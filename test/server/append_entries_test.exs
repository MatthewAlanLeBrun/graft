defmodule Graft.AppendEntiresTest do
  use ExUnit.Case, async: true

  test "follower replies false if term < current_term" do
    leader = self()

    rpc = %Graft.AppendEntriesRPC{
      term: 1,
      leader_name: leader
    }

    state = %Graft.State{
      me: {:test_server, :nonode@nohost},
      current_term: 2,
      leader: leader
    }

    Graft.Server.follower(:cast, rpc, state)

    assert_receive {_,
                    %Graft.AppendEntriesRPCReply{
                      term: 2,
                      success: false,
                      last_log_index: _,
                      last_log_term: _,
                      from: {:test_server, :nonode@nohost}
                    }}
  end

  test "follower replies false if log doesn't contain an entry at prev_log_index whose term matches prev_log_term" do
    leader = self()

    rpc = %Graft.AppendEntriesRPC{
      term: 5,
      leader_name: leader,
      prev_log_index: 2,
      prev_log_term: 4
    }

    state = %Graft.State{
      me: {:test_server, :nonode@nohost},
      current_term: 5,
      log: [{2, 3, :ok}, {1, 3, :ok}, {0, 0, nil}],
      leader: leader
    }

    Graft.Server.follower(:cast, rpc, state)

    assert_receive {_,
                    %Graft.AppendEntriesRPCReply{
                      term: 5,
                      success: false,
                      last_log_index: _,
                      last_log_term: _,
                      from: {:test_server, :nonode@nohost}
                    }}
  end

  test "follower appends new entries not already in log" do
    leader = self()

    rpc = %Graft.AppendEntriesRPC{
      term: 1,
      leader_name: leader,
      prev_log_index: 0,
      prev_log_term: 0,
      entries: [{1, :ok}]
    }

    state = %Graft.State{
      me: {:test_server, :nonode@nohost},
      current_term: 1,
      log: [{0, 0, nil}],
      leader: leader
    }

    {:keep_state, new_data, _} = Graft.Server.follower(:cast, rpc, state)

    assert new_data == %Graft.State{
             me: {:test_server, :nonode@nohost},
             current_term: 1,
             log: [{1, 1, :ok}, {0, 0, nil}],
             leader: leader
           }

    assert_receive {_,
                    %Graft.AppendEntriesRPCReply{
                      term: 1,
                      success: true,
                      last_log_index: 1,
                      last_log_term: 1,
                      from: {:test_server, :nonode@nohost}
                    }}
  end

  test "follower deletes conflicting new entries and appends new" do
    leader = self()

    rpc = %Graft.AppendEntriesRPC{
      term: 2,
      leader_name: leader,
      prev_log_index: 0,
      prev_log_term: 0,
      entries: [{2, :ok}]
    }

    state = %Graft.State{
      me: {:test_server, :nonode@nohost},
      current_term: 2,
      log: [{1, 1, :noop}, {0, 0, nil}],
      leader: leader
    }

    {:keep_state, new_data, _} = Graft.Server.follower(:cast, rpc, state)

    assert new_data == %Graft.State{
             me: {:test_server, :nonode@nohost},
             current_term: 2,
             log: [{1, 2, :ok}, {0, 0, nil}],
             leader: leader
           }

    assert_receive {_,
                    %Graft.AppendEntriesRPCReply{
                      term: 2,
                      success: true,
                      last_log_index: 1,
                      last_log_term: 2,
                      from: {:test_server, :nonode@nohost}
                    }}
  end

  test "follower doesn't re-append new entries already in log" do
    leader = self()

    rpc = %Graft.AppendEntriesRPC{
      term: 1,
      leader_name: leader,
      prev_log_index: 0,
      prev_log_term: 0,
      entries: [{1, :ok}]
    }

    state = %Graft.State{
      me: {:test_server, :nonode@nohost},
      current_term: 1,
      log: [{1, 1, :ok}, {0, 0, nil}],
      leader: leader
    }

    {:keep_state, new_data, _} = Graft.Server.follower(:cast, rpc, state)

    assert new_data == %Graft.State{
             me: {:test_server, :nonode@nohost},
             current_term: 1,
             log: [{1, 1, :ok}, {0, 0, nil}],
             leader: leader
           }

    assert_receive {_,
                    %Graft.AppendEntriesRPCReply{
                      term: 1,
                      success: true,
                      last_log_index: 1,
                      last_log_term: 1,
                      from: {:test_server, :nonode@nohost}
                    }}
  end

  test "follower updates commit_index when leader_commit > commit_index" do
    leader = self()

    rpc = %Graft.AppendEntriesRPC{
      term: 1,
      leader_name: leader,
      prev_log_index: 0,
      prev_log_term: 0,
      entries: [{1, :ok}],
      leader_commit: 1
    }

    state = %Graft.State{
      me: {:test_server, :nonode@nohost},
      current_term: 1,
      log: [{0, 0, nil}],
      leader: leader
    }

    {:keep_state, new_data, _} = Graft.Server.follower(:cast, rpc, state)

    assert new_data == %Graft.State{
             me: {:test_server, :nonode@nohost},
             current_term: 1,
             log: [{1, 1, :ok}, {0, 0, nil}],
             leader: leader,
             commit_index: 1
           }

    assert_receive {_,
                    %Graft.AppendEntriesRPCReply{
                      term: 1,
                      success: true,
                      last_log_index: 1,
                      last_log_term: 1,
                      from: {:test_server, :nonode@nohost}
                    }}
  end

  test "follower updates commit_index when leader_commit > commit_index but log is recovering" do
    leader = self()

    rpc = %Graft.AppendEntriesRPC{
      term: 2,
      leader_name: leader,
      prev_log_index: 0,
      prev_log_term: 0,
      entries: [{2, :ok}],
      leader_commit: 2
    }

    state = %Graft.State{
      me: {:test_server, :nonode@nohost},
      current_term: 2,
      log: [{0, 0, nil}],
      leader: leader
    }

    {:keep_state, new_data, _} = Graft.Server.follower(:cast, rpc, state)

    assert new_data == %Graft.State{
             me: {:test_server, :nonode@nohost},
             current_term: 2,
             log: [{1, 2, :ok}, {0, 0, nil}],
             leader: leader,
             commit_index: 1
           }

    assert_receive {_,
                    %Graft.AppendEntriesRPCReply{
                      term: 2,
                      success: true,
                      last_log_index: 1,
                      last_log_term: 2,
                      from: {:test_server, :nonode@nohost}
                    }}
  end
end
