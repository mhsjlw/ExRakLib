defmodule RakNet.Acceptor do
  require Logger

  @offline_ping_response Application.get_env(:rak_net, :offline_ping_response)
  @max_connections Application.get_env(:rak_net, :max_connections)

  @magic << 0, 255, 255, 0, 254, 254, 254, 254, 253, 253, 253, 253, 18, 52, 86, 120 >>
  @server_identifier << 123456789 :: size(64) >>

  @ping 0x00
  @unconnected_ping 0x01
  @open_connection_request_1 0x05
  @open_connection_request_2 0x07
  @client_connect 0x09
  @client_handshake 0x13
  @client_disconnect 0x15
  @unconnected_pong 0x1c
  @data_packet_0 0x80
  @data_packet_F 0x8f
  @nack 0xa0
  @ack 0xc0

  def start_link do
    {:ok, socket} = :gen_udp.open(19132, [:binary, {:active, :true}])
    Logger.info("Started!")
    loop(socket)
  end

  def loop(socket) do
    receive do
      {:udp, socket, host, port, packet} ->
        << identifier :: size(8), body :: binary >> = packet

        Logger.info("#{inspect identifier}")
        
        cond do
          identifier == @unconnected_ping ->
            << ping_identification :: size(64), _ :: binary >> = body
            
            payload = << @unconnected_pong, ping_identification :: size(64), @server_identifier :: binary , @magic :: binary, RakNet.DataTypes.write_string(@offline_ping_response) :: binary >>

            :gen_udp.send(socket, host, port, payload)
          identifier == @open_connection_request_1 ->
            lookup = Registry.lookup(Registry.RakNet, "#{convert_host_to_string host}:#{port}")
            
            if Enum.empty?(lookup) do
              {:ok, client} = RakNet.Client.start_link(%{socket: socket, port: port, host: host})
              GenServer.cast(client, {:open_connection_request_1, body})
              
              Registry.register(Registry.RakNet, "#{convert_host_to_string host}:#{port}", client)
            end
          true ->
            lookup = Registry.lookup(Registry.RakNet, "#{convert_host_to_string host}:#{port}")

            if not Enum.empty?(lookup) do
              [{_, client}] = lookup
              cond do
                Enum.member?(@data_packet_0..@data_packet_F, identifier) -> GenServer.cast(client, {:data_packet, body})
                identifier == @open_connection_request_1 -> GenServer.cast(client, {:open_connection_request_1, body})
                identifier == @open_connection_request_2 -> GenServer.cast(client, {:open_connection_request_2, body})
                identifier == @nack -> GenServer.cast(client, {:nack, body})
                identifier == @ack -> GenServer.cast(client, {:ack, body})
                true -> "shouldn't happen once every packet is implemented"
              end
            end
        end
    end
        
    loop(socket)
  end

  defp convert_host_to_string(host) do
    Enum.join(Tuple.to_list(host), ".")
  end
end