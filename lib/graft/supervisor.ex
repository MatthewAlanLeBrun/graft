defmodule Graft.Supervisor do
    @moduledoc false
    use Supervisor

    def start_link() do
        Supervisor.start_link __MODULE__, cluster_config(), name: __MODULE__
    end

    # def start_link(servers, machine_module, machine_args) do
    #     Supervisor.start_link(__MODULE__, [servers, machine_module, machine_args], name: __MODULE__)
    # end
    
    # def start_link(servers, states, machine_module, machine_args) do
    #     Supervisor.start_link(__MODULE__, [servers, states, machine_module, machine_args])
    # end

    def init([{my_servers, all_servers}, machine_module, machine_args]) do
        IO.inspect my_servers, label: "This node's servers"
        children = for {name, _node} <- my_servers do
            worker(Graft.Server, [name, all_servers, machine_module, machine_args], restart: :transient, id: name)
        end
        supervise(children, strategy: :one_for_one)
    end

    # def init([servers, states, machine_module, machine_args]) do
    #     children = for {server, state} <- Enum.zip(servers, states) do
    #         worker(Graft.Server, [server, servers, state, machine_module, machine_args], restart: :transient, id: server)
    #     end
    #     supervise(children, strategy: :one_for_one)
    # end

    defp cluster_config() do
        [
            Application.fetch_env!(:graft, :cluster) |> on_my_node(),
            Application.fetch_env!(:graft, :machine),
            Application.fetch_env!(:graft, :machine_args)
        ]
    end

    defp on_my_node(servers) do
        {(servers |> Enum.group_by(fn {_, node} -> node end))[node()], servers}
    end
end
