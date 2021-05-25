import Config

config :graft,
  cluster: [
    {:server1, :"nonode@nohost"},
    {:server2, :"nonode@nohost"},
    {:server3, :"nonode@nohost"},
    {:server4, :"nonode@nohost"},
    {:server5, :"nonode@nohost"}
  ],
  machine: MySumMachine,
  machine_args: [],
  server_timeout: fn -> :rand.uniform(51)+149 end,
  heartbeat_timeout: 75

config :logger, :console,
  colors: [info: :green],
  level: :notice
