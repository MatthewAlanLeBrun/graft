defmodule Graft.Server do
    use GenStateMachine, callback_mode: :state_functions

    def start_link(me, servers, machine_module, machine_args) do
        IO.inspect me, label: "Starting server"
        GenStateMachine.start_link(__MODULE__, [me, servers, machine_module, machine_args], name: me)
    end

    def init([me, servers, machine_module, machine_args]) do
        {:ok, machine} = Graft.Machine.register machine_module, machine_args
        IO.puts("registered machine")
        {:ok, :follower, %Graft.State{me: me,
                                      servers: servers,
                                      server_count: length(servers),
                                      machine: machine}}
    end

    ############################################################################
    #### FOLLOWER BEHAVIOUR ####
    ############################################################################

    ### General Rules ###

    def follower(:cast, :start, _data) do
        {:keep_state_and_data, [{{:timeout, :election_timeout}, generate_time_out(), :begin_election}]}
    end

    def follower({:timeout, :election_timeout}, :begin_election, data) do
        IO.inspect data.me, label: "Timed out"
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
        %Graft.State{current_term: current_term})
        when term < current_term
    do
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
        reply :ae, leader, me, current_term, false
        {:keep_state_and_data, []}
    end

    def follower(:cast, %Graft.AppendEntriesRPC{term: term, leader_name: leader, prev_log_index: rpc_pli,
        prev_log_term: rpc_plt, leader_commit: leader_commit, entries: entries},
        data = %Graft.State{current_term: current_term, log: log, commit_index: commit_index})
    do
        resolve_ae = fn log ->
            new_log = [{last_new_index, last_new_term, _entry} | _tail] = append_entries log, entries, term
            commit_index = if (leader_commit > commit_index), do: min(leader_commit, last_new_index), else: commit_index
            IO.puts "#{data.me} received AE RPC from #{leader}. AE was successful."
            case entries do
                [] -> reply :ae, leader, data.me, current_term, true
                _ -> reply :ae, leader, data.me, current_term, true, last_new_index, last_new_term
            end
            {:keep_state, %Graft.State{data | current_term: term, log: new_log, commit_index: commit_index, leader: leader},
             [{{:timeout, :election_timeout}, generate_time_out(), :begin_election}]}
        end

        case Enum.at(ordered_log = Enum.reverse(log), rpc_pli) do
            {^rpc_pli, ^rpc_plt, _entry} -> # matching
                resolve_ae.(log)
            {^rpc_pli, term, _entry} when term !== rpc_plt -> # conflicting
                Enum.split(ordered_log, rpc_pli)
                |> Enum.reverse
                |> resolve_ae.()
            _ -> # bad log
                IO.puts "#{data.me} received AE RPC from #{leader}. AE was NOT successful."
                GenStateMachine.cast leader, {%Graft.AppendEntriesRPCReply{term: current_term, success: false}, data.me}
                {:keep_state_and_data, [{{:timeout, :election_timeout}, generate_time_out(), :begin_election}]}
        end
    end

    ### Default ###

    def follower(:cast, _event, _data), do: {:keep_state_and_data, []}
    def follower({:call, from}, {:entry, _entry}, data) do
        {:keep_state_and_data, [{:reply, from, {:error, {:redirect, data.leader}}}]}
    end
    def follower({:call, from}, :data, data), do: {:keep_state_and_data, [{:reply, from, data}]}
    def follower({:call, from}, _event, _data), do: {:keep_state_and_data, [{:reply, from, {:error, :invalid_event}}]}

    ############################################################################
    #### CANDIDATE BEHAVIOUR ####
    ############################################################################

    ### General Rules ###

    def candidate({:timeout, :election_timeout}, :begin_election, data) do
        IO.puts "#{data.me} timed out as candidate, restarting election."
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
        IO.inspect data.me, "Demoting"
        handle_event :cast, rpc, data
    end

    ### Request Vote Rules ###

    def candidate(:cast, :request_votes, data = %Graft.State{me: me, servers: servers, votes: votes,
        current_term: current_term, log: [{last_index, last_term, _} | _tail]})
    do
        IO.puts "#{data.me} seding vote requests."
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
        IO.puts "#{data.me} got vote number #{data.votes+1}."
        if votes+1 > server_count/2 do
            IO.puts "#{data.me} got majority votes, becoming leader."
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
        handle_event :cast, rpc, data
    end

    def leader(:cast, :init, data = %Graft.State{log: [{prev_index, _, _} | _]}) do
        match_index = for server <- data.servers, into: %{} do
            {server, 0}
        end
        ready = for server <- data.servers, into: %{} do
            {server, true}
        end
        next_index = for server <- data.servers, into: %{} do
            {server, prev_index+1}
        end |> IO.inspect(label: "next_index init")
        events = for server <- data.servers, server !== data.me do
            {{:timeout, {:heartbeat, server}}, 0, :send_heartbeat}
        end
        {:keep_state, %Graft.State{data | ready: ready, next_index: next_index, match_index: match_index}, events}
    end

    def leader({:timeout, {:heartbeat, server}}, :send_heartbeat, %Graft.State{me: me}) do
        IO.inspect me, label: "Heartbeat timeout for #{server}, sending from"
        {:keep_state_and_data, [{:next_event, :cast, {:send_append_entries, server}}]}
    end

    ### Request Vote Rules ###

    def leader(:cast, %Graft.RequestVoteRPCReply{vote_granted: true}, data) do
        IO.puts("#{data.me} got vote number #{data.votes+1}")
        {:keep_state, %Graft.State{data | votes: data.votes+1}, []}
    end

    ### Append Entries Rules ###
    def leader({:call, from}, {:entry, entry}, data = %Graft.State{log: log = [{prev_index, _, _} | _]}) do
        IO.inspect entry, label: "Request received from client. Idx: #{prev_index+1}, entry"
        requests = Map.put data.requests, prev_index+1, from
        log = [{prev_index+1, data.current_term, entry} | log]
        events = for server <- data.servers, server !== data.me, data.ready[server] === true do
            {:next_event, :cast, {:send_append_entries, server}}
        end
        {:keep_state, %Graft.State{data | log: log, requests: requests}, events}
    end

    def leader(:cast, {rpc = %Graft.AppendEntriesRPCReply{success: true, last_log_index: lli}, from}, data)
        when lli === -1
    do
        IO.inspect rpc, label: "#{data.me} received AE RPC reply from #{from}. RPC"
        ready = %{data.ready | from => true}
        {:keep_state, %Graft.State{data | ready: ready}, []}
    end

    def leader(:cast, {rpc = %Graft.AppendEntriesRPCReply{success: true, last_log_index: lli, last_log_term: llt}, from},
               data = %Graft.State{ready: ready, match_index: match_index, log: [{prev_index, _, _} | _]})
    do
        IO.inspect rpc, label: "#{data.me} received AE RPC reply from #{from}. RPC: "
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

    def leader(:cast, {%Graft.AppendEntriesRPCReply{success: false}, from}, data) do
        next_index = %{data.next_index | from => data.next_index[from]-1}
        {:keep_state, %Graft.State{data | next_index: next_index}, [{:next_event, :cast, {:send_append_entries, from}}]}
    end

    def leader(:cast, {:send_append_entries, to}, data = %Graft.State{ready: ready, log: log}) do
        {last_index, prev_index, prev_term} = case log do
            [{last_index, _, _}, {prev_index, prev_term, _} | _] -> {last_index, prev_index, prev_term}
            [{0, 0, nil}] -> {0, 0, 0}
        end
        ready = %{ready | to => false}
        IO.inspect(data.next_index[to], label: "next_index")
        IO.inspect(last_index, label: "last_index")
        entry = if (next = data.next_index[to]) > last_index do
            []
        else
            {^next, _, entry} = Enum.reverse(log) |> Enum.at(next)
            [entry]
        end
        rpc = %Graft.AppendEntriesRPC{
            term: data.current_term,
            leader_name: data.me,
            prev_log_index: prev_index,
            prev_log_term: prev_term,
            entries: entry,
            leader_commit: data.commit_index
        }
        |> IO.inspect(label: "Sending AE RPC to #{to}, from #{data.me}. RPC")
        GenStateMachine.cast(to, rpc)
        {:keep_state, %Graft.State{data | ready: ready}, [{{:timeout, {:heartbeat, to}}, 3000, :send_heartbeat}]}
    end

    ### Default ###

    def leader(:cast, _event, _data), do: {:keep_state_and_data, []}
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

    def generate_time_out, do: :rand.uniform(500)*10+5000

    def reply(:rv, to, term, vote) do
        GenStateMachine.cast(to, %Graft.RequestVoteRPCReply{term: term, vote_granted: vote})
    end

    def reply(:ae, to, from, term, success) do
        GenStateMachine.cast(to, {%Graft.AppendEntriesRPCReply{term: term, success: success}, from})
    end

    def reply(:ae, to, from, term, success, lli, llt) do
        GenStateMachine.cast(to, {%Graft.AppendEntriesRPCReply{term: term, success: success, last_log_index: lli, last_log_term: llt}, from})
    end

    def append_entries(log, entries, term) do
        Stream.with_index(entries, Enum.count(log))
        |> Enum.map(fn {entry, index} -> {index, term, entry} end)
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
