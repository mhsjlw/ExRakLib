defmodule RakNet.Packet do
  @magic << 0x00, 0xff, 0xff, 0x00, 0xfe, 0xfe, 0xfe, 0xfe, 0xfd, 0xfd, 0xfd, 0xfd, 0x12, 0x34, 0x56, 0x78 >>

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
  
  def magic, do: @magic
  
  def ping, do: @ping
  def unconnected_ping, do: @unconnected_ping
  def unconnected_ping_open_connections, do: @unconnected_ping_open_connections
  def pong, do: @pong
  def open_connection_request_1, do: @open_connection_request_1
  def open_connection_reply_1, do: @open_connection_reply_1
  def open_connection_request_2, do: @open_connection_request_2
  def open_connection_reply_2, do: @open_connection_reply_2
  def client_connect, do: @client_connect
  def server_handshake, do: @server_handshake
  def client_handshake, do: @client_handshake
  def client_disconnect, do: @client_disconnect
  def unconnected_pong, do: @unconnected_pong
  def advertise_system, do: @advertise_system
  def data_packet_0, do: @data_packet_0
  def data_packet_1, do: @data_packet_1
  def data_packet_2, do: @data_packet_2
  def data_packet_3, do: @data_packet_3
  def data_packet_4, do: @data_packet_4
  def data_packet_5, do: @data_packet_5
  def data_packet_6, do: @data_packet_6
  def data_packet_7, do: @data_packet_7
  def data_packet_8, do: @data_packet_8
  def data_packet_9, do: @data_packet_9
  def data_packet_A, do: @data_packet_A
  def data_packet_B, do: @data_packet_B
  def data_packet_C, do: @data_packet_C
  def data_packet_D, do: @data_packet_D
  def data_packet_E, do: @data_packet_E
  def data_packet_F, do: @data_packet_F
  def nack, do: @nack
  def ack, do: @ack
  
  def read_ip_address(buffer) do
    << first :: unsigned-size(8), second :: unsigned-size(8), third :: unsigned-size(8), fourth :: unsigned-size(8) >> = buffer
    "#{first}.#{second}.#{third}.#{fourth}"
  end
  
  def write_ip_address(address) do
    [first | [second | [third | [fourth | _]]]] = String.split(address, ".")
    {first, _} = Integer.parse(first)
    {second, _} = Integer.parse(second)
    {third, _} = Integer.parse(third)
    {fourth, _} = Integer.parse(fourth)
    << first :: unsigned-size(8), second :: unsigned-size(8), third :: unsigned-size(8), fourth :: unsigned-size(8) >>
  end
  
  def read_triad(buffer) do
    << first :: size(8), second :: size(8), third :: size(8) >> = buffer
    [first, second, third]
  end
  
  def write_triad(triad) do
    [first | [second | [ third | _]]] = triad
    << first :: size(8), second :: size(8), third :: size(8) >>
  end
  
  def read_ltriad(buffer) do
    << first :: little-size(8), second :: little-size(8), third :: little-size(8) >> = buffer
    [first, second, third]
  end
  
  def write_ltriad(triad) do
    [first | [second | [ third | _]]] = triad
    << first :: little-size(8), second :: little-size(8), third :: little-size(8) >>
  end
end