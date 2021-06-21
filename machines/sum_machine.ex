defmodule MySumMachine do
  use Graft.Machine

  @impl Graft.Machine
  def init([]), do: {:ok, 0}

  @impl Graft.Machine
  def handle_entry(x, acc) when is_number(x), do: {x+acc, x+acc}
  def handle_entry(:fault, _), do: (10/0)
  def handle_entry(_, acc), do: {:invalid_request, acc}
end
