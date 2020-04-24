defmodule GraftTest do
    use ExUnit.Case

    # AE refers to an append entries rpc
    # RV refers to a request votes rpc
    # 'up-to-date' has the same meaning as defined in https://raft.github.io/raft.pdf

    test "follower receives AE with outdated term" do

    end

    test "follower receives AE with a far ahead log" do

    end

    test "follower with matching log receives AE" do

    end

    test "follower with mismatching log receives AE" do

    end

    test "follower receives RV with outdated term" do

    end

    test "follower receives RV from candidate with a not as up-to-date log as the follower's" do

    end

    test "follower that already voted receives a RV rpc from a different candidate" do

    end

    test "follower that already voted receives a RV rpc from the same candidate" do

    end

    test "follower receives a valid RV rpc" do

    end

    test "candidate receives rpc with term > current term" do

    end

    test "leader receives rpc with term > current term" do

    end

    test "follower converts to candidate on timeout" do

    end

    test "servers just converted to candidates start election" do

    end

    test "candidate receives majority votes" do

    end

    test "candidate receives AE from new leader" do

    end

    test "candidate receives AE from old leader" do

    end

    test "candidate restarts new election on timeout" do

    end

    test "leader sends heartbeat on election" do

    end

    test "leader appends entry to local log when receiving client request" do

    end

    test "leader increments next index map for a server on a successful AE reply" do

    end

    test "leader decrements next index map for a server on a unsuccessful AE reply" do

    end

    test "leader updates commit index when majority of servers have a matching log" do

    end

    test "follower with a commit index larger than last applied index will apply the next entry in its log" do

    end

    test "candidate with a commit index larger than last applied index will apply the next entry in its log" do

    end

    test "leader with a commit index larger than last applied index will apply the next entry in its log" do

    end
end
