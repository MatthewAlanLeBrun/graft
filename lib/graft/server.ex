defmodule Graft.Server do
    @moduledoc false
    @heartbeat Application.compile_env(:graft, :heartbeat_timeout)
    use GenStateMachine, callback_mode: :state_functions
    require Logger

    def start_link(me, servers, machine_module, machine_args) do
        Logger.info "Starting graft server #{inspect me}."
        GenStateMachine.start_link(__MODULE__, [me, servers, machine_module, machine_args], name: me)
    end

    def init([me, servers, machine_module, machine_args]) do
        {:ok, machine} = Graft.Machine.register machine_module, machine_args
        Logger.info "#{me} registered #{machine_module} as its machine."
        {:ok, :follower, %Graft.State{me: {me, node()},
                                      servers: servers,
                                      server_count: length(servers),
                                      machine: machine}}
    end

    ############################################################################
    #### FOLLOWER BEHAVIOUR ####
    ############################################################################

    ### General Rules ###

    def follower(:cast, :start, data) do
        Logger.debug "#{inspect data.me} is starting its timeout as a follower."
        {:keep_state_and_data, [{{:timeout, :election_timeout}, generate_time_out(), :begin_election}]}
    end

    def follower({:timeout, :election_timeout}, :begin_election, data) do
        Logger.debug "#{inspect data.me} timed out. Starting election..."
        {:next_state, :candidate, data, [{:next_event, :cast, :request_votes}]}
    end

    def follower(:cast, :data, data) do
        IO.inspect data, label: "Data"
        {:keep_state_and_data, []}
    end

    def follower(:cast, event, data = %Graft.State{last_applied: last_applied, commit_index: commit_index})
        when commit_index > last_applied
    do
        apply_entry last_applied+1, data.log, data.machine
        {:keep_state, %Graft.State{data | last_applied: last_applied+1}, [{:next_event, :cast, event}]}
    end

    def follower(:cast, rpc = %{term: term}, data = %Graft.State{current_term: current_term})
        when term > current_term
    do
        handle_event :cast, rpc, data
    end

    ### Request Vote Rules ###

    def follower(:cast, %Graft.RequestVoteRPC{term: term, candidate_name: candidate},
        data = %Graft.State{current_term: current_term})
        when term < current_term
    do
        Logger.debug "#{inspect data.me} reveived RequestVoteRPC from #{inspect candidate}."
        reply :rv, candidate, current_term, false
        {:keep_state_and_data, []}
    end

    def follower(:cast, %Graft.RequestVoteRPC{term: term, last_log_index: rpc_lli, last_log_term: rpc_llt, candidate_name: candidate},
        data = %Graft.State{voted_for: voted_for, log: [{last_log_index, last_log_term, _entry} | _tail]})
        when rpc_llt >= last_log_term and rpc_lli >= last_log_index and voted_for in [nil, candidate]
    do
        reply :rv, candidate, term, true
        {:keep_state, %Graft.State{data | voted_for: candidate, current_term: term}, [{:next_event, :cast, :start}]}
    end

    def follower(:cast, %Graft.RequestVoteRPC{candidate_name: candidate}, %Graft.State{current_term: current_term}) do
        reply :rv, candidate, current_term, false
        {:keep_state_and_data, []}
    end

    ### Append Entries Rules ###

    def follower(:cast, %Graft.AppendEntriesRPC{term: term, leader_name: leader},
        %Graft.State{current_term: current_term, me: me}) when term < current_term
    do
        Logger.debug "#{inspect me} received AE RPC with outdated term. Replying with success: false."
        reply :ae, leader, me, current_term, false 
        {:keep_state_and_data, []}
    end

    def follower(:cast, %Graft.AppendEntriesRPC{term: term, leader_name: leader, prev_log_index: rpc_pli,
        prev_log_term: rpc_plt, leader_commit: leader_commit, entries: entries},
        data = %Graft.State{current_term: current_term, log: log, commit_index: commit_index})
    do
        resolve_ae = fn log ->
            new_log = [{last_new_index, last_new_term, _entry} | _tail] = append_entries log, entries, rpc_pli
            commit_index = if (leader_commit > commit_index), do: min(leader_commit, last_new_index), else: commit_index
            Logger.debug "#{inspect data.me} is appending the new entry. Replying to #{inspect(leader)} with success: true."
            case entries do
                [] -> reply :ae, leader, data.me, current_term, true
                _ -> reply :ae, leader, data.me, current_term, true, last_new_index, last_new_term
            end
            {:keep_state, %Graft.State{data | current_term: term, log: new_log, commit_index: commit_index, leader: leader},
             [{{:timeout, :election_timeout}, generate_time_out(), :begin_election}]}
        end

        Logger.debug "#{inspect data.me} received AppendEntriesRPC from #{inspect(leader)}."
        case Enum.at(Enum.reverse(log), rpc_pli) do
            {^rpc_pli, ^rpc_plt, _entry} ->
                Logger.debug "Matching log"
                resolve_ae.(log)
            _ ->
                Logger.debug "#{inspect data.me} did NOT append entry because of bad log. Replying to #{inspect(leader)} with success: false."
                GenStateMachine.cast leader, %Graft.AppendEntriesRPCReply{term: current_term, success: false, from: data.me}
                {:keep_state_and_data, [{{:timeout, :election_timeout}, generate_time_out(), :begin_election}]}
        end
    end

    def follower(:cast, :force_promotion, data) do
        {:next_state, :leader, data, [{{:timeout, :election_timeout}, :infinity, :ok}, {:next_event, :cast, :init}]}
    end

    ### Default ###

    def follower(:cast, _event, _data), do: {:keep_state_and_data, []}
    def follower({:call, from}, {:entry, _entry}, data) do
        {:keep_state_and_data, [{:reply, from, {:error, {:redirect, data.leader}}}]}
    end
    def follower({:call, from}, :data, data), do: {:keep_state_and_data, [{:reply, from, data}]}
    def follower({:call, from}, :leader, data), do: {:keep_state_and_data, [{:reply, from, data.leader}]}
    def follower({:call, from}, _event, _data), do: {:keep_state_and_data, [{:reply, from, {:error, :invalid_event}}]}

    ############################################################################
    #### CANDIDATE BEHAVIOUR ####
    ############################################################################

    ### General Rules ###

    def candidate({:timeout, :election_timeout}, :begin_election, data) do
        Logger.debug "#{inspect data.me} timed out as candidate. Restarting election..."
        {:keep_state_and_data, [{:next_event, :cast, :request_votes}]}
    end

    def candidate({:call, from}, {:entry, _entry}, %Graft.State{leader: leader}) do
        {:keep_state_and_data, [{:reply, from, {:error, {:redirect, leader}}}]}
    end

    def candidate(:cast, event, data = %Graft.State{last_applied: last_applied, commit_index: commit_index})
        when commit_index > last_applied
    do
        apply_entry last_applied+1, data.log, data.machine
        {:keep_state, %Graft.State{data | last_applied: last_applied+1}, [{:next_event, :cast, event}]}
    end

    def candidate(:cast, rpc = %{term: term}, data = %Graft.State{current_term: current_term})
        when term > current_term
    do
        Logger.debug "#{inspect data.me} got an RPC with a higher term. Demoting to follower..."
        handle_event :cast, rpc, data
    end

    ### Request Vote Rules ###

    def candidate(:cast, :request_votes, data = %Graft.State{me: me, servers: servers, votes: votes,
        current_term: current_term, log: [{last_index, last_term, _} | _tail]})
    do
        Logger.debug "#{inspect data.me} is sending out RequestVoteRPCs to all other nodes."
        for server <- servers, server !== me do
            GenStateMachine.cast(server, %Graft.RequestVoteRPC{
                term: current_term+1,
                candidate_name: me,
                last_log_index: last_index,
                last_log_term: last_term
            })
        end
        {:keep_state, %Graft.State{data | current_term: current_term+1, voted_for: me, votes: votes+1},
         [{{:timeout, :election_timeout}, generate_time_out(), :begin_election}]}
    end

    def candidate(:cast, %Graft.RequestVoteRPCReply{vote_granted: true},
        data = %Graft.State{votes: votes, server_count: server_count})
    do
        Logger.debug "#{inspect data.me} received a vote! Total votes: #{data.votes+1}."
        if votes+1 > server_count/2 do
            Logger.debug "#{inspect data.me} received majority votes! Becoming leader..."
            {:next_state, :leader, %Graft.State{data | votes: votes+1},
             [{{:timeout, :election_timeout}, :infinity, :ok}, {:next_event, :cast, :init}]}
        else
            {:keep_state, %Graft.State{data | votes: votes+1}, []}
        end
    end

    ### Append Entries Rules ###

    def candidate(:cast, rpc = %Graft.AppendEntriesRPC{leader_name: leader}, data) do
        {:next_state, :follower, %Graft.State{data | leader: leader},
         [{{:timeout, :election_timeout}, generate_time_out(), :begin_election}, {:next_event, :cast, rpc}]}
    end

    ### Default ###

    def candidate(:cast, _event, _data), do: {:keep_state_and_data, []}
    def candidate({:call, from}, _event, _data), do: {:keep_state_and_data, [{:reply, from, {:error, :invalid_event}}]}

    ############################################################################
    #### LEADER BEHAVIOUR ####
    ############################################################################

    ### General Rules ###

    def leader(:cast, event, data = %Graft.State{last_applied: last_applied, commit_index: commit_index})
        when commit_index > last_applied
    do
        response = apply_entry last_applied+1, data.log, data.machine
        {:keep_state, %Graft.State{data | last_applied: last_applied+1},
         [{:reply, data.requests[last_applied+1], {:ok, response}}, {:next_event, :cast, event}]}
    end

    def leader(:cast, rpc = %{term: term}, data = %Graft.State{current_term: current_term})
        when term > current_term
    do
        Logger.debug "#{inspect data.me} got RPC with with higher term. RPC: #{inspect rpc}"
        handle_event :cast, rpc, data
    end

    def leader(:cast, :init, data = %Graft.State{log: [{prev_index, _, _} | _]}) do
        t=:os.system_time(:millisecond)
        Graft.Timer.elected t, data.me
        Logger.info "New leader: #{inspect data.me}."
        match_index = for server <- data.servers, into: %{} do
            {server, 0}
        end
        ready = for server <- data.servers, into: %{} do
            {server, true}
        end
        next_index = for server <- data.servers, into: %{} do
            {server, prev_index+1}
        end
        events = for server={name, node} <- data.servers, server !== data.me do
            {{:timeout, {:heartbeat, {name, node}}}, 0, :send_heartbeat}
        end
        {:keep_state, %Graft.State{data | ready: ready, next_index: next_index, match_index: match_index}, events}
    end

    def leader({:timeout, {:heartbeat, server}}, :send_heartbeat, %Graft.State{me: me}) do
        Logger.debug "#{inspect me} is sending a heartbeat RPC to #{inspect server}."
        {:keep_state_and_data, [{:next_event, :cast, {:send_append_entries, server}}]}
    end

    ### Request Vote Rules ###

    def leader(:cast, %Graft.RequestVoteRPCReply{vote_granted: true}, data) do
        Logger.debug "#{inspect data.me} got another vote! Total votes: #{data.votes+1}."
        {:keep_state, %Graft.State{data | votes: data.votes+1}, []}
    end

    ### Append Entries Rules ###
    def leader({:call, from}, {:entry, entry}, data = %Graft.State{log: log = [{prev_index, _, _} | _]}) do
        Logger.debug "#{inspect data.me} received a request from a client! Index of entry: #{prev_index+1}."
        requests = Map.put data.requests, prev_index+1, from
        log = [{prev_index+1, data.current_term, entry} | log]
        events = for server <- data.servers, server !== data.me, data.ready[server] === true do
            {:next_event, :cast, {:send_append_entries, server}}
        end
        {:keep_state, %Graft.State{data | log: log, requests: requests}, events}
    end

    def leader(:cast, %Graft.AppendEntriesRPCReply{success: true, last_log_index: lli, from: from}, data)
        when lli === -1
    do
        ready = %{data.ready | from => true}
        {:keep_state, %Graft.State{data | ready: ready}, []}
    end

    def leader(:cast, %Graft.AppendEntriesRPCReply{success: true, last_log_index: lli, last_log_term: llt, from: from},
               data = %Graft.State{ready: ready, match_index: match_index, log: [{prev_index, _, _} | _]})
    do
        Logger.debug "#{inspect data.me} recceived a SUCCESSFUL AppendEntriesRPCReply from #{inspect from}."
        match_index = %{match_index | from => lli}
        ready = %{ready | from => true}
        next_index = %{data.next_index | from => data.next_index[from]+1}
        events = if data.next_index[from] > prev_index do
            [{:next_event, :cast, :ok}]
        else
            [{:next_event, :cast, {:send_append_entries, from}}]
        end
        commit_index = if (lli > data.commit_index) and (llt === data.current_term) do
            number_of_matches = Enum.reduce(match_index, 1, fn {server, index}, acc ->
                if (server !== data.me) and (index >= lli), do: acc+1, else: acc end)
            if number_of_matches > (data.server_count/2), do: lli, else: data.commit_index
        else
            data.commit_index
        end
        {:keep_state, %Graft.State{data | ready: ready, next_index: next_index, commit_index: commit_index, match_index: match_index}, events}
    end

    def leader(:cast, %Graft.AppendEntriesRPCReply{success: false, from: from}, data) do
        Logger.debug "#{inspect data.me} (term: #{data.current_term}) received an UNSUCCESSFUL AppendEntriesRPCReply from #{inspect from}."
        next_index = %{data.next_index | from => data.next_index[from]-1}
        {:keep_state, %Graft.State{data | next_index: next_index}, [{:next_event, :cast, {:send_append_entries, from}}]}
    end

    def leader(:cast, {:send_append_entries, to}, data = %Graft.State{ready: ready, log: log = [{last_index, _, _} | _tail]}) do
        ready = %{ready | to => false}
        entry = if (next = data.next_index[to]) > last_index do
            []
        else
            {^next, term, entry} = Enum.reverse(log) |> Enum.at(next)
            [{term, entry}]
        end
        {prev_index, prev_term, _prev_enrty} = case log do
            [{0, 0, nil}] -> {0, 0, nil}
            _ -> Enum.reverse(log) |> Enum.at(next-1)
        end
        rpc = %Graft.AppendEntriesRPC{
            term: data.current_term,
            leader_name: data.me,
            prev_log_index: prev_index,
            prev_log_term: prev_term,
            entries: entry,
            leader_commit: data.commit_index
        }
        Logger.debug "#{inspect data.me} is sending an AppendEntriesRPC to #{inspect to}. RPC: #{inspect(rpc)}."
        GenStateMachine.cast(to, rpc)
        {:keep_state, %Graft.State{data | ready: ready}, [{{:timeout, {:heartbeat, to}}, @heartbeat, :send_heartbeat}]}
    end

    ### Default ###

    def leader(:cast, _event, _data), do: {:keep_state_and_data, []}
    def leader({:call, from}, :data, data), do: {:keep_state_and_data, [{:reply, from, data}]}
    def leader({:call, from}, :leader, data), do: {:keep_state_and_data, [{:reply, from, data.me}]}
    def leader({:call, from}, _event, _data), do: {:keep_state_and_data, [{:reply, from, {:error, :invalid_event}}]}

    ############################################################################
    #### GENERAL BEHAVIOUR ####
    ############################################################################

    def handle_event(:cast, rpc = %{term: term}, data = %Graft.State{current_term: current_term})
        when term > current_term
    do
        {:next_state, :follower, %Graft.State{data | current_term: term, voted_for: nil, votes: 0},
         [{{:timeout, :heartbeat}, :infinity, :send_heartbeat}, {{:timeout, :election_timeout}, generate_time_out(), :begin_election}, {:next_event, :cast, rpc}]}
    end

    ############################################################################
    #### OTHER FUNCTIONS ####
    ############################################################################

    def generate_time_out, do: Application.fetch_env!(:graft, :server_timeout).()

    def reply(:rv, to, term, vote) do
        Logger.debug "#{inspect self()} is sending RV RPC REPLY to #{inspect to} with vote_granted: #{inspect vote}."
        GenStateMachine.cast(to, %Graft.RequestVoteRPCReply{term: term, vote_granted: vote})
    end

    def reply(:ae, to, from, term, success) do
        Logger.debug "#{inspect from} is sending AE RPC REPLY to #{inspect to} with success: #{inspect success} and term: #{inspect term}."
        GenStateMachine.cast(to, %Graft.AppendEntriesRPCReply{term: term, success: success, from: from})
    end

    def reply(:ae, to, from, term, success, lli, llt) do
        GenStateMachine.cast(to, %Graft.AppendEntriesRPCReply{term: term, success: success, last_log_index: lli, last_log_term: llt, from: from})
    end

    def append_entries(log, [], _pli) do
        log
    end

    def append_entries(log, entries, pli) do
        ordered_log = Enum.reverse log
        entries = Stream.with_index(entries, pli+1)
        |> Enum.map(fn {{term, entry}, index} -> {index, term, entry} end)

        entries = for e={i, t, _} <- entries do
            case Enum.at ordered_log, i do
                {^i, ^t, _} -> nil
                {^i, term, _} when term !==t -> e
                nil -> e
            end
        end
        |> Enum.drop_while(fn x -> x==nil end)
        
        log = case entries do
            [{i, _, _} | _tail] -> Enum.slice ordered_log, 0..i-1
            [] -> ordered_log
        end |> Enum.reverse
        
        entries
        |> Enum.reverse
        |> Kernel.++(log)
    end

    def apply_entry(apply_index, log, machine) do
        {^apply_index, _term, entry} = log
            |> Enum.reverse
            |> Enum.at(apply_index)
        Graft.Machine.apply_entry machine, entry
    end
end
