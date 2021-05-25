defmodule Graft.State do
  @moduledoc false
            # name of the server process
  defstruct me: nil,
            # latest term server has seen
            current_term: 0,
            # candidate_pid that received vote in current term (or nil if none)
            voted_for: nil,
            # log entries; each entry contains command for state machine, and term when entry was received by leader
            log: [{0, 0, nil}],
            # index of highest log entry known to be committed
            commit_index: 0,
            # index of highest log entry applied to state machine
            last_applied: 0,
            # for each server, index of the next log entry to send to that server
            next_index: %{},
            # for each server, index of highest log entry known to be replicated on server
            match_index: %{},
            # for each server, an indication of whether that server has been sent an AE rpc and still has not replied
            ready: %{},
            # number of servers in the cluster
            server_count: 0,
            # names of each server in the cluster
            servers: [],
            # number of votes obtained
            votes: 0,
            # the id of the node believed to be the leader
            leader: nil,
            # the replicated state machine pid
            machine: nil,
            # for each request, the address of the client who requested it
            requests: %{}
end
