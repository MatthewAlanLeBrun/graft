defmodule Graft do
    @moduledoc """
    Documentation for Graft.
    """

    def start(servers, machine_module, machine_args \\ []) do
        {:ok, supervisor_pid} = Graft.Supervisor.start_link servers, machine_module, machine_args
        for server <- servers, do: Supervisor.start_child supervisor_pid, [server, servers, machine_module, machine_args]
        for server <- servers, do: GenStateMachine.cast server, :start
        {:ok, supervisor_pid}
    end

    def data(server), do: GenStateMachine.call(server, :data)

    def all_data(servers) do
        for server <- servers do
            GenStateMachine.call(server, :data)
        end
    end

end
