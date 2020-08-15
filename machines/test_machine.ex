defmodule MyTestMachine do
    use Graft.Machine

    @impl Graft.Machine
    def init([]) do
        {:ok, :ok}
    end

    @impl Graft.Machine
    def handle_entry({tester, msg}, state) do
        send tester, {:test_machine, msg}
        {state, state}
    end
end