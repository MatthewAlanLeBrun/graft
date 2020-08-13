-module(local_mon).
-author("detectEr").
-generated("2020/ 8/12 08:09:33").
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
            fun(_E =
                    {trace, _Node, spawn, _Machine,
                     {proc_lib, init_p,
                      [_ServerID, _, _, _,
                       [_, _, _, 'Elixir.Graft.Machine', _, _]]}}) ->
                   io:format("\e[37m*** [~w] Analyzing event ~p.~n\e[0m",
                             [self(), _E]),
                   fun(_E =
                           {trace, _Machine, spawned, _Node,
                            {proc_lib, init_p,
                             [_ServerID, _, _, _,
                              [_, _, _, 'Elixir.Graft.Machine', _, _]]}}) ->
                          io:format("\e[37m*** [~w] Analyzing event ~p."
                                    "~n\e[0m",
                                    [self(), _E]),
                          fun(_E =
                                  {trace, _Node, 'receive',
                                   {ack, _, {ok, _}}}) ->
                                 io:format("\e[37m*** [~w] Analyzing ev"
                                           "ent ~p.~n\e[0m",
                                           [self(), _E]),
                                 fun(_E =
                                         {trace, _Node, 'receive',
                                          {_, start}}) ->
                                        io:format("\e[37m*** [~w] Analy"
                                                  "zing event ~p.~n\e[0"
                                                  "m",
                                                  [self(), _E]),
                                        fun(_E =
                                                {trace, _Node,
                                                 'receive',
                                                 {timeout, _,
                                                  {timeout,
                                                   election_timeout}}}) ->
                                               io:format("\e[37m*** [~w"
                                                         "] Analyzing e"
                                                         "vent ~p.~n\e["
                                                         "0m",
                                                         [self(), _E]),
                                               fun X() ->
                                                       fun(_E =
                                                               {trace,
                                                                _Node,
                                                                'receive',
                                                                _}) ->
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
                                                                  X()
                                                              end;
                                                          (_E =
                                                               {trace,
                                                                _Node,
                                                                send, _,
                                                                _}) ->
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
                                                                  X()
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
                                               end();
                                           (_E =
                                                {trace, _Node,
                                                 'receive',
                                                 {'$gen_cast', #{'__struct__' := 'Elixir.Graft.RequestVoteRPC'}}}) -> %EDIT
                                               io:format("\e[37m*** [~w"
                                                         "] Analyzing e"
                                                         "vent ~p.~n\e["
                                                         "0m",
                                                         [self(), _E]),
                                               fun Y() ->
                                                       fun(_E =
                                                               {trace,
                                                                _Node,
                                                                'receive',
                                                                _}) ->
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
                                                                             'Y']),
                                                                  Y()
                                                              end;
                                                          (_E =
                                                               {trace,
                                                                _Node,
                                                                send, _,
                                                                _}) ->
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
                                                                             'Y']),
                                                                  Y()
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
                                               end();
                                           (_E) ->
                                               begin
                                                   io:format("\e[1m\e[3"
                                                             "3m*** [~w"
                                                             "] Reached"
                                                             " verdict "
                                                             "'end' on "
                                                             "event ~p."
                                                             "~n\e[0m",
                                                             [self(),
                                                              _E]),
                                                   'end'
                                               end
                                        end;
                                    (_E) ->
                                        begin
                                            io:format("\e[1m\e[33m*** ["
                                                      "~w] Reached verd"
                                                      "ict 'end' on eve"
                                                      "nt ~p.~n\e[0m",
                                                      [self(), _E]),
                                            'end'
                                        end
                                 end;
                             (_E) ->
                                 begin
                                     io:format("\e[1m\e[33m*** [~w] Rea"
                                               "ched verdict 'end' on e"
                                               "vent ~p.~n\e[0m",
                                               [self(), _E]),
                                     'end'
                                 end
                          end;
                      (_E) ->
                          begin
                              io:format("\e[1m\e[33m*** [~w] Reached ve"
                                        "rdict 'end' on event ~p.~n\e[0"
                                        "m",
                                        [self(), _E]),
                              'end'
                          end
                   end;
               (_E) ->
                   begin
                       io:format("\e[1m\e[33m*** [~w] Reached verdict '"
                                 "end' on event ~p.~n\e[0m",
                                 [self(), _E]),
                       'end'
                   end
            end;
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
