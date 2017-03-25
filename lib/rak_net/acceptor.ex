defmodule RakNet.Acceptor do
  require Logger

  @response "MCPE;A Minecraft: PE Server;102;1.0.4.11;0;20"

  def start_link(opts \\ []) do
    {:ok, socket} = :gen_udp.open(19132, [:binary, {:active, :true}])
    Logger.info("Started!")
    loop(socket)
  end

  def loop(socket) do
    receive do
      {:udp, socket, host, port, packet} ->
        << identifier :: size(8), body :: binary >> = packet
        
        unconnected_ping = RakNet.unconnected_ping

        data_packet_0 = RakNet.data_packet_0
        data_packet_F = RakNet.data_packet_F

        ping = RakNet.ping
        open_connection_request_1 = RakNet.open_connection_request_1
        open_connection_request_2 = RakNet.open_connection_request_2
        client_connect = RakNet.client_connect
        client_handshake = RakNet.client_handshake
        client_disconnect = RakNet.client_disconnect
        nack = RakNet.nack
        ack = RakNet.ack

        Logger.info("#{inspect identifier}")
        
        cond do
          identifier == unconnected_ping ->
            << ping_identification :: size(64), _ :: binary >> = body
            
            payload = << RakNet.unconnected_pong, ping_identification :: size(64), RakNet.server_identification :: binary , RakNet.magic :: binary, RakNet.DataTypes.write_string(@response) :: binary >>

            :gen_udp.send(socket, host, port, payload)
          identifier == open_connection_request_1 ->
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
                Enum.member?(data_packet_0..data_packet_F, identifier) -> GenServer.cast(client, {:data_packet, body})
                identifier == ping -> GenServer.cast(client, {:ping, body})
                identifier == open_connection_request_1 -> GenServer.cast(client, {:open_connection_request_1, body})
                identifier == open_connection_request_2 -> GenServer.cast(client, {:open_connection_request_2, body})
                identifier == client_connect -> GenServer.cast(client, {:client_connect, body})
                identifier == client_handshake -> GenServer.cast(client, {:client_handshake, body})
                identifier == client_disconnect -> GenServer.cast(client, {:client_disconnect, body})
                identifier == nack -> GenServer.cast(client, {:nack, body})
                identifier == ack -> GenServer.cast(client, {:ack, body})
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