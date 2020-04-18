defmodule Graft.Machine do
    use GenServer

    @callback init(args :: list(any)) :: {:ok, any}
    @callback apply_entry(state :: any, entry :: any) :: {any, any}

    defmacro __using__(_opts) do
        quote do
            @behaviour Graft.Machine

            def init(_args) do
                raise "function init/1 required by Graft.Machine"
            end

            def apply_entry(_state, _entry) do
                raise "function apply_entry/2 required by Graft.Machine"
            end

            defoverridable [init: 1, apply_entry: 2]
        end
    end

    @impl GenServer
    def init([module, args]) do
        {:ok, state} = module.init(args)
        {:ok, {module, state}}
    end

    @impl GenServer
    def handle_call({:apply, entry}, _from, {module, state}) do
        {state, reply} = module.apply_entry(state, entry)
        {:reply, reply, {module, state}}
    end

    def register(module, machine_args \\ []) do
        GenServer.start_link(__MODULE__, [module, machine_args])
    end

    def apply_entry(machine, entry) do
        GenServer.call machine, {:apply, entry}
    end
end

defmodule MyMapMachine do
    use Graft.Machine

    @impl Graft.Machine
    def init([]) do
        {:ok, %{}}
    end

    @impl Graft.Machine
    def apply_entry(state, {key, value}) do
        {Map.put(state, key, value), :ok}
    end

    def apply_entry(state, key) do
        {state, Map.get(state, key)}
    end
end
