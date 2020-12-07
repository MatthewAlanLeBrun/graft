import Config

config :graft,
    cluster: [{:server1, :nonode@nohost}, {:server2, :nonode@nohost}, {:server3, :nonode@nohost}],
    machine: MyKVMachine,
    machine_args: [],
    server_timeout: fn -> :rand.uniform(150)+150 end,
    heartbeat_timeout: 100

config :logger, :console,
    colors: [info: :green],
    level: :info