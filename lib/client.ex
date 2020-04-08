defmodule Graft.Client do
    def read(server, key) do
        case GenStateMachine.call(server, {:entry, key}) do
            {:ok, value} -> {:ok, value}
            {:error, {:redirect, leader}} -> read(leader, key)
        end
    end

    def write(server, {key, value}) do
        case GenStateMachine.call(server, {:entry, {key, value}}) do
            :ok -> :ok
            {:error, {:redirect, leader}} -> write(leader, {key, value})
        end
    end
end
