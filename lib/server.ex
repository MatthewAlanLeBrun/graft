defmodule Graft.Server do
    alias Graft.State, as: State

    def start do
        spawn fn -> init() end
    end

    def init() do
        Graft.StateFactory.new_state()
        State.update(:general, :time_out, generate_time_out())
        follower()
    end

    def follower do
        receive do
            {:msg, msg} ->
                IO.puts(msg)
                follower()
        after
            ms = State.get(:general, :time_out) ->
                IO.puts("Timed out #{ms}, beginning election")
                candidate()
        end
    end

    def candidate do

    end

    def leader do

    end

    def generate_time_out do :rand.uniform(500)*10+5000 end
end
