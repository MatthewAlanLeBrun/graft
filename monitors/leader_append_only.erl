-module(leader_append_only).
-author("detectEr").
-generated("2020/ 8/17 08:54:57").
-export([mfa_spec/1]).
mfa_spec({proc_lib, init_p,
          ['Elixir.Graft.Supervisor', _, _, _,
           [_, _, _, {local, _ServerID}, 'Elixir.Graft.Server', _, _]]}) ->
    {ok,
     fun(_E =
             {trace, _Node, spawned, _Supervisor,
              {proc_lib, init_p,
               ['Elixir.Graft.Supervisor', _, _, _,
                [_, _, _,
                 {local, _ServerID},
                 'Elixir.Graft.Server', _, _]]}}) ->
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
                                           {trace, Leader, send,
                                            {_, #{'__struct__' := 'Elixir.Graft.AppendEntriesRPC'}},
                                            _}) ->
                                          io:format("\e[37m*** [~w] Ana"
                                                    "lyzing event ~p.~n"
                                                    "\e[0m",
                                                    [self(), _E]),
                                          {_, #{log := LeaderLog}} = sys:get_state(Leader),
                                          fun X(LeaderLog) ->
                                                  {_, #{log := [NewHead | NewTail]}} = sys:get_state(Leader),
                                                  fun(_E = _) 
                                                        when LeaderLog =/= [NewHead | NewTail],
                                                             LeaderLog =/= NewTail ->
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
                                                             io:format("\e[1m\e"
                                                                       "[31m*"
                                                                       "** [~"
                                                                       "w] Re"
                                                                       "ached"
                                                                       " verd"
                                                                       "ict '"
                                                                       "no'. Leader append only compromised!~"
                                                                       "n\e[0m",
                                                                       [self()]),
                                                             no
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
                                                             X([NewHead | NewTail])
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
                                                             X([NewHead | NewTail])
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
                                                                        'START']),
                                                             START()
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
                                          end(LeaderLog);
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
                                          begin
                                              io:format("\e[36m*** [~w]"
                                                        " Unfolding rec"
                                                        ". var. ~p.~n\e"
                                                        "[0m",
                                                        [self(),
                                                         'START']),
                                              START()
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
