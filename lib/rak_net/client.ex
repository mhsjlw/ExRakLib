defmodule RakNet.Client do
  use GenServer
  require Logger

  @magic << 0, 255, 255, 0, 254, 254, 254, 254, 253, 253, 253, 253, 18, 52, 86, 120 >>
  @server_identification << 0, 5, 47, 12, 255, 154, 221, 225 >>

  @ping 0x00
  @unconnected_ping 0x01
  @unconnected_ping_open_connections 0x02
  @pong 0x03
  @open_connection_request_1 0x05
  @open_connection_reply_1 0x06
  @open_connection_request_2 0x07
  @open_connection_reply_2 0x08
  @client_connect 0x09
  @server_handshake 0x10
  @client_handshake 0x13
  @client_disconnect 0x15
  @unconnected_pong 0x1c
  @advertise_system 0x1d
  @data_packet_0 0x80
  @data_packet_1 0x81
  @data_packet_2 0x82
  @data_packet_3 0x83
  @data_packet_4 0x84
  @data_packet_5 0x85
  @data_packet_6 0x86
  @data_packet_7 0x87
  @data_packet_8 0x88
  @data_packet_9 0x89
  @data_packet_A 0x8a
  @data_packet_B 0x8b
  @data_packet_C 0x8c
  @data_packet_D 0x8d
  @data_packet_E 0x8e
  @data_packet_F 0x8f
  @nack 0xa0
  @ack 0xc0

  def start_link(state) do
    state = Map.put(state, :sequence_number, 0)
    GenServer.start_link(__MODULE__, state)
  end

  def handle_cast({:ping, packet}, state) do
    Logger.info "Got a ping! #{inspect packet}"

    packet = RakNet.DataTypes.read_data_packet(packet)
    [head | tail] = packet[:packets]
    Logger.info("#{inspect head}")

    # write_encapsulated(%{identifier: "pong", flags: 0, buffer: response})
    # :gen_udp.send(state[:socket], state[:host], state[:port], response)

    {:noreply, state}
  end

  def handle_cast({:open_connection_request_1, packet}, state) do
    Logger.info "Got an open_connection_request_1! #{inspect packet}"
    << _ :: binary-size(16), protocol :: size(8), mtu_size :: binary >> = packet

    response = << @open_connection_reply_1, @magic :: binary, @server_identification :: binary, 0 :: size(8), byte_size(mtu_size) + 46 :: size(16) >>
    :gen_udp.send(state[:socket], state[:host], state[:port], response)

    {:noreply, state}
  end

  def handle_cast({:open_connection_request_2, packet}, state) do
    Logger.info "Got an open_connection_request_2! #{inspect packet}"
    << _ :: binary-size(16), server_address :: binary-size(7), mtu_size :: size(16), client_id :: size(64) >> = packet
    server_address = RakNet.DataTypes.read_address_port(server_address)

    client_address = RakNet.DataTypes.write_address_port(%{version: 4, address: state[:host], port: state[:port]})
    response = << @open_connection_reply_2, @magic :: binary, @server_identification :: binary, client_address :: binary, mtu_size :: size(16), 0 :: size(8) >>
    :gen_udp.send(state[:socket], state[:host], state[:port], response)

    {:noreply, state}
  end

  def handle_cast({:client_connect, packet}, state) do
    Logger.info "Got a client_connect! #{inspect packet}"
    {:noreply, state}
  end

  def handle_cast({:client_handshake, packet}, state) do
    Logger.info "Got a client_handshake! #{inspect packet}"
    Map.put(state, :connected, true)
    {:noreply, state}
  end

  def handle_cast({:client_disconnect, packet}, state) do
    Logger.info "Got a client_disconnect! #{inspect packet}"
    GenServer.stop(self(), :normal)
    {:noreply, state}
  end

  def handle_cast({:data_packet, packet}, state) do
    Logger.info "Got an data_packet! #{inspect packet}"
    packet = RakNet.DataTypes.read_data_packet(packet)
    [head | tail] = packet[:packets]
    Logger.info("#{inspect head}")
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

  def terminate(reason, state) do
    Registry.unregister(Registry.RakNet, self())
  end
end