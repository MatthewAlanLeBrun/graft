defmodule Graft.ServerTest do
  use ExUnit.Case, async: true

  test "applies entries when commit_index > last_applied" do
    leader = self()
    {:ok, machine} = Graft.Machine.register(MyTestMachine)

    rpc = %Graft.AppendEntriesRPC{
      term: 1,
      leader_name: leader,
      prev_log_index: 1,
      prev_log_term: 1,
      entries: [],
      leader_commit: 1
    }

    state = %Graft.State{
      me: {:test_server, :nonode@nohost},
      current_term: 1,
      log: [{1, 1, {leader, "Entry applied"}}, {0, 0, nil}],
      commit_index: 1,
      last_applied: 0,
      machine: machine
    }

    {_, new_data, _} = Graft.Server.follower(:cast, rpc, state)

    assert new_data == %Graft.State{
             me: {:test_server, :nonode@nohost},
             current_term: 1,
             log: [{1, 1, {leader, "Entry applied"}}, {0, 0, nil}],
             commit_index: 1,
             last_applied: 1,
             machine: machine
           }

    assert_receive {:test_machine, "Entry applied"}
  end

  test "updates term and demotes when term > current_term" do
    server = self()

    ae = %Graft.AppendEntriesRPC{term: 10}
    ae_reply = %Graft.AppendEntriesRPCReply{term: 10}
    rv = %Graft.RequestVoteRPC{term: 10}
    rv_reply = %Graft.RequestVoteRPCReply{term: 10}

    state = %Graft.State{
      me: {:test_server, :nonode@nohost},
      current_term: 1,
      leader: server
    }

    # Follower remains follower
    {:next_state, :follower, new_data_ae, _} = Graft.Server.follower(:cast, ae, state)
    {:next_state, :follower, new_data_ae_reply, _} = Graft.Server.follower(:cast, ae_reply, state)
    {:next_state, :follower, new_data_rv, _} = Graft.Server.follower(:cast, rv, state)
    {:next_state, :follower, new_data_rv_reply, _} = Graft.Server.follower(:cast, rv_reply, state)

    assert ^new_data_ae =
             ^new_data_ae_reply =
             ^new_data_rv =
             ^new_data_rv_reply = %Graft.State{
               me: {:test_server, :nonode@nohost},
               current_term: 10,
               leader: server
             }

    # Candidate demotes
    {:next_state, :follower, new_data_ae, _} = Graft.Server.candidate(:cast, ae, state)

    {:next_state, :follower, new_data_ae_reply, _} =
      Graft.Server.candidate(:cast, ae_reply, state)

    {:next_state, :follower, new_data_rv, _} = Graft.Server.candidate(:cast, rv, state)

    {:next_state, :follower, new_data_rv_reply, _} =
      Graft.Server.candidate(:cast, rv_reply, state)

    assert ^new_data_ae =
             ^new_data_ae_reply =
             ^new_data_rv =
             ^new_data_rv_reply = %Graft.State{
               me: {:test_server, :nonode@nohost},
               current_term: 10,
               leader: server
             }

    # Leader demotes
    {:next_state, :follower, new_data_ae, _} = Graft.Server.candidate(:cast, ae, state)

    {:next_state, :follower, new_data_ae_reply, _} =
      Graft.Server.candidate(:cast, ae_reply, state)

    {:next_state, :follower, new_data_rv, _} = Graft.Server.candidate(:cast, rv, state)

    {:next_state, :follower, new_data_rv_reply, _} =
      Graft.Server.candidate(:cast, rv_reply, state)

    assert ^new_data_ae =
             ^new_data_ae_reply =
             ^new_data_rv =
             ^new_data_rv_reply = %Graft.State{
               me: {:test_server, :nonode@nohost},
               current_term: 10,
               leader: server
             }
  end

  test "candidate updates state on conversion" do
    server = self()
    servers = [server]

    state = %Graft.State{
      me: {:test_server, :nonode@nohost},
      current_term: 0,
      voted_for: nil,
      servers: servers,
      votes: 0
    }

    {:keep_state, new_data, events} = Graft.Server.candidate(:cast, :request_votes, state)

    assert new_data == %Graft.State{
             me: {:test_server, :nonode@nohost},
             current_term: 1,
             voted_for: {:test_server, :nonode@nohost},
             servers: servers,
             votes: 1
           }

    assert [{{:timeout, :election_timeout}, _, :begin_election} | _] = events

    assert_receive {_,
                    %Graft.RequestVoteRPC{
                      term: 1,
                      candidate_name: {:test_server, :nonode@nohost},
                      last_log_index: 0,
                      last_log_term: 0
                    }}
  end

  test "candidate promotes to leader with majority votes" do
    server = self()
    servers = [server]

    rpc = %Graft.RequestVoteRPCReply{
      term: 1,
      vote_granted: true
    }

    state = %Graft.State{
      me: {:test_server, :nonode@nohost},
      current_term: 1,
      voted_for: {:test_server, :nonode@nohost},
      servers: servers,
      server_count: 2,
      votes: 1
    }

    assert {:next_state, :leader, new_data, _} = Graft.Server.candidate(:cast, rpc, state)

    assert new_data == %Graft.State{
             me: {:test_server, :nonode@nohost},
             current_term: 1,
             voted_for: {:test_server, :nonode@nohost},
             servers: servers,
             server_count: 2,
             votes: 2
           }
  end

  test "candidate doesn't recount the same votes" do
    server = self()
    servers = [server]

    rpc = %Graft.RequestVoteRPCReply{
      term: 1,
      vote_granted: true
    }

    state = %Graft.State{
      me: {:test_server, :nonode@nohost},
      current_term: 1,
      voted_for: nil,
      servers: servers,
      server_count: 2,
      votes: 0
    }

    Graft.Server.candidate(:cast, rpc, state)
    {_, new_data, _} = Graft.Server.candidate(:cast, rpc, state)

    assert new_data == %Graft.State{
             me: {:test_server, :nonode@nohost},
             current_term: 1,
             servers: servers,
             server_count: 2,
             votes: 1
           }
  end

  test "candidate demotes when it receives AE RPC from new leader" do
    leader = self()

    rpc = %Graft.AppendEntriesRPC{
      term: 1,
      leader_name: leader,
      prev_log_index: 0,
      prev_log_term: 0,
      entries: [],
      leader_commit: 0
    }

    state = %Graft.State{
      me: {:test_server, :nonode@nohost},
      voted_for: {:test_server, :nonode@nohost},
      votes: 1
    }

    assert {:next_state, :follower, _, _} = Graft.Server.candidate(:cast, rpc, state)
  end

  test "leader receiving client requests appends to local log" do
    client = self()

    state = %Graft.State{
      me: {:test_server, :nonode@nohost},
      current_term: 1,
      log: [{0, 0, nil}]
    }

    {:keep_state, new_data, _} = Graft.Server.leader({:call, client}, {:entry, :ok}, state)

    assert new_data == %Graft.State{
             me: {:test_server, :nonode@nohost},
             current_term: 1,
             log: [{1, 1, :ok}, {0, 0, nil}],
             requests: %{1 => client}
           }
  end
end
