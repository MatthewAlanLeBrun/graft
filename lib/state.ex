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
    defstruct general:    %Graft.State.Server.General{},
              persistent: %Graft.State.Server.Persistent{},
              volatile:   %Graft.State.Server.Volatile{},
              leader:     nil

    def create_state do
        spawn_link(fn() -> state(%Graft.State{}) end);
    end

    defp state(%Graft.State{} = state) do
        receive do
            {:get, within, key, from} ->
                send from, Map.get(state, within) |> Map.get(key)
                state(state)
            {:put, into, struct_name, key, value} ->
                update = struct(struct_name, Map.get(state,into) |> Map.put(key, value))
                state(struct(Graft.State, Map.put(state, into, update)))
        end
    end
end
