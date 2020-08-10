import Config

config :graft,
    cluster: [{:server1, :node0@localhost}, {:server2, :node1@localhost}, {:server3, :node1@localhost}],
    machine: MyStackMachine,
    machine_args: [],
    monitor: [module: Graft.Supervisor, function: :start_link, args: [], hml: &:bypass.mfa_spec/1]
    # monitor: :off

config :logger, :console,
    colors: [info: :green],
    level: :info