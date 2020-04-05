defmodule Graft.State do
    defstruct me: nil,              # name of the server process
              current_term: 0,      # latest term server has seen
              voted_for: nil,       # candidate_pid that received vote in current term (or nil if none)
              log: [{0, 0, nil}],   # log entries; each entry contains command for state machine, and term when entry was received by leader
              commit_index: 0,      # index of highest log entry known to be committed
              last_applied: 0,      # index of highest log entry applied to state machine
              next_index: [],       # for each server, index of the next log entry to send to that server
              match_index: [],      # for each server, index of highest log entry known to be replicated on server
              server_count: 0,      # number of servers in the cluster
              servers: [],          # names of each server in the cluster
              votes: 0,             # number of votes obtained
              leader: nil,          # the id of the node believed to be the leader
              client_data: %{}      # data structure being managed by client
end
