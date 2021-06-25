defmodule Graft.MixProject do
  use Mix.Project

  @version "0.2.0"
  @description "A library for implementing distributed generic replicated state machines using the Raft consensus algorithm"
  @github "https://github.com/MatthewAlanLeBrun/graft"

  def project do
    [
      app: :graft,
      version: @version,
      description: @description,
      elixir: "~> 1.9",
      deps: deps(),
      package: package(),
      source_url: @github,
      elixirc_paths: ["lib", "machines"],
      start_permanent: Mix.env() == :prod,
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

  defp package do
    %{
      licenses: ["MIT"],
      maintainers: ["Matthew Alan Le Brun"],
      links: %{"GitHub" => @github}
    }
  end
end
