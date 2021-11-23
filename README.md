# Graft

[![Module Version](https://img.shields.io/hexpm/v/graft.svg)](https://hex.pm/packages/graft)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/graft/)
[![License](https://img.shields.io/hexpm/l/libcluster.svg)](https://github.com/MatthewAlanLeBrun/graft/blob/master/LICENSE)

Graft offers an Elixir implementation of the raft consensus algorithm, allowing the creation of a distributed cluster of servers, where each server manages a replicated state machine. The `Graft.Machine` behaviour allows users to define their own replicated state machines, that may handle user defined client requests.

In this project's documentation you will find terminology that has been defined in the [raft paper](https://raft.github.io/raft.pdf). The docs do not go into specifics of the raft algorithm, so if you wish to learn more about how raft achieves consensus, the [official raft webpage](https://raft.github.io/) is a great place to start.

## Installation
To install the package, add it to your dependency list in `mix.exs`.

```elixir
def deps do
    [{:graft, "~> 0.1.1"}]
end
```
If you are new to Elixir/mix, check out the [official Elixir webpage](https://elixir-lang.org/) for instructions on how to install Elixir. It is also a great place to start for newcomers to the language. You may also want to check out the [Introduction to mix](https://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html) and [dependencies](https://elixir-lang.org/getting-started/mix-otp/dependencies-and-umbrella-projects.html) guides for more information on how importing external projects works in Elixir.

## Documentation
Find the full documentation as well as examples [here](https://hexdocs.pm/graft/Graft.html).
