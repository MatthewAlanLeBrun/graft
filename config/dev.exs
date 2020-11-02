import Config

config :graft,
    cluster: [{:server1, :nonode@nohost}, {:server2, :nonode@nohost}, {:server3, :nonode@nohost}],
    machine: MyKVMachine,
    machine_args: []

config :logger, :console,
    colors: [info: :green],
    level: :info