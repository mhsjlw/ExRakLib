defmodule RakNet.Acceptor do
  require Logger

  @response "MCPE;A Minecraft: PE Server;102;1.0.4.11;0;20"
  @server_identification << 0, 5, 47, 12, 255, 154, 221, 225 >>

  @connected_users %{}

  def start_link(opts \\ []) do
    {:ok, socket} = :gen_udp.open(19132, [:binary, {:active, :true}])
    Logger.info("Started!")
    loop(socket)
  end

  def loop(socket) do
    receive do
      {:udp, socket, host, port, packet} ->
        << identifier :: size(8), body :: binary >> = packet
        
        unconnected_ping = RakNet.Packet.unconnected_ping
        open_connection_request_1 = RakNet.Packet.open_connection_request_1
        unconnected_pong = RakNet.Packet.unconnected_pong
        
        case identifier do
          unconnected_ping ->
            << ping_identification :: size(64), _ :: binary >> = body
            Logger.info("Got unconnected ping! With ID of #{inspect ping_identification}, #{inspect body}")
            payload = << unconnected_pong, ping_identification :: size(64), @server_identification, RakNet.Packet.magic, byte_size(@response) :: size(16), @response >>
            :gen_udp.send(socket, host, port, payload)
            Logger.info("Sent back #{byte_size(payload)} #{inspect payload}")
            IO.inspect(payload, limit: :infinity)
          open_connection_request_1 ->
            if not Map.has_key?(@connected_users, host) do
              {:ok, pid} = RakNet.Client.start_link(socket, host, port)
              send pid, {identifier, body}
              Map.put(@connected_users, host, pid)
            end
          _ ->
            if Map.has_key?(@connected_users, host) do
              pid = Map.get(@connected_users, host)
              send pid, {identifier, body}
            end
        end
    end
        
    loop(socket)
  end
end