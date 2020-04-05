defmodule Graft.Server do
    use GenStateMachine, callback_mode: :state_functions

    def start(me, servers) do
        GenStateMachine.start(__MODULE__, [me, servers], name: me)
    end

    def init([me, servers]) do
        {:ok, :follower, %Graft.State{me: me,
                                      servers: servers,
                                      server_count: length(servers)}}
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

    def follower({:call, from}, {:entry, _operation, _key}, data) do
        {:keep_state_and_data, [{:reply, from, {:error, {:redirect, data.leader}}}]}
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
        %Graft.State{current_term: current_term}) when term < current_term
    do
        reply :ae, leader, current_term, false
        {:keep_state_and_data, []}
    end

    def follower(:cast, %Graft.AppendEntriesRPC{term: term, leader_name: leader, prev_log_index: rpc_pli,
        prev_log_term: rpc_plt, leader_commit: leader_commit, entries: entries},
        data = %Graft.State{current_term: current_term, log: log, commit_index: commit_index})
    do
        IO.inspect data.me, label: "Received AE rpc"
        resolve_ae = fn log ->
            new_log = [{last_new_index, _term, _entry} | _tail] = append_entries log, entries, term
            commit_index = if leader_commit > commit_index do
                min leader_commit, last_new_index
            else commit_index
            end
            IO.inspect true, label: "Reply"
            reply :ae, leader, current_term, true
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
                IO.inspect true, label: "Reply"
                reply :ae, leader, current_term, false
                {:keep_state_and_data, []} # TODO: can be made follower here and restart timer
        end
    end

    def follower(:cast, %Graft.AppendEntriesRPC{leader_name: leader}, %Graft.State{current_term: current_term}) do
        reply :ae, leader, current_term, false
        {:keep_state_and_data, []}
    end

    ############################################################################
    #### CANDIDATE BEHAVIOUR ####
    ############################################################################

    ### General Rules ###

    def candidate({:timeout, :election_timeout}, :begin_election, data) do
        IO.puts "#{data.me} timed out as candidate, restarting election."
        {:keep_state_and_data, [{:next_event, :cast, :request_votes}]}
    end

    def candidate({:call, from}, {:entry, _operation, _key}, %Graft.State{leader: leader}) do
        {:keep_state_and_data, [{:reply, from, {:error, {:redirect, leader}}}]}
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
            {:next_state, :leader, %Graft.State{data | votes: votes+1}, [{{:timeout, :heartbeat}, 0, :send_heartbeat}]}
        else
            {:keep_state, %Graft.State{data | votes: votes+1}, []}
        end
    end

    ### Append Entries Rules ###

    def candidate(:cast, rpc = %Graft.AppendEntriesRPC{leader_name: leader}, data) do
        {:next_state, :follower, %Graft.State{data | leader: leader},
         [{{:timeout, :election_timeout}, generate_time_out(), :begin_election}, {:next_event, :cast, rpc}]}
    end

    def candidate(:cast, _event, _data) do
        {:keep_state_and_data, []}
    end

    def candidate(event_type, event_content, data) do
        handle_event(event_type, event_content, data)
    end

    #### LEADER BEHAVIOUR ####

    ### General Rules ###

    def leader(:cast, rpc = %{term: term}, data = %Graft.State{current_term: current_term})
        when term > current_term
    do
        handle_event :cast, rpc, data
    end

    def leader({:timeout, :heartbeat}, :send_heartbeat, data = %Graft.State{servers: servers, me: me, log: [{pli, plt, _entry} | _tail]}) do
        IO.inspect me, label: "Sending heartbeat"
        for server <- servers, server !== me do
            GenStateMachine.cast(server, %Graft.AppendEntriesRPC{
                term: data.current_term,
                leader_name: me,
                prev_log_index: pli,
                prev_log_term: plt,
                entries: [],
                leader_commit: data.commit_index
                })
        end
        {:keep_state_and_data, [{{:timeout, :heartbeat}, 3000, :send_heartbeat}]}
    end

    ### Request Vote Rules ###

    def leader(:cast, %Graft.RequestVoteRPCReply{vote_granted: true}, data) do
        IO.puts("#{data.me} got vote number #{data.votes+1}")
        {:keep_state, %Graft.State{data | votes: data.votes+1}, []}
    end

    ### Append Entries Rules ###

    def leader(:cast, _event, _data) do
        {:keep_state_and_data, []}
    end

    def leader(event_type, event_content, data) do
        handle_event(event_type, event_content, data)
    end

    #### GENERAL BEHAVIOUR ####

    def handle_event(:cast, rpc = %{term: term}, data = %Graft.State{current_term: current_term})
        when term > current_term
    do
        {:next_state, :follower, %Graft.State{data | current_term: term, voted_for: nil, votes: 0},
         [{{:timeout, :heartbeat}, :infinity, :send_heartbeat}, {{:timeout, :election_timeout}, generate_time_out(), :begin_election}, {:next_event, :cast, rpc}]}
    end

    def handle_event({:call, from}, _event_content, data) do
        {:keep_state_and_data, [{:reply, from, data}]}
    end

    def handle_event(_event_type, _event_content, _data) do
        {:keep_state_and_data, []}
    end

    #### OTHER FUNCTIONS ####

    def generate_time_out, do: :rand.uniform(500)*10+5000

    def reply(:ae, to, term, success) do
        GenStateMachine.cast(to, %Graft.AppendEntriesRPCReply{term: term, success: success})
    end

    def reply(:rv, to, term, vote) do
        GenStateMachine.cast(to, %Graft.RequestVoteRPCReply{term: term, vote_granted: vote})
    end

    def append_entries(log, entries, term) do
        Stream.with_index(entries, Enum.count(log))
        |> Enum.map(fn {entry, index} -> {index, term, entry} end)
        |> Enum.reverse
        |> Kernel.++(log)
    end
end
