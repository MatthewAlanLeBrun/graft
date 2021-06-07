defmodule Graft.Machine do
  @moduledoc """
  A behaviour module for implementing a replicated machine for the raft consensus
  algorithm. Look at the `Graft` module docs for examples on how to create such
  machines.
  """
  require Logger
  use GenServer

  @typedoc """
  The state/data of the replicated machine (similar to the 'state' of GenServer).
  """
  @type state :: any

  @typedoc """
  The entry request sent by the client.
  """
  @type entry :: any

  @typedoc """
  The reply to be sent back to the client.
  """
  @type response :: any

  @doc """
  Invoked when the server starts and links to the machine.

  `args` is a list accepted arguments. Look at `Graft.start` to see how to pass
  in these optional arguments.

  Returning `{:ok, state}`, will initialise the state of the machine to `state`.
  """
  @callback init(args :: list(any)) :: {:ok, state}

  @doc """
  Invoked when a server in the raft cluster is commiting an entry to its log.
  Should apply the entry to the replicated machine.

  Should return a tuple of the response for the server along with the new state of the
  replicated machine.
  """
  @callback handle_entry(entry, state) :: {response, state}

  defmacro __using__(_opts) do
    quote location: :keep do
      @behaviour Graft.Machine
    end
  end

  @doc false
  @impl GenServer
  def init([state]), do: {:ok, state}

  def init([module, args]) do
    {:ok, state} = module.init(args)
    {:ok, {module, state}}
  end

  @doc false
  @impl GenServer
  def handle_call({:apply, entry}, _from, {module, state}) do
    {reply, state} = module.handle_entry(entry, state)
    {:reply, reply, {module, state}}
  end

  @doc false
  @impl GenServer
  def handle_cast({:apply, from, entry}, {module, state}) do
    Logger.debug("Sandbox got asynch request for #{entry}")
    {reply, state} = module.handle_entry(entry, state)
    GenStateMachine.cast(from, {:sandbox, {:ok, reply}})
    {:noreply, {module, state}}
  end

  @doc false
  def register(a, b \\ [])
  def register(machine, :sandbox) when is_pid(machine) do
    state = :sys.get_state(machine)
    GenServer.start_link(__MODULE__, [state])
  end

  def register(module, machine_args) do
    GenServer.start_link(__MODULE__, [module, machine_args])
  end

  @doc false
  def apply_entry(_machine, :noop), do: :noop
  def apply_entry(machine, entry) do
    GenServer.call(machine, {:apply, entry})
  end
  def apply_entry(machine, entry, :sandbox) do
    Logger.info("Sending entry #{entry} to sandbox")
    GenServer.cast(machine, {:apply, self(), entry})
  end

  @doc false
  def sandbox_child_spec(server, machine) when is_pid(machine) do
    %{
      id: :"#{server}_sandbox",
      start: {__MODULE__, :register, [machine, :sandbox]}
    }
  end
end
