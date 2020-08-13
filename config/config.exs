import Config

config :graft,
    cluster: [{:server1, :nonode@nohost}, {:server2, :nonode@nohost}, {:server3, :nonode@nohost}],
    machine: MyStackMachine,
    machine_args: [],
    monitor: [module: Graft.Supervisor, function: :start_link, args: [], hml: &:election_safety.mfa_spec/1]
    # monitor: false

config :logger, :console,
    colors: [info: :green],
    level: :info