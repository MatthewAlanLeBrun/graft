# Graft
Graft offers an Elixir implementation of the raft consensus algorithm, allowing the creation of a distributed cluster of servers, where each server manages a replicated state machine. The `Graft.Machine` behaviour allows users to define their own replicated state machines, that may handle user defined client requests.

In this project's documentation you will find terminology that has been defined in the [raft paper](https://raft.github.io/raft.pdf). The docs do not go into specifics of the raft algorithm, so if you wish to learn more about how raft achieves consensus, the [official raft webpage](https://raft.github.io/) is a great place to start.

## Installation
To install the package, add it to your dependency list in `mix.exs`.

```elixir
def deps do
    [{:graft, "~> 0.1.0"}]
end
```

## Documentation
Find the full documentation as well as examples here.
