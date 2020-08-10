defmodule Inspecter do
    def my_inspect(term, label) do
        IO.puts IO.ANSI.format([:yellow_background, :black, label, ": ", inspect(term)])
        term
    end
end