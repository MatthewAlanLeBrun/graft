defmodule MathMachine do
  use Graft.Machine

  @impl Graft.Machine
  def init([]), do: {:ok, 0}

  @impl Graft.Machine
  def handle_entry({:add, x}, acc) do
    ans = acc+x
    {ans, ans}
  end
  def handle_entry({:mul, x}, acc) do
    ans = acc*x
    {ans, ans}
  end
  def handle_entry({:sub, x}, acc) do
    ans = acc-x
    {ans, ans}
  end
  def handle_entry({:div, x}, acc) do
    ans = acc/x
    {ans, ans}
  end
  def handle_entry(_, acc), do: {:invalid_request, acc}
end
