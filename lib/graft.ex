defmodule Graft do
    @moduledoc """
    Documentation for Graft.
    """

    def start(servers) do
        {:ok, supervisor_pid} = Graft.Supervisor.start_link servers
        for server <- servers, do: Supervisor.start_child supervisor_pid, [server, servers]
        for server <- servers, do: GenStateMachine.cast server, :start
        supervisor_pid
    end

    def start5, do: start([:server1, :server2, :server3, :server4, :server5])
    def start3, do: start([:server1, :server2, :server3])

    def data(server), do: GenStateMachine.call(server, :data)

    def all_data(servers) do
        for server <- servers do
            GenStateMachine.call(server, :data)
        end
    end

end
