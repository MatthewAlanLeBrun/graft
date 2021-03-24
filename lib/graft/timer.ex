defmodule Graft.Timer do
  @moduledoc false
  @timer_node :"timer@192.168.0.232"

  def start_coordinator do 
    spawn(&coordinator/0)
    |> Process.register(:coordinator)
  end

  def elected(t, leader) do
    send {:timer, @timer_node}, {:elected, t, leader}
  end

  defp coordinator do
    receive do
      :initialise_cluster -> initialise_cluster(); coordinator()
      :destroy_cluster -> destroy_cluster(); coordinator()
      {:kill_leader, leader} -> kill_leader(leader); coordinator()
      :start_graft -> start_graft(); coordinator()
      :stop -> :ok
    end
  end

  defp initialise_cluster do 
    Graft.start nil, nil
    send {:timer, @timer_node}, {:started, node()}
  end

  defp start_graft do 
    Graft.start()
  end

  defp kill_leader(leader) do
    IO.inspect leader, label: "Killing leader"
    t = :os.system_time :millisecond
    Supervisor.terminate_child Graft.Supervisor, leader
    send {:timer, @timer_node}, {:killed_leader, t}
  end

  defp destroy_cluster, do: Graft.stop() 
end
