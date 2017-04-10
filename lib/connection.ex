defmodule RakNet.Connection do
  use GenServer
  require Logger

  @magic << 0, 255, 255, 0, 254, 254, 254, 254, 253, 253, 253, 253, 18, 52, 86, 120 >>
  @server_identifier << 123456789 :: size(64) >>

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
    GenServer.start_link(__MODULE__, state)
  end

  def handle_cast({:open_connection_request_1, data}, state) do
    Logger.info "Got an open_connection_request_1! #{inspect data}"
    << _ :: binary-size(16), protocol :: size(8), mtu_size :: binary >> = data

    response = << @open_connection_reply_1, @magic :: binary, @server_identifier :: binary, 0 :: size(8), byte_size(mtu_size) + 46 :: size(16) >>
    :gen_udp.send(state[:socket], state[:host], state[:port], response)

    {:noreply, state}
  end

  def handle_cast({:open_connection_request_2, data}, state) do
    Logger.info "Got an open_connection_request_2! #{inspect data}"
    << _ :: binary-size(16), server_address :: binary-size(7), mtu_size :: size(16), client_id :: size(64) >> = data
    server_address = RakNet.DataTypes.decode_address_port(server_address)

    client_address = RakNet.DataTypes.encode_address_port(%{version: 4, address: state[:host], port: state[:port]})
    response = << @open_connection_reply_2, @magic :: binary, @server_identifier :: binary, client_address :: binary, mtu_size :: size(16), 0 :: size(8) >>
    :gen_udp.send(state[:socket], state[:host], state[:port], response)

    {:noreply, state}
  end


  def handle_cast({:data_packet, data}, state) do
    Logger.info "Got a data_packet! #{inspect data}"
    RakNet.DataTypes.decode_data_packet(data)
    {:noreply, state}
  end

  def terminate(reason, state) do
    Registry.unregister(Registry.RakNet, {state[:host], state[:port]})
  end
end