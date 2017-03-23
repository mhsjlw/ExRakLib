elixir-raknet
=============

UDP network library that follows the RakNet protocol for Elixir

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add rak_net to your list of dependencies in `mix.exs`:
  ```elixir
  def deps do
  	[{:rak_net, "~> 0.0.1"}]
  end
  ```

  2. Ensure rak_net is started before your application:
  ```elixir
  def application do
      [applications: [:rak_net]]
  end
  ```

## Thanks
- [RakLib](https://github.com/PocketMine/RakLib) for some packets to look at
- [RakNet](http://www.jenkinssoftware.com/) for the original protocol
- [hansihe](https://github.com/hansihe)
- [rom1504](https://github.com/rom1504)