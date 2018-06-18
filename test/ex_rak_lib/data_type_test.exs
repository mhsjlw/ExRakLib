defmodule ExRakLibTest.DataTypeTest do
  use ExUnit.Case, async: true

  import ExRakLib.DataTypes

  @address {192, 168, 0, 1}
  @triad 1
  @string "Hello!"
  @destination %{version: 4, address: @address, port: 12345}

  test "ip address" do
    {result, _} =
      encode_ip_address(@address)
      |> decode_ip_address

    assert result == @address
  end

  test "triad" do
    {result, _} =
      encode_triad(@triad)
      |> decode_triad

    assert result == @triad
  end

  test "little triad" do
    {result, _} =
      encode_ltriad(@triad)
      |> decode_ltriad

    assert result == @triad
  end

  test "string" do
    {result, _} =
      encode_string(@string)
      |> decode_string

    assert result == @string
  end

  test "byte prefixed string" do
    {result, _} =
      encode_bstring(@string)
      |> decode_bstring

    assert result == @string
  end

  test "address port" do
    {result, _} =
      encode_address_port(@destination)
      |> decode_address_port

    assert result == @destination
  end
end
