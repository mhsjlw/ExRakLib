defmodule RakNet.Client do
  require Logger

  @state %{connected: false, queue: []}
  @host nil
  @port nil

  def start_link(socket, host, port) do
    @host = host
    @port = port

    Task.start_link(fn -> loop(socket, host, port) end)
  end

  defp loop(socket, host, port) do
    Logger.info "called"
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

    receive do
      {identifier, packet} ->
        cond do
          Enum.member?(data_packet_0..data_packet_F, identifier) -> handle_data_packet(packet)
          identifier == ping -> handle_ping(packet)
          identifier == open_connection_request_1 -> handle_open_connection_request_1(packet)
          identifier == open_connection_request_2 -> handle_open_connection_request_2(packet)
          identifier == client_connect -> handle_client_connect(packet)
          identifier == client_handshake -> handle_client_handshake(packet)
          identifier == client_disconnect -> handle_client_disconnect(packet)
          identifier == nack -> handle_nack(packet)
          identifier == ack -> handle_ack(packet)
          true -> "shouldn't happen once every packet is implemented"
        end
    end
    loop(socket, host, port)
  end

  defp handle_ping(packet) do
    Logger.info "Got a ping! #{inspect packet}"
  end

  defp handle_open_connection_request_1(packet) do
    Logger.info "Got an open_connection_request_1! #{inspect packet}"
  end

  defp handle_open_connection_request_2(packet) do
    Logger.info "Got an open_connection_request_2! #{inspect packet}"
  end

  defp handle_client_connect(packet) do
    Logger.info "Got a client_connect! #{inspect packet}"
  end

  defp handle_client_handshake(packet) do
    Logger.info "Got a client_handshake! #{inspect packet}"
  end

  defp handle_client_disconnect(packet) do
    Logger.info "Got a client_disconnect! #{inspect packet}"
  end

  defp handle_data_packet(packet) do
    Logger.info "Got a data_packet! #{inspect packet}"
  end

  defp handle_nack(packet) do
    Logger.info "Got a nack! #{inspect packet}"
  end

  defp handle_ack(packet) do
    Logger.info "Got an ack! #{inspect packet}"
  end
end