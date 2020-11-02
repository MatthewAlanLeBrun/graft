defmodule MyKVMachine do
    use Graft.Machine
  
    @impl Graft.Machine
    def init([]), do: {:ok, %{}}
  
    @impl Graft.Machine
    def handle_entry({:write, key, value}, state), do: {:ok, Map.put(state, key, value)}
    def handle_entry({:read, key}, state), do: {state[key], state}
    def handle_entry(_, state), do: {:invalid_request, state}
end