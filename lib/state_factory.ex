defmodule Graft.StateFactory do
    use GenServer

    def start do
        GenServer.start_link(Graft.StateFactory, %{}, name: :factory)
    end

    def new_state do
        GenServer.cast(:factory, {:put, self()})
    end

    def get_state do
        GenServer.call(:factory, :get)
    end

    @impl true
    def init(%{}) do
        {:ok, %{}}
    end

    @impl true
    def handle_call(:get, {from_pid, _from_reference}, states) do
        {:reply, Map.get(states, from_pid) , states}
    end

    @impl true
    def handle_cast({:put, new_pid}, states) do
        {:noreply, Map.put(states, new_pid, Graft.State.create_state())}
    end
end
