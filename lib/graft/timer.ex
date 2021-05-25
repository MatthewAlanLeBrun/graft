defmodule Graft.Timer do
  @moduledoc false
  @timer_node :"timer@192.168.0.195"

  def start_coordinator do
    spawn(&coordinator/0)
    |> Process.register(:coordinator)
  end

  # Called from the location below, must be inserted before using the Timer   
#  def leader(:cast, :init, data = %Graft.State{log: [{prev_index, _, _} | _]}) do
#    t = :os.system_time(:millisecond)
#    Graft.Timer.elected(t, data.me)
#    Logger.info("New leader: #{inspect(data.me)}.")

  def elected(t, leader) do
    send({:timer, @timer_node}, {:elected, t, leader})
  end

  defp coordinator do
    receive do
      :initialise_cluster ->
        initialise_cluster()
        coordinator()

      :destroy_cluster ->
        destroy_cluster()
        coordinator()

      {:kill_leader, leader} ->
        kill_leader(leader)
        coordinator()

      :start_graft ->
        start_graft()
        coordinator()

      :stop ->
        :ok
    end
  end

  defp initialise_cluster do
    Graft.start(nil, nil)
    send({:timer, @timer_node}, {:started, node()})
  end

  defp start_graft do
    Graft.start()
  end

  defp kill_leader(leader) do
    t = :os.system_time(:millisecond)
    Supervisor.terminate_child(Graft.Supervisor, leader)
    send({:timer, @timer_node}, {:killed_leader, t})
  end

  defp destroy_cluster, do: Graft.stop()
end
