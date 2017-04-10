defmodule RakNet.Acceptor do
  require Logger

  @offline_ping_response Application.get_env(:rak_net, :offline_ping_response)
  @max_connections Application.get_env(:rak_net, :max_connections)

  @magic << 0, 255, 255, 0, 254, 254, 254, 254, 253, 253, 253, 253, 18, 52, 86, 120 >>
  @server_identifier << 123456789 :: size(64) >>

  @unconnected_ping 0x01
  @open_connection_request_1 0x05
  @open_connection_request_2 0x07
  @unconnected_pong 0x1c
  @data_packet_0 0x80
  @data_packet_F 0x8f

  def start_link do
    {:ok, socket} = :gen_udp.open(19132, [:binary, {:active, :true}])
    accept(socket)
  end

  def accept(socket) do
    receive do
      {:udp, socket, host, port, << identifier :: unsigned-size(8), data :: binary >>} ->
        Logger.info("#{inspect identifier}")
        
        case identifier do
          @unconnected_ping ->
            :gen_udp.send(socket, host, port, handle_unconnected_ping(data))
          @open_connection_request_1 ->
            handle_open_connection_request_1(socket, host, port, data)
          _ ->
            dispatch(socket, host, port, identifier, data)
        end

    end

    accept(socket)
  end

  defp handle_unconnected_ping(<< ping_identification :: size(64), _ :: binary >>) do
    << @unconnected_pong, ping_identification :: size(64), @server_identifier :: binary, @magic :: binary, RakNet.DataTypes.encode_string(@offline_ping_response) :: binary >>
  end

  defp handle_open_connection_request_1(socket, host, port, data) do
    if not in_registry?({host, port}) do
      {:ok, client} = RakNet.Connection.start_link(%{socket: socket, host: host, port: port, sequence_number: 0})
      Registry.register(Registry.RakNet, {host, port}, client)
      GenServer.cast(client, {:open_connection_request_1, data})
    end
  end

  defp dispatch(socket, host, port, identifier, data) do
    if in_registry?({host, port}) do
      client = lookup({host, port})

      cond do
        Enum.member?(@data_packet_0..@data_packet_F, identifier) -> GenServer.cast(client, {:data_packet, data})
        @open_connection_request_1 == identifier -> GenServer.cast(client, {:open_connection_request_1, data})
        @open_connection_request_2 == identifier -> GenServer.cast(client, {:open_connection_request_2, data})
        true -> Logger.info("#{inspect identifier} is not handled!")
      end
    end
  end

  defp in_registry?({host, port}) do
    not Enum.empty?(Registry.lookup(Registry.RakNet, {host, port}))
  end

  defp lookup({host, port}) do
    [{_, client}] = Registry.lookup(Registry.RakNet, {host, port})
    client
  end
end