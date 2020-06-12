defmodule Graft.Supervisor do
    @moduledoc false
    use Supervisor

    def start_link(servers, machine_module, machine_args) do
        Supervisor.start_link(__MODULE__, [servers, machine_module, machine_args], name: __MODULE__)
    end
    
    def start_link(servers, states, machine_module, machine_args) do
        Supervisor.start_link(__MODULE__, [servers, states, machine_module, machine_args])
    end

    def init([servers, machine_module, machine_args]) do
        children = for server <- servers do
            worker(Graft.Server, [server, servers, machine_module, machine_args], restart: :transient, id: server)
        end
        supervise(children, strategy: :one_for_one)
    end

    def init([servers, states, machine_module, machine_args]) do
        children = for {server, state} <- Enum.zip(servers, states) do
            worker(Graft.Server, [server, servers, state, machine_module, machine_args], restart: :transient, id: server)
        end
        supervise(children, strategy: :one_for_one)
    end
end
