defmodule Graft do
  @moduledoc """
  Documentation for Graft.
  """

  def start(servers) do
      for server <- servers do
          Graft.Server.start(server, servers)
      end
  end

  def start5, do: start([:server1, :server2, :server3, :server4, :server5])

  def data(server), do: GenStateMachine.call(server, :data)
  
end
