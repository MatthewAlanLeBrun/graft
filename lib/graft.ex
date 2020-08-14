defmodule Graft do
    @moduledoc """
    An API of the raft consensus algorithm, allowing for custom client requests
    and custom replicated state machines.

    ## Example

    Let's create a distributed stack. The first step is to set up the state machine.
    Here we will use the `Graft.Machine` behaviour.

    ```
    defmodule MyStackMachine do
        use Graft.Machine

        @impl Graft.Machine
        def init([]) do
            {:ok, []}
        end

        @impl Graft.Machine
        def handle_entry({:put, value}, state) do
            {:ok, [value | state]}
        end

        def handle_entry(:pop, []) do
            {:noop, []}
        end

        def handle_entry(:pop, [response | state]) do
            {response, state}
        end

        def handle_entry(_, state) do
            {:invalid_request, state}
        end
    end
    ```

    Now that we have our state machine, we can define the servers that
    will make up the raft cluster. Each server must have a unique name.

    ```
    servers = [:server1, :server2, :server3]
    ```

    With both the servers and state machine, we can now run the graft funtion,
    which will start the servers and the consensus algorithm.

    ```
    {:ok, supervisor} = Graft.start servers, MyStackMachine
    ```

    `Graft.start` returns the supervisor pid from which we can terminate or restart
    the servers.

    We can now use `Graft.request` to make requests to our consensus cluster.
    As long as we know at least one server, we can send requests, since the `Graft.Client`
    module will forward the request if the server we choose is not the current leader.

    ```
    Graft.request :server1, :pop
    #=> :noop

    Graft.request :server1, {:put, :foo}
    #=> :ok

    Graft.request :server1, :pop
    #=> :foo

    Graft.request :server1, :bar
    #=> :invalid_request
    ```

    That completes the distributed stack.
    """

    use Application

    def start(), do: for server <- Application.fetch_env!(:graft, :cluster), do: GenStateMachine.cast server, :start
    def start(_type, _args) do
        case Application.fetch_env!(:graft, :monitor) do
            [module: m, function: f, args: a, hml: hml] ->
                {_, sup} = :async_mon.start {m,f,a}, hml, merged: false
                sup
            _ -> Graft.Supervisor.start_link
        end
    end

    def force_promotion(server), do: GenStateMachine.cast server, :force_promotion
    def leader(server), do: GenStateMachine.call server, :leader
    def stop_server(server), do: Supervisor.terminate_child Graft.Supervisor, server
    def restart_server(server), do: Supervisor.restart_child Graft.Supervisor, server 
    def send_AE(leader, follower), do: GenStateMachine.cast leader, {:send_append_entries, follower}

    # @doc """
    # Starts the raft cluster.

    # `servers` - list of server names.
    # `machine_module` - module using the `Graft.Machine` behaviour to define the replicated state machine.
    # `machine_args` - an optional list of arguments that are passed to the `init` function of the machine.

    # Returns `{:ok, pid}` where `pid` is the supervisor pid which can be used to supervise the cluster's servers.
    # """
    # @spec start(list(atom), module(), list(any)) :: {:ok, pid()}
    # def start(servers, machine_module, machine_args \\ []) do
    #     {:ok, supervisor_pid} = Graft.Supervisor.start_link servers, machine_module, machine_args
    #     for server <- servers, do: Supervisor.start_child supervisor_pid, [server, servers, machine_module, machine_args]
    #     for server <- servers, do: GenStateMachine.cast server, :start
    #     {:ok, supervisor_pid}
    # end

    @doc """
    Print out the internal state of the `server`.
    """
    def data(server), do: GenStateMachine.call(server, :data)

    @doc """
    Make a new client request to a server within the consensus cluster.

    `server` - name of the server the request should be sent to.
    'entry' - processed and applied by the replicated state machine.
    """
    @spec request(atom(), any()) :: response :: any()
    def request(server, entry), do: Graft.Client.request server, entry
end
