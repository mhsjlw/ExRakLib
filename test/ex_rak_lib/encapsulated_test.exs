defmodule ExRakLibTest.MultipleEncapsulatedTest do
  use ExUnit.Case, async: true

  import ExRakLib.DataTypes

  @string "Hello!"
  @data <<byte_size(@string)::size(8), @string::binary>>

  test "data packet with multiple encapsulated packets" do
    encapsulated_packet = %{
      sequence_number: 0,
      encapsulated_packets: [
        %{reliability: 2, has_split: 0, message_index: 0, buffer: @data},
        %{reliability: 2, has_split: 0, message_index: 0, buffer: @data}
      ]
    }

    encoded_data_packet = encode_data_packet(encapsulated_packet, false)
    data_packet = decode_data_packet(encoded_data_packet, false)

    [head | [tail | _]] = data_packet[:encapsulated_packets]

    assert head[:buffer] == @data && tail[:buffer] == @data
  end

  test "data packet with internal encapsulated packet" do
    encapsulated_packet = %{
      sequence_number: 0,
      encapsulated_packets: [
        %{reliability: 2, has_split: 0, message_index: 0, identifier_ack: 0, buffer: @data}
      ]
    }

    encoded_data_packet = encode_data_packet(encapsulated_packet, true)
    data_packet = decode_data_packet(encoded_data_packet, true)

    [head | _] = data_packet[:encapsulated_packets]

    assert head[:buffer] == @data
  end

  test "data packet with a split" do
    encapsulated_packet = %{
      sequence_number: 0,
      encapsulated_packets: [
        %{
          reliability: 2,
          has_split: 1,
          message_index: 0,
          identifier_ack: 0,
          buffer: @data,
          split_count: 0,
          split_id: 0,
          split_index: 0
        }
      ]
    }

    encoded_data_packet = encode_data_packet(encapsulated_packet, true)
    data_packet = decode_data_packet(encoded_data_packet, true)

    [head | _] = data_packet[:encapsulated_packets]

    assert head[:buffer] == @data && head[:has_split] > 0
  end
end
