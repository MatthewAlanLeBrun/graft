defmodule Graft.Client do
    def read(server, key) do
        # TODO: change back to call when fixed from server.ex
        case GenStateMachine.cast(server, {:entry, key}) do
            {:ok, value} -> {:ok, value}
            {:error, {:redirect, leader}} -> read(leader, key)
        end
    end

    def write(server, {key, value}) do
        case GenStateMachine.cast(server, {:entry, {key, value}}) do
            :ok -> :ok
            {:error, {:redirect, leader}} -> write(leader, {key, value})
        end
    end
end
