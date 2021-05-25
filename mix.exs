defmodule Graft.MixProject do
  use Mix.Project

  def project do
    [
      app: :graft,
      version: "0.1.0",
      elixir: "~> 1.9",
      elixirc_paths: ["lib", "machines"],
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Graft, []},
      registered: [Graft.Supervisor]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:excoveralls, "~> 0.10", only: :test},
      {:gen_state_machine, "~> 2.0"}
    ]
  end
end
