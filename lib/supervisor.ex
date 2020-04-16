defmodule Graft.Supervisor do
    use Supervisor

    def start_link(servers) do
        Supervisor.start_link(__MODULE__, [servers])
    end

    def init([servers]) do
        children = for server <- servers do
            worker(Graft.Server, [server, servers], restart: :transient, id: server)
        end

        supervise(children, strategy: :one_for_one)
    end
end
