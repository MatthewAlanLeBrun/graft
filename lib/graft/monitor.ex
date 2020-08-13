defmodule Monitor do
    use GenServer
    require Logger

    def start_link(), do: GenServer.start_link __MODULE__, [], name: __MODULE__

    def trace(data) do 
        Logger.info "Pid of server calling trace #{inspect self()}"    
        GenServer.cast Monitor, data 
    end

    @impl true
    def init(_) do
        {:ok, :ok}
    end

    @impl true
    def handle_cast(data, _state) do
        Logger.info "Monitor (#{inspect self()}) data: #{inspect data}"
        {:noreply, :ok}
    end
end