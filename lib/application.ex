defmodule RakNet.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Registry, [:unique, Registry.RakNet]),
      worker(RakNet.Acceptor, [])
    ]

    opts = [strategy: :one_for_one, name: RakNet.Supervisor]
    Supervisor.start_link(children, opts)
  end
end