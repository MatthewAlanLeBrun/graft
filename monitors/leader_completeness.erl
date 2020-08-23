-module(leader_completeness).
-author("detectEr").
-generated("2020/ 8/23 14:27:06").
-export([mfa_spec/1]).
mfa_spec({proc_lib, init_p,
          [_, _, _, _, [_, _, _, {local, Supervisor}, _, _, _]]})
    when Supervisor =:= 'Elixir.Graft.Supervisor' ->
    {ok,
     fun(_E =
             {trace, _SupervisorPid, spawned, _LauncherPid,
              {proc_lib, init_p, [_, _, _, _, _]}}) ->
            io:format("\e[37m*** [~w] Analyzing event ~p.~n\e[0m",
                      [self(), _E]),
            fun INIT_LOOP() ->
                    fun(_E =
                            {trace, _P, spawn, _C,
                             {proc_lib, init_p, [_, _, _, _, _]}}) ->
                           io:format("\e[37m*** [~w] Analyzing event ~p"
                                     ".~n\e[0m",
                                     [self(), _E]),
                           begin
                               io:format("\e[36m*** [~w] Unfolding rec."
                                         " var. ~p.~n\e[0m",
                                         [self(), 'INIT_LOOP']),
                               INIT_LOOP()
                           end;
                       (_E =
                            {trace, _C, spawned, _P,
                             {proc_lib, init_p, [_, _, _, _, _]}}) ->
                           io:format("\e[37m*** [~w] Analyzing event ~p"
                                     ".~n\e[0m",
                                     [self(), _E]),
                           begin
                               io:format("\e[36m*** [~w] Unfolding rec."
                                         " var. ~p.~n\e[0m",
                                         [self(), 'INIT_LOOP']),
                               INIT_LOOP()
                           end;
                       (_E =
                            {trace, _Server, 'receive',
                             {ack, _, {ok, _}}}) ->
                           io:format("\e[37m*** [~w] Analyzing event ~p"
                                     ".~n\e[0m",
                                     [self(), _E]),
                           begin
                               io:format("\e[36m*** [~w] Unfolding rec."
                                         " var. ~p.~n\e[0m",
                                         [self(), 'INIT_LOOP']),
                               INIT_LOOP()
                           end;
                       (_E = {trace, _Server, 'receive', {_, start}}) ->
                           io:format("\e[37m*** [~w] Analyzing event ~p"
                                     ".~n\e[0m",
                                     [self(), _E]),
                           fun START(CommittedLog) ->
                                   fun(_E =
                                           {trace, Leader, send,
                                            {_, #{'__struct__' := 'Elixir.Graft.AppendEntriesRPC'}},
                                            _}) ->
                                          io:format("\e[37m*** [~w] Ana"
                                                    "lyzing event ~p.~n"
                                                    "\e[0m",
                                                    [self(), _E]),
                                          LeaderComplete = leader_complete(Leader, CommittedLog),
                                          if LeaderComplete ->
                                            fun X(CommittedLog) ->
                                                    fun(_E =
                                                            {trace,
                                                            Server, exit,
                                                            _})
                                                            when
                                                                Server
                                                                =:=
                                                                Leader ->
                                                            io:format("\e[37m"
                                                                    "*** ["
                                                                    "~w] A"
                                                                    "nalyz"
                                                                    "ing e"
                                                                    "vent "
                                                                    "~p.~n"
                                                                    "\e[0m",
                                                                    [self(),
                                                                        _E]),
                                                            begin
                                                                io:format("\e[36m"
                                                                        "*** ["
                                                                        "~w] U"
                                                                        "nfold"
                                                                        "ing r"
                                                                        "ec. v"
                                                                        "ar. ~"
                                                                        "p.~n\e"
                                                                        "[0m",
                                                                        [self(),
                                                                            'START']),
                                                                START(CommittedLog)
                                                            end;
                                                        (_E =
                                                            {trace, _P,
                                                            spawn, _C,
                                                            {proc_lib,
                                                                init_p,
                                                                [_, _, _, _,
                                                                _]}}) ->
                                                            io:format("\e[37m"
                                                                    "*** ["
                                                                    "~w] A"
                                                                    "nalyz"
                                                                    "ing e"
                                                                    "vent "
                                                                    "~p.~n"
                                                                    "\e[0m",
                                                                    [self(),
                                                                        _E]),
                                                            begin
                                                                io:format("\e[36m"
                                                                        "*** ["
                                                                        "~w] U"
                                                                        "nfold"
                                                                        "ing r"
                                                                        "ec. v"
                                                                        "ar. ~"
                                                                        "p.~n\e"
                                                                        "[0m",
                                                                        [self(),
                                                                            'X']),
                                                                X(CommittedLog)
                                                            end;
                                                        (_E =
                                                            {trace, _C,
                                                            spawned, _P,
                                                            {proc_lib,
                                                                init_p,
                                                                [_, _, _, _,
                                                                _]}}) ->
                                                            io:format("\e[37m"
                                                                    "*** ["
                                                                    "~w] A"
                                                                    "nalyz"
                                                                    "ing e"
                                                                    "vent "
                                                                    "~p.~n"
                                                                    "\e[0m",
                                                                    [self(),
                                                                        _E]),
                                                            begin
                                                                io:format("\e[36m"
                                                                        "*** ["
                                                                        "~w] U"
                                                                        "nfold"
                                                                        "ing r"
                                                                        "ec. v"
                                                                        "ar. ~"
                                                                        "p.~n\e"
                                                                        "[0m",
                                                                        [self(),
                                                                            'X']),
                                                                X(CommittedLog)
                                                            end;
                                                        (_E =
                                                            {trace,
                                                            Server,
                                                            send, {_, #{'__struct__':='Elixir.Graft.AppendEntriesRPC', leader_commit := Idx}}, _}) ->
                                                            NewCommittedLog = get_committed_log(Server, Idx),
                                                            io:format("\e[37m"
                                                                    "*** ["
                                                                    "~w] A"
                                                                    "nalyz"
                                                                    "ing e"
                                                                    "vent "
                                                                    "~p.~n"
                                                                    "\e[0m",
                                                                    [self(),
                                                                        _E]),
                                                            begin
                                                                io:format("\e[36m"
                                                                        "*** ["
                                                                        "~w] U"
                                                                        "nfold"
                                                                        "ing r"
                                                                        "ec. v"
                                                                        "ar. ~"
                                                                        "p.~n\e"
                                                                        "[0m",
                                                                        [self(),
                                                                            'X']),
                                                                X(NewCommittedLog)
                                                            end;
                                                        (_E =
                                                            {trace,
                                                            _Server,
                                                            send, _, _}) ->
                                                            io:format("\e[37m"
                                                                    "*** ["
                                                                    "~w] A"
                                                                    "nalyz"
                                                                    "ing e"
                                                                    "vent "
                                                                    "~p.~n"
                                                                    "\e[0m",
                                                                    [self(),
                                                                        _E]),
                                                            begin
                                                                io:format("\e[36m"
                                                                        "*** ["
                                                                        "~w] U"
                                                                        "nfold"
                                                                        "ing r"
                                                                        "ec. v"
                                                                        "ar. ~"
                                                                        "p.~n\e"
                                                                        "[0m",
                                                                        [self(),
                                                                            'X']),
                                                                X(CommittedLog)
                                                            end;
                                                        (_E =
                                                            {trace,
                                                            _Server,
                                                            'receive', _}) ->
                                                            io:format("\e[37m"
                                                                    "*** ["
                                                                    "~w] A"
                                                                    "nalyz"
                                                                    "ing e"
                                                                    "vent "
                                                                    "~p.~n"
                                                                    "\e[0m",
                                                                    [self(),
                                                                        _E]),
                                                            begin
                                                                io:format("\e[36m"
                                                                        "*** ["
                                                                        "~w] U"
                                                                        "nfold"
                                                                        "ing r"
                                                                        "ec. v"
                                                                        "ar. ~"
                                                                        "p.~n\e"
                                                                        "[0m",
                                                                        [self(),
                                                                            'X']),
                                                                X(CommittedLog)
                                                            end;
                                                        (_E =
                                                            {trace,
                                                            _Server,
                                                            exit, _}) ->
                                                            io:format("\e[37m"
                                                                    "*** ["
                                                                    "~w] A"
                                                                    "nalyz"
                                                                    "ing e"
                                                                    "vent "
                                                                    "~p.~n"
                                                                    "\e[0m",
                                                                    [self(),
                                                                        _E]),
                                                            begin
                                                                io:format("\e[36m"
                                                                        "*** ["
                                                                        "~w] U"
                                                                        "nfold"
                                                                        "ing r"
                                                                        "ec. v"
                                                                        "ar. ~"
                                                                        "p.~n\e"
                                                                        "[0m",
                                                                        [self(),
                                                                            'X']),
                                                                X(CommittedLog)
                                                            end;
                                                        (_E) ->
                                                            begin
                                                                io:format("\e[1m\e"
                                                                        "[33m*"
                                                                        "** [~"
                                                                        "w] Re"
                                                                        "ached"
                                                                        " verd"
                                                                        "ict '"
                                                                        "end' "
                                                                        "on ev"
                                                                        "ent ~"
                                                                        "p.~n\e"
                                                                        "[0m",
                                                                        [self(),
                                                                            _E]),
                                                                'end'
                                                            end
                                                    end
                                            end(CommittedLog);
                                          true ->
                                              io:format("\e[1m\e[31m***"
                                                        " [~w] Reached "
                                                        "verdict 'no'. Leader Completeness property compromised!~"
                                                        "n\e[0m",
                                                        [self()]),
                                              no
                                          end;
                                      (_E =
                                           {trace, _P, spawn, _C,
                                            {proc_lib, init_p,
                                             [_, _, _, _, _]}}) ->
                                          io:format("\e[37m*** [~w] Ana"
                                                    "lyzing event ~p.~n"
                                                    "\e[0m",
                                                    [self(), _E]),
                                          begin
                                              io:format("\e[36m*** [~w]"
                                                        " Unfolding rec"
                                                        ". var. ~p.~n\e"
                                                        "[0m",
                                                        [self(),
                                                         'START']),
                                              START(CommittedLog)
                                          end;
                                      (_E =
                                           {trace, _C, spawned, _P,
                                            {proc_lib, init_p,
                                             [_, _, _, _, _]}}) ->
                                          io:format("\e[37m*** [~w] Ana"
                                                    "lyzing event ~p.~n"
                                                    "\e[0m",
                                                    [self(), _E]),
                                          begin
                                              io:format("\e[36m*** [~w]"
                                                        " Unfolding rec"
                                                        ". var. ~p.~n\e"
                                                        "[0m",
                                                        [self(),
                                                         'START']),
                                              START(CommittedLog)
                                          end;
                                      (_E =
                                           {trace, _Server, 'receive',
                                            _}) ->
                                          io:format("\e[37m*** [~w] Ana"
                                                    "lyzing event ~p.~n"
                                                    "\e[0m",
                                                    [self(), _E]),
                                          begin
                                              io:format("\e[36m*** [~w]"
                                                        " Unfolding rec"
                                                        ". var. ~p.~n\e"
                                                        "[0m",
                                                        [self(),
                                                         'START']),
                                              START(CommittedLog)
                                          end;
                                      (_E = {trace, _Server, send, _, _}) ->
                                          io:format("\e[37m*** [~w] Ana"
                                                    "lyzing event ~p.~n"
                                                    "\e[0m",
                                                    [self(), _E]),
                                          begin
                                              io:format("\e[36m*** [~w]"
                                                        " Unfolding rec"
                                                        ". var. ~p.~n\e"
                                                        "[0m",
                                                        [self(),
                                                         'START']),
                                              START(CommittedLog)
                                          end;
                                      (_E = {trace, _Server, exit, _}) ->
                                          io:format("\e[37m*** [~w] Ana"
                                                    "lyzing event ~p.~n"
                                                    "\e[0m",
                                                    [self(), _E]),
                                          begin
                                              io:format("\e[36m*** [~w]"
                                                        " Unfolding rec"
                                                        ". var. ~p.~n\e"
                                                        "[0m",
                                                        [self(),
                                                         'START']),
                                              START(CommittedLog)
                                          end;
                                      (_E) ->
                                          begin
                                              io:format("\e[1m\e[33m***"
                                                        " [~w] Reached "
                                                        "verdict 'end' "
                                                        "on event ~p.~n"
                                                        "\e[0m",
                                                        [self(), _E]),
                                              'end'
                                          end
                                   end
                           end([{0,0,nil}]);
                       (_E) ->
                           begin
                               io:format("\e[1m\e[33m*** [~w] Reached v"
                                         "erdict 'end' on event ~p.~n\e"
                                         "[0m",
                                         [self(), _E]),
                               'end'
                           end
                    end
            end();
        (_E) ->
            begin
                io:format("\e[1m\e[33m*** [~w] Reached verdict 'end' on"
                          " event ~p.~n\e[0m",
                          [self(), _E]),
                'end'
            end
     end};
mfa_spec(_Mfa) ->
    io:format("\e[1m\e[31m*** [~w] Did not match MFA pattern '~p'.~n\e["
              "0m",
              [self(), _Mfa]),
    undefined.

get_log(Server) -> {_, #{log:= Log}} = sys:get_state(Server), Log.

leader_complete([], _CommittedLog) -> false;
leader_complete(Log=[_LogHead | _LogTail], CommittedLog) when CommittedLog =:= Log -> true;
leader_complete([_LogHead | LogTail], CommittedLog) -> leader_complete(LogTail, CommittedLog);
leader_complete(Leader, CommittedLog) ->
    LeaderLog = get_log(Leader),
    leader_complete(LeaderLog, CommittedLog).

get_committed_log(Log=[{I, _, _} | _Tail], Idx) when I =:= Idx -> Log;
get_committed_log([_Head | Tail], Idx) -> get_committed_log(Tail, Idx);
get_committed_log(Server, Idx) ->
    Log = get_log(Server),
    get_committed_log(Log, Idx).