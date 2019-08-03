defmodule Graft.Server do
    def start do
        spawn fn -> follower() end
    end

    def follower do
        receive do
            {:msg, msg} -> IO.puts(msg)
        after
            10_000 ->
                IO.puts("Timed out, beginning election") 
                candidate()
        end
        follower()
    end

    def candidate do

    end

    def leader do

    end
end
