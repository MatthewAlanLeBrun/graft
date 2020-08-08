defmodule Graft.MixProject do
  use Mix.Project

  def project do
    [
      app: :graft,
      version: "0.1.0",
      elixir: "~> 1.9",
      elixirc_paths: ["lib", "machines"],
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Graft, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:gen_state_machine, "~> 2.0"}
    ]
  end
end
