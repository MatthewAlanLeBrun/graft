import Config

config :graft,
    cluster: [{:s1, :nonode@nohost}, {:s2, :nonode@nohost}, {:s3, :nonode@nohost}],
    machine: MyStackMachine,
    machine_args: [],
    monitor: false

config :logger, :console,
    level: :debug