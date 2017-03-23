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
        open_connection_request_1 = RakNet.open_connection_request_1
        
        case identifier do
          unconnected_ping ->
            << ping_identification :: size(64), _ :: binary >> = body
            
            Logger.info("Got unconnected ping! With ID of #{inspect ping_identification}, #{inspect body}")
            
            payload = << RakNet.unconnected_pong, ping_identification :: size(64), RakNet.server_identification :: binary , RakNet.magic :: binary, RakNet.DataTypes.write_string(@response) :: binary >>

            :gen_udp.send(socket, host, port, payload)
            
            Logger.info("Sent back #{byte_size(payload)} #{inspect payload}")
            IO.inspect(payload, limit: :infinity)
          open_connection_request_1 ->
            [{_, value}] = Registry.lookup(Registry.RakNet, "#{host}:#{port}")
            
            if not value do
              {:ok, pid} = RakNet.Client.start_link(socket, host, port)
              send pid, {identifier, body}
              
              Registry.register(Registry.RakNet, "#{host}:#{port}", pid)
            end
          _ ->
            [{_, value}] = Registry.lookup(Registry.RakNet, "#{host}:#{port}")
            
            if value do
              send value, {identifier, body}
            end
        end
    end
        
    loop(socket)
  end
end