defmodule Graft.Server do
    use GenStateMachine, callback_mode: :state_functions

    def start(me, servers) do
        GenStateMachine.start(__MODULE__, [me, servers], name: me)
    end

    def init([:server1, servers]) do
        {:ok, :follower, %Graft.State{me: :server1,
                                      servers: servers,
                                      server_count: length(servers),
                                      time_out: 2000}}
    end

    def init([me, servers]) do
        {:ok, :follower, %Graft.State{me: me,
                                      servers: servers,
                                      server_count: length(servers),
                                      time_out: generate_time_out()}}
    end

    def follower(:cast, :start, data) do
        {:keep_state_and_data, [{{:timeout, :election_timeout}, data.time_out, :begin_election}]}
    end

    def follower({:timeout, :election_timeout}, :begin_election, data) do
        {:next_state,
         :candidate,
         %Graft.State{data | state: :candidate, current_term: data.current_term+1,
                             voted_for: data.me, votes: data.votes+1},
         [{:next_event, :cast, :request_votes}]}
    end

    def follower({:call, from}, :data, data) do
        {:keep_state_and_data, [{:reply, from, data}]}
    end

    def follower(:cast, {:request_vote, rpc = %Graft.RequestVoteRPC{}}, data) do
        current_term = data.current_term
        case rpc.term do
            term when term > current_term ->
                case data.voted_for do
                    nil ->
                        GenStateMachine.cast(rpc.candidate_pid, %Graft.RequestVoteRPCReply{term: data.current_term, vote_granted: true})
                        {:keep_state, %Graft.State{data | voted_for: rpc.candidate_pid}, [{:next_event, :cast, :start}]}
                    _ ->
                        GenStateMachine.cast(rpc.candidate_pid, %Graft.RequestVoteRPCReply{term: data.current_term})
                        {:keep_state_and_data, []}
                end
            _ ->
                GenStateMachine.cast(rpc.candidate_pid, %Graft.RequestVoteRPCReply{term: data.current_term})
                {:keep_state_and_data, []}
        end
    end

    def follower(:cast, %Graft.AppendEntriesRPC{entries: []}, data) do
        {:keep_state_and_data, [{{:timeout, :election_timeout}, data.time_out, :begin_election}]}
    end

    def candidate(:cast, :request_votes, data) do
        send_requests(data)
        {:keep_state_and_data, []}
    end

    def candidate(:cast, %Graft.RequestVoteRPCReply{vote_granted: true}, data) do
        case data.votes+1 > data.server_count/2 do
            true -> {:next_state, :leader, %Graft.State{data | votes: data.votes+1, state: :leader},
                                          [{{:timeout, :heartbeat}, 0, :ok}]}
            false -> {:keep_state, %Graft.State{data | votes: data.votes+1}, []}
        end
    end

    def candidate(:cast, %Graft.RequestVoteRPCReply{term: term, vote_granted: false}, data) do
        case (term > data.current_term) do
            true -> {:next_state, :follower, %Graft.State{data | current_term: term}, [{:next_event, :cast, :start}]}
            false -> {:keep_state_and_data, []}
        end
    end

    def candidate(event_type, event_content, data) do
        handle_event(event_type, event_content, data)
    end

    def leader({:timeout, :heartbeat}, :ok, data) do
        send_append_entries(%Graft.AppendEntriesRPC{
            term: data.current_term,
            leader_name: data.me
        }, data.servers, data.me)
        {:keep_state_and_data, [{{:timeout, :heartbeat}, 4000, :ok}]}
    end

    def leader(event_type, event_content, data) do
        handle_event(event_type, event_content, data)
    end

    def handle_event({:call, from}, _event_content, data) do
        {:keep_state_and_data, [{:reply, from, data}]}
    end

    def handle_event(_event_type, _event_content, _data) do
        {:keep_state_and_data, []}
    end

    def generate_time_out, do: :rand.uniform(500)*10+5000

    def send_requests(data) do
        [{last_index, last_term, _} | _rest] = data.log
        me = data.me
        for server <- data.servers do
            case server do
                ^me -> :ok
                _ -> GenStateMachine.cast(server, {:request_vote, %Graft.RequestVoteRPC{
                        term: data.current_term,
                        candidate_pid: data.me,
                        last_log_index: last_index,
                        last_log_term: last_term
                    }})
            end
        end
    end

    def send_append_entries(rpc, servers, me) do
        for server <- servers do
            case server do
                ^me -> :ok
                _ -> GenStateMachine.cast(server, rpc)
            end
        end
    end
end
