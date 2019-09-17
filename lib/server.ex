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

    def follower(:cast, :start, data) do
        {:keep_state_and_data, [{{:timeout, :election_timeout}, data.time_out, :begin_election}]}
    end

    def follower({:timeout, :election_timeout}, :begin_election, data) do
        {:next_state,
         :candidate,
         %Graft.State{data | state: :candidate, current_term: data.current_term+1, voted_for: data.me},
         [{:next_event, :cast, :request_votes}]}
    end

    def follower({:call, from}, :data, data) do
        {:keep_state_and_data, [{:reply, from, data}]}
    end

    def follower({:call, from}, {:request_vote, rpc = %Graft.RequestVoteRPC{}}, data) do
        current_term = data.current_term
        case rpc.term do
            term when term > current_term ->
                case data.voted_for do
                    nil -> {:keep_state,
                            %Graft.State{data | voted_for: rpc.candidate_pid},
                            [{:reply, from, %Graft.RequestVoteRPCReply{term: data.current_term, vote_granted: true}},
                             {:next_event, :cast, :start}]}
                    _ -> {:keep_state_and_data, [{:reply, from, %Graft.RequestVoteRPCReply{term: data.current_term}}]}
                end
            _ -> {:keep_state_and_data, [{:reply, from, %Graft.RequestVoteRPCReply{term: data.current_term}}]}
        end
    end

    def candidate(:cast, :request_votes, data) do
        send_requests(data)
        {:keep_state}
    end

    def candidate(event_type, event_content, data) do
        handle_event(event_type, event_content, data)
    end

    def leader(event_type, event_content, data) do
        handle_event(event_type, event_content, data)
    end

    def handle_event({:call, from}, _event_content, data) do
        {:keep_state_and_data, [{:reply, from, data}]}
    end

    def handle_event(_event_type, _event_content, _data) do
        IO.puts("Quando?")
        {:keep_state_and_data}
    end

    def generate_time_out, do: :rand.uniform(500)*10+5000

    def send_requests(data) do
        [{last_index, last_term, _} | _rest] = data.log
        me = data.me
        for server <- data.servers do
            case server do
                ^me -> :ok
                _ -> GenStateMachine.call(server, {:request_vote, %Graft.RequestVoteRPC{
                        term: data.current_term,
                        candidate_pid: data.me,
                        last_log_index: last_index,
                        last_log_term: last_term
                    }})
            end
        end
    end
end
