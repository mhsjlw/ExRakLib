defmodule RakNet.DataTypes do
  use Bitwise
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

  def decode_data_packet(<< sequence_number :: little-size(24), encapsulated_packets :: binary >>) do
    packet = decode_encapsulated_packet(encapsulated_packets, false)

    decode_data_packet(packet[:rest], sequence_number, [Map.pop(packet, :rest)])
  end

  defp decode_data_packet(binary, sequence_number, encapsulated_packets) do
    packet = decode_encapsulated_packet(binary, false)
    decode_data_packet(packet[:rest], sequence_number, encapsulated_packets ++ packet)
  end

  defp decode_data_packet("", sequence_number, encapsulated_packets) do
    %{sequence_number: sequence_number, encapsulated_packets: encapsulated_packets}
  end

  def encode_data_packet(%{sequence_number: sequence_number, encapsulated_packets: encapsulated_packets}) do
    data = << sequence_number :: little-size(24) >>
    Enum.map(encapsulated_packets, fn(x) -> data <> x end)
    data
  end

  def decode_encapsulated_packet(data, internal) do
    << reliabilty :: unsigned-size(3), has_split :: unsigned-size(5), rest :: binary >> = data

    {length, identifier_ack, rest} = if internal do
      << length :: size(32), identifier_ack :: size(32), rest :: binary >> = rest
      {length, identifier_ack, rest}
    else
      << length :: size(16), rest :: binary >> = rest
      Logger.info("#{inspect length}")
      {trunc(Float.ceil(length / 8)), nil, rest}
    end

    {message_index, rest} = if reliabilty > 0 && reliabilty >= 2 && reliabilty != 5 do
      << message_index :: little-size(24), rest :: binary >> = rest
      {message_index, rest}
    else
      {nil, rest}
    end

    {order_index, order_channel, rest} = if reliabilty > 0 && reliabilty <= 4 && reliabilty != 2 do
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

    length = trunc(Float.ceil(length / 2))
    Logger.info("#{inspect length}")
    << buffer :: size(length), rest :: binary >> = rest

    %{reliabilty: reliabilty, has_split: has_split, length: length, identifier_ack: identifier_ack, message_index: message_index, order_index: order_index, order_channel: order_channel, split_count: split_count, split_id: split_id, split_index: split_index, buffer: buffer, rest: rest}
  end

  def encode_encapsulated_packet(options, internal) do
    {data} = if internal do
      << options[:reliabilty] :: unsigned-size(3), options[:has_split] :: unsigned-size(5), byte_size(options[:buffer]) :: size(32), options[:identifier_ack] :: size(32) >>
    else
      << options[:reliabilty] :: unsigned-size(3), options[:has_split] :: unsigned-size(5), byte_size(options[:buffer]) <<< 3 :: size(16) >>
    end 

    {data} = if options[:reliabilty] > 0 && options[:reliabilty] >= 2 && options[:reliabilty] != 5 do
      data <> << options[:message_index] :: little-size(24) >>
    end

    {data} = if options[:reliabilty] > 0 && options[:reliabilty] <= 4 && options[:reliabilty] != 2 do
      data <> << options[:order_index] :: little-size(24), options[:order_index] :: size(8) >>
    end

    {data} = if options[:has_split] do
      data <> << options[:split_count] :: size(32), options[:split_id] :: size(16), options[:split_index] :: size(32) >>
    end

    data <> options[:buffer]
  end
end