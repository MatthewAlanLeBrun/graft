import Config

config :graft,
  cluster: [
    {:s1, :"s1@192.168.0.232"},
    {:s2, :"s2@192.168.0.232"},
    {:s3, :"s3@192.168.0.232"},
    {:s4, :"s4@192.168.0.232"},
    {:s5, :"s5@192.168.0.232"}
  ],
  machine: MathMachine,
  machine_args: [],
  server_timeout: fn -> :rand.uniform(18)+18 end,
  heartbeat_timeout: 6

config :logger, :console,
  colors: [info: :green],
  level: :info
