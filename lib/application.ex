defmodule ExRakLib.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Registry, [:unique, Registry.ExRakLib]),
      worker(ExRakLib.Acceptor, [])
    ]

    opts = [strategy: :one_for_one, name: ExRakLib.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
