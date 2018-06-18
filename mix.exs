defmodule ExRakLib.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_rak_lib,
      version: "0.1.0",
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:logger], mod: {ExRakLib.Application, []}]
  end

  defp deps do
    []
  end

  defp aliases do
    [test: "test --no-start"]
  end
end
