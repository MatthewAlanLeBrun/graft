-module(log_matching).
-author("detectEr").
-generated("2020/ 8/17 17:13:39").
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
                           fun START() ->
                                   fun(_E =
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
                                              START()
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
                                              START()
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
                                              START()
                                          end;
                                      (_E = {trace, _Server, send, _, _}) ->
                                          io:format("\e[37m*** [~w] Ana"
                                                    "lyzing event ~p.~n"
                                                    "\e[0m",
                                                    [self(), _E]),
                                          Matching_Logs = check_logs(),
                                          if
                                            Matching_Logs ->
                                                begin
                                                    io:format("\e[36m*** [~w]"
                                                            " Unfolding rec"
                                                            ". var. ~p.~n\e"
                                                            "[0m",
                                                            [self(),
                                                            'START']),
                                                    START()
                                                end;
                                            true ->
                                                begin
                                                    io:format("\e[1m\e"
                                                            "[31m*"
                                                            "** [~"
                                                            "w] Re"
                                                            "ached"
                                                            " verd"
                                                            "ict '"
                                                            "no'. Log matching property compromised!~"
                                                            "n\e[0m",
                                                            [self()]),
                                                    no
                                                end
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
                                              START()
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
                           end();
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


extract_log(Server) ->
    {_, #{log := Log}} = sys:get_state(Server),
    Log.

check_logs() ->
    Log1 = extract_log(server1),
    Log2 = extract_log(server2),
    Log3 = extract_log(server3),

    check_logs(Log1, Log2) and check_logs(Log1, Log3) and check_logs(Log2, Log3).


check_logs(Log=[{I, _T, _E} | _Tail], [{LI, _, _} | LTail])
      when I < LI ->
    check_logs(Log, LTail);

check_logs([{I, _T, _E} | Tail], L=[{LI, _LT, _LE} | _LTail])
      when I > LI ->
    check_logs(Tail, L);

check_logs(Log=[{I, T, _E} | _Tail], [{LI, LT, _LE} | LTail])
      when I =:= LI, T =/= LT ->
    check_logs(Log, LTail);

check_logs(Log=[{I,T,_E} | _Tail], L=[{LI, LT, _LE} | _LTail])
      when I =:= LI, T =:= LT ->
    Log =:= L.
