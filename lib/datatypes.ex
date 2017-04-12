defmodule RakNet.DataTypes do
  require Logger

  def decode_ip_address(<< first :: unsigned-size(8), second :: unsigned-size(8), third :: unsigned-size(8), fourth :: unsigned-size(8), rest :: binary >>), do: {{first, second, third, fourth}, rest}
  
  def encode_ip_address({first, second, third, fourth}), do: << first :: unsigned-size(8), second :: unsigned-size(8), third :: unsigned-size(8), fourth :: unsigned-size(8) >>

  def decode_triad(<< triad :: size(24), rest :: binary >>), do: {triad, rest}
  
  def encode_triad(triad), do: << triad :: size(24) >>
  
  def decode_ltriad(<< triad :: little-size(24), rest :: binary >>), do: {triad, rest}
  
  def encode_ltriad(triad), do: << triad :: little-size(24) >>
  
  def decode_string(<< prefix :: unsigned-size(16), string :: binary-size(prefix), rest :: binary >>), do: {string, rest}
  
  def encode_string(string), do: << byte_size(string) :: unsigned-size(16), string :: bitstring >>
  
  def decode_bstring(<< prefix :: unsigned-size(8), string :: binary-size(prefix), rest :: binary >>), do: {string, rest}
  
  def encode_bstring(string), do: << byte_size(string) :: unsigned-size(8), string :: bitstring >>
  
  def decode_address_port(<< version :: size(8), address :: binary-size(4), port :: unsigned-size(16), rest :: binary >>), do: {%{version: 4, address: elem(decode_ip_address(address), 0), port: port}, rest}
  
  def encode_address_port(%{version: version, address: address, port: port}), do: << 4 :: size(8), encode_ip_address(address) :: binary, port :: unsigned-size(16) >>

  def decode_data_packet(<< sequence_number::little-size(24), rest::binary >>) do
    %{sequence_number: sequence_number, encapsulated_packets: decode_data_packet(rest, [])}
  end
  
  defp decode_data_packet("", encapsulated_packets) do
    Enum.reverse(encapsulated_packets)
  end

  defp decode_data_packet(rest, encapsulated_packets) do
    {packet, rest} = decode_encapsulated_packet(rest, false)
    decode_data_packet(rest, [packet | encapsulated_packets])
  end

  def encode_data_packet(%{sequence_number: sequence_number, encapsulated_packets: encapsulated_packets}) do
    [<< sequence_number::little-size(24) >>, Enum.map(encapsulated_packets, fn(x) -> encode_encapsulated_packet(x, false) end)]
  end

  def decode_encapsulated_packet(data, internal) do
    << reliability :: unsigned-size(3), has_split :: unsigned-size(5), rest :: binary >> = data

    {length, identifier_ack, rest} = if internal do
      << length :: size(32), identifier_ack :: size(32), rest :: binary >> = rest
      {length, identifier_ack, rest}
    else
      << length :: size(16), rest :: binary >> = rest
      {trunc(Float.ceil(length / 8)), nil, rest}
    end

    {message_index, rest} = if reliability in [2, 3, 4, 6, 7] do
      << message_index :: little-size(24), rest :: binary >> = rest
      {message_index, rest}
    else
      {nil, rest}
    end

    {order_index, order_channel, rest} = if reliability in [1, 3, 4] do
      << order_index :: little-size(24), order_channel :: size(8), rest :: binary >> = rest
      {order_index, order_channel, rest}
    else
      {nil, nil, rest}
    end

    {split_count, split_id, split_index, rest} = if has_split > 0 do
      << split_count :: size(32), split_id :: size(16), split_index :: size(32), rest :: binary >> = rest
      {split_count, split_id, split_index, rest}
    else
      {nil, nil, nil, rest}
    end

    if !(has_split in [0, 16]), do: throw "fail"

    << buffer :: binary-size(length), rest :: binary >> = rest

    {%{reliability: reliability, has_split: has_split, length: length, identifier_ack: identifier_ack, message_index: message_index, order_index: order_index, order_channel: order_channel, split_count: split_count, split_id: split_id, split_index: split_index, buffer: buffer}, rest}
  end

  def encode_encapsulated_packet(options, internal) do
    data = if internal do
      [<< options[:reliability] :: unsigned-size(3), options[:has_split] :: unsigned-size(5), byte_size(options[:buffer]) :: size(32), options[:identifier_ack] :: size(32) >>]
    else
      [<< options[:reliability] :: unsigned-size(3), options[:has_split] :: unsigned-size(5), trunc(byte_size(options[:buffer]) * 8) :: size(16) >>]
    end

    data = if options[:reliability] in [2, 3, 4, 6, 7] do
      [data, << options[:message_index] :: little-size(24) >>]
    else
      [data]
    end

    data = if options[:reliability] in [1, 3, 4] do
      [data, << options[:order_index] :: little-size(24), options[:order_channel] :: size(8) >>]
    else
      [data]
    end

    data = if options[:has_split] > 0 do
      [data, << options[:split_count] :: size(32), options[:split_id] :: size(16), options[:split_index] :: size(32) >>]
    else
      [data]
    end

    [data, options[:buffer]]
  end
end