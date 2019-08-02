defmodule Graft.Server do
    def start do
        spawn fn -> follower() end
    end

    def follower do
        receive do
            {:msg, msg} -> IO.puts(msg)
        after
            1_000 -> IO.puts("Still a follower, want to move to candidate")
        end
        follower()
    end

    def candidate do

    end

    def leader do

    end
end
