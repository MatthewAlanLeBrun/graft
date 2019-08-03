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
