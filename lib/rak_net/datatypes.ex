defmodule RakNet.DataTypes do 
  use Bitwise

  def read_ip_address(buffer) do
    << first :: unsigned-size(8), second :: unsigned-size(8), third :: unsigned-size(8), fourth :: unsigned-size(8) >> = buffer
    {first, second, third, fourth}
  end
  
  def write_ip_address({first, second, third, fourth}) do
    << first :: unsigned-size(8), second :: unsigned-size(8), third :: unsigned-size(8), fourth :: unsigned-size(8) >>
  end
  
  def read_triad(buffer) do
    << triad :: size(24) >> = buffer
    triad
  end
  
  def write_triad(triad) do
    << triad :: size(24) >>
  end
  
  def read_ltriad(buffer) do
    << triad :: little-size(24) >> = buffer
    triad
  end
  
  def write_ltriad(triad) do
    << triad :: little-size(24) >>
  end
  
  def read_string(buffer) do
    << prefix :: unsigned-size(16), string :: binary-size(prefix) >> = buffer
    string
  end
  
  def write_string(string) do
    << byte_size(string) :: unsigned-size(16), string :: bitstring >>
  end
  
  def read_bstring(buffer) do
    << prefix :: unsigned-size(8), string :: binary-size(prefix) >> = buffer
    string
  end
  
  def write_bstring(string) do
    << byte_size(string) :: unsigned-size(8), string :: bitstring >>
  end
  
  def read_address_port(buffer) do
    << version :: size(8), address :: binary-size(4), port :: unsigned-size(16) >> = buffer
    %{version: 4, address: read_ip_address(address), port: port}
  end
  
  def write_address_port(destination) do
    << 4 :: size(8), write_ip_address(destination[:address]) :: binary, destination[:port] :: unsigned-size(16) >>
  end

  def write_encapsulated(encapsulated, internal \\ false) do
    reliability = encapsulated[:reliability]
    has_split = encapsulated[:has_split] || false
    length = encapsulated[:length] || 0
    message_index = encapsulated[:message_index] || nil
    order_index = encapsulated[:order_index] || nil
    order_channel = encapsulated[:order_channel] || nil
    split_count = encapsulated[:split_count] || nil
    split_id = encapsulated[:split_id] || nil
    split_index = encapsulated[:split_index] || nil
    buffer = encapsulated[:buffer]
    need_ack = encapsulated[:need_ack] || false
    identifier_ack = encapsulated[:identifier_ack] || nil

    payload = << >>

    if has_split do
      payload ++ << ((reliability <<< 5) ||| 0b00010000) :: size(8) >>
    else
      payload ++ << (reliability <<< 5) :: size(8) >>
    end

    if internal do
      payload ++ << byte_size(buffer) :: size(32) >>
      payload ++ << identifier_ack :: size(32) >>
    else
      payload ++ << (byte_size(buffer) <<< 3) :: size(32) >>
    end

    if reliability > 0 do
      if (reliability > 2 || reliability == 2) && reliability != 5 do
        payload ++ << write_ltriad(message_index) :: binary >>
      end
      if (reliability < 4 || reliability == 4) && reliability != 2 do
        payload ++ << write_ltriad(order_index) :: binary >>
        payload ++ << order_channel :: size(8) >>
      end
    end

    if has_split do
      payload ++ << split_count :: size(32), split_id :: size(16), split_index :: size(32) >>
    end

    payload ++ buffer
  end

  def read_encapsulated(buffer, internal \\ false) do
    << flags :: size(8), rest :: binary >> = buffer

    reliability = (flags &&& 0b11100000) >>> 5
    has_split = (flags &&& 0b00010000) > 0

    [length, identifier_ack, rest] = if internal do
      << length :: size(32), identifier_ack :: size(32), rest :: binary >> = rest
      [length, identifier_ack, rest]
    else
      << length :: size(16), rest :: binary >> = rest
      identifier_ack = false
      [length, identifier_ack, rest]
    end

    [message_index, rest] = if reliability > 0 do
      [message_index, rest] = if (reliability > 2 || reliability == 2) && reliability != 5 do
        << message_index :: little-size(24), rest :: binary >> = rest
        [message_index, rest]
      end
    end

    [order_index, order_channel, rest] = if reliability > 0 do
      [order_index, order_channel, rest] = if (reliability < 4 || reliability == 2) && reliability != 2 do
        << order_index :: little-size(24), order_channel :: size(8), rest :: binary >> = rest
        [order_index, order_channel, rest]
      end
    end

    [split_count, split_id, split_index, rest] = if has_split do
      << split_count :: size(32), split_id :: size(16), split_index :: size(32), rest :: binary >> = rest
      [split_count, split_id, split_index, rest]
    end

    %{
      reliability: reliability,
      has_split: has_split || false,
      length: length || 0,
      message_index: message_index || nil,
      order_index: order_index || nil,
      order_channel: order_channel || nil,
      split_count: split_count || nil,
      split_id: split_id || nil,
      split_index: split_index || nil,
      buffer: rest,
      need_ack: false,
      identifier_ack: identifier_ack || nil,
    }
  end

  def write_data_packet(packets, sequence_number) do
    sequence_number = write_ltriad(sequence_number)
    [head | tail] = packets

    buffer = << sequence_number :: buffer, head :: binary >>
    write_data_packet(packets, sequence_number, tail)
  end

  def write_data_packet(packets, sequence_number, buffer) do
    [head | tail] = packets
    buffer ++ << buffer :: binary >>
    write_data_packet(packets, sequence_number, buffer) 
  end

  def write_data_packet([], sequence_number, buffer) do
    buffer
  end

  def read_data_packet(buffer) do
    # how u do ?! 
    # << sequence_number :: little-size(24), rest :: binary >> = buffer
    # encapsulated = read_encapsulated(buffer)
  end
end