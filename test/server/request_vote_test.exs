defmodule Graft.RequestVoteTest do
    use ExUnit.Case, async: true

    test "follower replies false when term < current_term" do
        candidate = self()

        rpc = %Graft.RequestVoteRPC{
            term: 1,
            candidate_name: candidate,
            last_log_index: 0,
            last_log_term: 0
        }

        state = %Graft.State{
            me: {:test_server, :nonode@nohost},
            current_term: 2
        }

        Graft.Server.follower :cast, rpc, state

        assert_receive {_, %Graft.RequestVoteRPCReply{
            term: 2,
            vote_granted: false
        }}
    end

    test "follower grants vote when voted_for is nil" do
        candidate = self()

        rpc = %Graft.RequestVoteRPC{
            term: 1,
            candidate_name: candidate,
            last_log_index: 0,
            last_log_term: 0
        }

        state = %Graft.State{
            me: {:test_server, :nonode@nohost},
            current_term: 1,
            voted_for: nil
        }

        Graft.Server.follower :cast, rpc, state

        assert_receive {_, %Graft.RequestVoteRPCReply{
            term: 1,
            vote_granted: true
        }}
    end

    test "follower grants vote when voted_for = candidate" do
        candidate = self()

        rpc = %Graft.RequestVoteRPC{
            term: 1,
            candidate_name: candidate,
            last_log_index: 0,
            last_log_term: 0
        }

        state = %Graft.State{
            me: {:test_server, :nonode@nohost},
            current_term: 1,
            voted_for: candidate
        }

        Graft.Server.follower :cast, rpc, state

        assert_receive {_, %Graft.RequestVoteRPCReply{
            term: 1,
            vote_granted: true
        }}
    end

    test "candidate's log is not as up to date as follower" do
        candidate = self()

        rpc = %Graft.RequestVoteRPC{
            term: 2,
            candidate_name: candidate,
            last_log_index: 0,
            last_log_term: 0
        }

        state = %Graft.State{
            me: {:test_server, :nonode@nohost},
            current_term: 2,
            voted_for: nil,
            log: [{1,1,:ok}, {0,0,nil}]
        }

        Graft.Server.follower :cast, rpc, state

        assert_receive {_, %Graft.RequestVoteRPCReply{
            term: 2,
            vote_granted: false
        }}
    end
end