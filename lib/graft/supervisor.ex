defmodule Graft.Supervisor do
  @moduledoc false
  require Logger
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, cluster_config(), name: __MODULE__)
  end

  def init([{my_servers, all_servers}, machine_module, machine_args]) do
    Logger.info("This is node #{node()}, servers on this node are #{inspect(my_servers)}")

    servers =
      for {name, _node} <- my_servers do
        %{
          id: name,
          start: {Graft.Server, :start_link, [name, all_servers, machine_module, machine_args]}
          # restart: :transient
        }
      end

    sandboxes = 
      for {name, _node} <- my_servers do
        %{
          id: :"#{name}_sandbox",
          start: {Graft.Machine, :register, [machine_module, machine_args]}
        }
      end

    children = servers ++ sandboxes
    Supervisor.init(children, strategy: :one_for_one)
  end


  defp cluster_config() do
    [
      Application.fetch_env!(:graft, :cluster) |> on_my_node(),
      Application.fetch_env!(:graft, :machine),
      Application.fetch_env!(:graft, :machine_args)
    ]
  end

  defp on_my_node(servers) do
    {(servers |> Enum.group_by(fn {_, node} -> node end))[node()], servers}
  end
end
