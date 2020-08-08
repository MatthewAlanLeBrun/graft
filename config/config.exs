import Config

config :graft,
    cluster: [{:server1, :me@localhost}, {:server2, :me@localhost}, {:server3, :me@localhost}],
    machine: MyStackMachine,
    machine_args: []

config :logger,
    level: :info