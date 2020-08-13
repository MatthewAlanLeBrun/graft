-module(election_safety).
-author("detectEr").
-generated("2020/ 8/13 12:38:58").
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
                                           {trace, Leader, send,
                                            {_, #{'__struct__' := 'Elixir.Graft.AppendEntriesRPC',
                                                  term := Term}},
                                            _}) ->
                                          io:format("\e[37m*** [~w] Ana"
                                                    "lyzing event ~p.~n"
                                                    "\e[0m",
                                                    [self(), _E]),
                                          fun X(Leader, Term) ->
                                                  fun(_E =
                                                          {trace,
                                                           NewLeader,
                                                           send,
                                                           {_,
                                                            #{'__struct__' := 'Elixir.Graft.AppendEntriesRPC',
                                                  term := NewTerm}},
                                                           _})
                                                         when
                                                             Term
                                                             =:=
                                                             NewTerm,
                                                             Leader
                                                             =/=
                                                             NewLeader ->
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
                                                                       "no'. Election safety compromised!~"
                                                                       "n\e[0m",
                                                                       [self()]),
                                                             no
                                                         end;
                                                     (_E =
                                                          {trace,
                                                           NewLeader,
                                                           send,
                                                           {_,
                                                            #{'__struct__' := 'Elixir.Graft.AppendEntriesRPC',
                                                  term := NewTerm}},
                                                           _})
                                                         when
                                                             Term
                                                             <
                                                             NewTerm ->
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
                                                             X(NewLeader, NewTerm)
                                                         end;
                                                     (_E =
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
                                                             START()
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
                                                             X(Leader, Term)
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
                                                             X(Leader, Term)
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
                                                             X(Leader, Term)
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
                                                             X(Leader, Term)
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
                                                             X(Leader, Term)
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
                                          end(Leader, Term);
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
