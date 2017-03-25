defmodule RakNet.Client do
  use GenServer
  require Logger

  def start_link(state),
   do: GenServer.start_link(__MODULE__, state) # %{socket: socket, port: port, host: host}

  def handle_cast({:ping, packet}, state) do
    Logger.info "Got a ping! #{inspect packet}"
  end

  def handle_cast({:open_connection_request_1, packet}, state) do
    Logger.info "Got an open_connection_request_1! #{inspect packet}"
    << _ :: binary-size(16), protocol :: size(8), mtu_size :: binary >> = packet

    # id (i8), magic, server_identification, server_security (i8), mtuSize (i16)
    response = << RakNet.open_connection_reply_1, RakNet.magic :: binary, RakNet.server_identification :: binary, 0 :: size(8), byte_size(mtu_size) + 46 :: size(16) >>
    :gen_udp.send(state[:socket], state[:host], state[:port], response)

    {:noreply, state}
  end

  def handle_cast({:open_connection_request_2, packet}, state) do
    Logger.info "Got an open_connection_request_2! #{inspect packet}"
    {:noreply, state}
  end

  def handle_cast({:client_connect, packet}, state) do
    Logger.info "Got a client_connect! #{inspect packet}"
    {:noreply, state}
  end

  def handle_cast({:client_handshake, packet}, state) do
    Logger.info "Got a client_handshake! #{inspect packet}"
    {:noreply, state}
  end

  def handle_cast({:client_disconnect, packet}, state) do
    Logger.info "Got a client_disconnect! #{inspect packet}"
    {:noreply, state}
  end

  def handle_cast({:data_packet, packet}, state) do
    Logger.info "Got an data_packet! #{inspect packet}"
    {:noreply, state}
  end

  def handle_cast({:nack, packet}, state) do
    Logger.info "Got a nack! #{inspect packet}"
    {:noreply, state}
  end

  def handle_cast({:ack, packet}, state) do
    Logger.info "Got an ack! #{inspect packet}"
    {:noreply, state}
  end
end