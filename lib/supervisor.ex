defmodule Graft.Supervisor do
    use Supervisor

    def start_link(servers, machine_module, machine_args) do
        Supervisor.start_link(__MODULE__, [servers, machine_module, machine_args])
    end

    def init([servers, machine_module, machine_args]) do
        children = for server <- servers do
            worker(Graft.Server, [server, servers, machine_module, machine_args], restart: :transient, id: server)
        end

        supervise(children, strategy: :one_for_one)
    end
end
