defmodule Graft.State.Server.General do
    defstruct time_out: 0,          # random time out of server
              state: :follower      # current state of the server
end

defmodule Graft.State.Server.Persistent do
    defstruct current_term: 0,      # latest term server has seen
              voted_for: nil,       # candidate_pid that received vote in current term (or null if none)
              log: []               # log entries; each entry contains command for state machine, and term when entry was received by leader
end

defmodule Graft.State.Server.Volatile do
    defstruct commit_index: 0,      # index of highest log entry known to be committed
              last_applied: 0       # index of highest log entry applied to state machine
end

defmodule Graft.State.Leader.Volatile do
    defstruct next_index: [],       # for each server, index of the next log entry to send to that server
              match_index: []       # for each server, index of highest log entry known to be replicated on server
end

defmodule Graft.State.Cluster do
    defstruct server_count: 0,      # number of servers in the cluster
              server_pids: []       # pids of each server in the cluster
end

defmodule Graft.State do
    def create_state(:general, time_out_ms), do: spawn_link(fn -> state(%Graft.State.Server.General{time_out: time_out_ms}) end)

    defp state(%Graft.State.Server.General{} = state) do
        receive do
            {:get, :time_out, server} ->
                send server, state.time_out
                state(state)
            {:get, :state, server} ->
                send server, state.state
                state(state)
            {:put, :state, new_state} ->
                state(%Graft.State.Server.General{state | state: new_state})
        end
    end

    defp state(%Graft.State.Server.Persistent{} = state) do
        receive do
            {:get, :current_term, server} ->
                send server, state.current_term
                state(state)
            {:get, :voted_for, server} ->
                send server, state.voted_for
                state(state)
        end
    end
end
