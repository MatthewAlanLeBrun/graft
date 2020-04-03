defmodule Graft.Server do
    use GenStateMachine, callback_mode: :state_functions

    def start(me, servers) do
        GenStateMachine.start(__MODULE__, [me, servers], name: me)
    end

    def init([me, servers]) do
        {:ok, :follower, %Graft.State{me: me,
                                      servers: servers,
                                      server_count: length(servers),
                                      time_out: generate_time_out()}}
    end

    #### FOLLOWER BEHAVIOUR ####

    ### Request Vote Rules ###

    def follower(:cast, rpc = %Graft.RequestVoteRPC{}, data) do
        handle_event :cast, rpc, data
    end

    ### Append Entries Rules ###

    def follower(:cast, rpc = %Graft.AppendEntriesRPC{entries: []}, data) do
        {:keep_state, %Graft.State{data | leader: rpc.leader_name}, [{{:timeout, :election_timeout}, data.time_out, :begin_election}]}
    end

    ### General Rules ###

    def follower(:cast, :start, data) do
        {:keep_state_and_data, [{{:timeout, :election_timeout}, data.time_out, :begin_election}]}
    end

    def follower({:timeout, :election_timeout}, :begin_election, data) do
        IO.puts("#{data.me} timed out as follower. Starting election.")
        {:next_state,
         :candidate,
         %Graft.State{data | state: :candidate, current_term: data.current_term+1,
                             voted_for: data.me, votes: data.votes+1},
         [{:next_event, :cast, :request_votes}]}
    end

    def follower({:call, from}, :data, data) do
        {:keep_state_and_data, [{:reply, from, data}]}
    end

    def follower({:call, from}, {:entry, _operation, _key}, data) do
        {:keep_state_and_data, [{:reply, from, {:error, {:redirect, data.leader}}}]}
    end

    #### CANDIDATE BEHAVIOUR ####

    ### Request Vote Rules ###

    def candidate(:cast, :request_votes, data = %Graft.State{me: me, servers: servers, current_term: current_term, log: [{last_index, last_term, _} | _tail]}) do
        IO.puts "#{data.me} seding vote requests."
        for server <- servers, server !== me do
            GenStateMachine.cast(server, %Graft.RequestVoteRPC{
                term: current_term,
                candidate_name: me,
                last_log_index: last_index,
                last_log_term: last_term
            })
        end
        {:keep_state_and_data, []}
    end

    def candidate(:cast, %Graft.RequestVoteRPCReply{vote_granted: true}, data = %Graft.State{votes: votes, server_count: server_count}) do
        IO.puts "#{data.me} got vote number #{data.votes+1}."
        if votes+1 > server_count/2 do
            IO.puts "#{data.me} got majority votes, becoming leader."
            {:next_state, :leader, %Graft.State{data | votes: votes+1, state: :leader}, [{{:timeout, :heartbeat}, 0, :ok}]}
        else
            {:keep_state, %Graft.State{data | votes: votes+1}, []}
        end
    end

    def candidate(:cast, %Graft.RequestVoteRPCReply{term: term, vote_granted: false}, data = %Graft.State{current_term: current_term}) do
        if term > current_term do
            {:next_state, :follower, %Graft.State{data | current_term: term}, [{:next_event, :cast, :start}]}
        else
            {:keep_state_and_data, []}
        end
    end

    def candidate(:cast, rpc = %Graft.RequestVoteRPC{}, data) do
        handle_event :cast, rpc, data
    end

    ### Append Entries Rules ###
    ### General Rules ###

    def candidate({:call, from}, {:entry, _operation, _key}, %Graft.State{leader: leader}) do
        {:keep_state_and_data, [{:reply, from, {:error, {:redirect, leader}}}]}
    end

    def candidate(event_type, event_content, data) do
        handle_event(event_type, event_content, data)
    end

    #### LEADER BEHAVIOUR ####

    ### Request Vote Rules ###
    ### Append Entries Rules ###
    ### General Rules ###

    def leader({:timeout, :heartbeat}, :ok, data) do
        IO.puts("#{data.me} sending heartbeat.")
        send_append_entries(%Graft.AppendEntriesRPC{
            term: data.current_term,
            leader_name: data.me
        }, data.servers, data.me)
        {:keep_state_and_data, [{{:timeout, :heartbeat}, 4000, :ok}]}
    end

    def leader(:cast, %Graft.RequestVoteRPCReply{vote_granted: true}, data) do
        IO.puts("#{data.me} got vote number #{data.votes+1}")
        {:keep_state, %Graft.State{data | votes: data.votes+1}, []}
    end

    def leader(:cast, rpc = %Graft.RequestVoteRPC{}, data) do
        handle_event :cast, rpc, data
    end

    def leader(event_type, event_content, data) do
        handle_event(event_type, event_content, data)
    end

    #### GENERAL BEHAVIOUR ####

    ### Request Vote Rules ###

    def handle_event(:cast, %Graft.RequestVoteRPC{term: term, candidate_name: candidate},
                            %Graft.State{current_term: current_term})
                            when term < current_term do
        reply :rv, candidate, current_term, false
        {:keep_state_and_data, []}
    end

    def handle_event(:cast, %Graft.RequestVoteRPC{term: term, last_log_index: rpc_lli, last_log_term: rpc_llt, candidate_name: candidate},
                        data = %Graft.State{current_term: current_term, log: [{last_log_index, last_log_term, _entry} | _tail]})
                        when term > current_term and rpc_llt >= last_log_term and rpc_lli >= last_log_index do
        reply :rv, candidate, term, true
        {:next_state, :follower, %Graft.State{data | voted_for: candidate, current_term: term}, [{:next_event, :cast, :start}]}
    end

    def handle_event(:cast, %Graft.RequestVoteRPC{term: term, last_log_index: rpc_lli, last_log_term: rpc_llt, candidate_name: candidate},
                        data = %Graft.State{voted_for: voted_for, log: [{last_log_index, last_log_term, _entry} | _tail]})
                        when rpc_llt >= last_log_term and rpc_lli >= last_log_index and voted_for in [nil, candidate] do
        reply :rv, candidate, term, true
        {:next_state, :follower, %Graft.State{data | voted_for: candidate, current_term: term}, [{:next_event, :cast, :start}]}
    end

    def handle_event(:cast, %Graft.RequestVoteRPC{candidate_name: candidate}, %Graft.State{current_term: current_term}) do
        reply :rv, candidate, current_term, false
        {:keep_state_and_data, []}
    end

    ### Append Entries Rules ###

    def handle_event(:cast, %Graft.AppendEntriesRPC{term: term, leader_name: leader},
                            %Graft.State{current_term: current_term}) when term < current_term do
        reply :ae, leader, current_term, false
        {:keep_state_and_data, []}
    end

    def handle_event(:cast, %Graft.AppendEntriesRPC{term: term, leader_name: leader, prev_log_index: rpc_pli, prev_log_term: rpc_plt, leader_commit: leader_commit, entries: entries},
                            data = %Graft.State{current_term: current_term, log: log, commit_index: commit_index}) do
        resolve_ae = fn log ->
            new_log = [{last_new_index, _term, _entry} | _tail] = append_entries log, entries, term
            commit_index = if leader_commit > commit_index do
                min leader_commit, last_new_index
            else commit_index
            end
            reply :ae, leader, current_term, true
            {:next_state, :follower, %Graft.State{data | current_term: term, log: new_log, commit_index: commit_index, leader: leader},
                                     [{:next_event, :cast, :start}]}
        end

        case Enum.at(ordered_log = Enum.reverse(log), rpc_pli) do
            {^rpc_pli, ^rpc_plt, _entry} -> # matching
                resolve_ae.(log)
            {^rpc_pli, term, _entry} when term !== rpc_plt -> # conflicting
                Enum.split(ordered_log, rpc_pli)
                |> Enum.reverse
                |> resolve_ae.()
            _ -> # bad log
                reply :ae, leader, current_term, false
                {:keep_state_and_data, []} # TODO: can be made follower here and restart timer
        end
    end

    def handle_event(:cast, %Graft.AppendEntriesRPC{leader_name: leader}, %Graft.State{current_term: current_term}) do
        reply :ae, leader, current_term, false
        {:keep_state_and_data, []}
    end

    def handle_event({:call, from}, _event_content, data) do
        {:keep_state_and_data, [{:reply, from, data}]}
    end

    def handle_event(_event_type, _event_content, _data) do
        {:keep_state_and_data, []}
    end

    #### OTHER FUNCTIONS ####

    def generate_time_out, do: :rand.uniform(500)*10+5000

    def send_append_entries(rpc, servers, me) do
        for server <- servers do
            case server do
                ^me -> :ok
                _ -> GenStateMachine.cast(server, rpc)
            end
        end
    end

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
