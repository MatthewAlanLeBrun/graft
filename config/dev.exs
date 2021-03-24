import Config

config :graft,
    cluster: [{:server1, :"server1@192.168.0.232"}, 
              {:server2, :"server2@192.168.0.232"}, 
              {:server3, :"server3@192.168.0.232"} 
              #{:server4, :"server4@192.168.0.232"}, 
              #{:server5, :"server5@192.168.0.232"}
    ],
    machine: MySumMachine,
    machine_args: [],
    server_timeout: fn -> :rand.uniform(150)+150 end,
    heartbeat_timeout: 70

config :logger, :console,
    colors: [info: :green],
    level: :notice
