defmodule RakNet.Mixfile do
  use Mix.Project

  def project do
    [app: :rak_net,
     version: "0.0.1",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     mod: {RakNet.Application, []}]
  end

  defp deps do
    []
  end

  defp aliases do
    [test: "test --no-start"]
  end
end
