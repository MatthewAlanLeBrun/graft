defmodule Graft.AppendEntriesRPC do
    @moduledoc false
    defstruct term: -1,             # leader’s term
              leader_name: nil,     # so follower can redirect clients
              prev_log_index: -1,   # index of log entry immediately preceding new ones
              prev_log_term: -1,    # term of prevLogIndex entry
              entries: [],          # log entries to store (empty for heartbeat; may send more than one for efficiency)
              leader_commit: -1     # leader’s commit_index
end

defmodule Graft.AppendEntriesRPCReply do
    @moduledoc false
    defstruct term: -1,             # current_term, for leader to update itself
              success: false,       # true if follower contained entry matching prev_log_index and prev_log_term
              last_log_index: -1,   # index of last entry in follower's log
              last_log_term: -1     # term of last entry in follower's log
end

defmodule Graft.RequestVoteRPC do
    @moduledoc false
    defstruct term: -1,             # candidate’s term
              candidate_name: nil,  # candidate requesting vote
              last_log_index: -1,   # index of candidate’s last log entry
              last_log_term: -1     # term of candidate’s last log entry
end

defmodule Graft.RequestVoteRPCReply do
    @moduledoc false
    defstruct term: -1,             # current_term, for candidate to update itself
              vote_granted: false   # true means candidate received vote
end
