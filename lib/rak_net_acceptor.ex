defmodule RakNet.Acceptor do
  require Logger

  @response "MCPE;A Minecraft: PE Server;102;1.0.4.11;0;20"
  @magic << 0x00, 0xff, 0xff, 0x00, 0xfe, 0xfe, 0xfe, 0xfe, 0xfd, 0xfd, 0xfd, 0xfd, 0x12, 0x34, 0x56, 0x78 >>
  @server_identification << 0, 5, 47, 12, 255, 154, 221, 225 >>

  @connected_users %{}

  def start_link(opts \\ []) do
    {:ok, socket} = :gen_udp.open(19132, [:binary, {:active, :true}])
    Logger.info("Started!")
    loop(socket)
  end

  def loop(socket) do
    # :inet.setopts(socket, [{:active, :once}])
    receive do
      {:udp, socket, host, port, packet} ->
        << identifier :: size(8), body :: binary >> = packet

        # Logger.info(identifier)
        if identifier == RakNet.Packets.id_unconnected_ping do
          << ping_identification :: size(64), _ :: binary >> = body
          Logger.info("Got unconnected ping! With ID of #{inspect ping_identification}, #{inspect body}")
          payload = << RakNet.Packets.id_unconnected_pong, ping_identification :: size(64), @server_identification, @magic, byte_size(@response) :: size(16), @response >>
          :gen_udp.send(socket, host, port, payload)
          Logger.info("Sent back #{byte_size(payload)} #{inspect payload}")
          IO.inspect(payload, limit: :infinity)
        else if identifier == RakNet.Packets.open_connection_request_1
          if not Map.has_key?(@connected_users, host)
            {:ok, pid} = RakNet.Client.start_link(socket, host, port)
            send pid {identifier, body}
            Map.put(@connected_users, host, pid)
        else
          if Map.has_key?(@connected_users, host)
            pid = Map.get(@connected_users, host)
            send pid {identifier, body}
        end
      end
    end
    loop(socket)
  end
end