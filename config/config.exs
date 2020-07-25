import Config

config :graft,
    cluster: [{:server1, :server1@localhost}, {:server2, :server1@localhost}, {:server3, :server1@localhost}],
    machine: MyStackMachine,
    machine_args: []