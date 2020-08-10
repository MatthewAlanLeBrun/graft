defmodule MyStackMachine do
    use Graft.Machine

    @impl Graft.Machine
    def init([]) do
        {:ok, []}
    end

    @impl Graft.Machine
    def handle_entry({:push, value}, state) do
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