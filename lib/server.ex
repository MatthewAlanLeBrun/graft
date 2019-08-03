defmodule Graft.Server do
    def start do
        spawn fn -> init() end
    end

    def init() do
        Process.register(Graft.State.create_state(:general, generate_time_out(), general_state())
        follower()
    end

    def follower do
        receive do
            {:msg, msg} ->
                IO.puts(msg)
                follower()
        after
            ms = time_out() ->
                IO.puts("Timed out #{ms}, beginning election")
                candidate()
        end
    end

    def candidate do

    end

    def leader do

    end

    defp generate_time_out do: :rand.uniform(50)*100+5000)

    defp time_out do
        send general_state(), {:get, :time_out, self()}
        receive do ms -> ms end
    end

    defp general_state do
        pid_string = String.replace((inspect self()), ["#",".","<",">"], "_")
        String.to_atom("general_state" <> pid_string)
    end
end
