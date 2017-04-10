defmodule RakNetTest do
  use ExUnit.Case
  doctest RakNet

  @address {192, 168, 0, 1}
  @triad 1
  @string "Hello!"
  @destination %{version: 4, address: @address, port: 12345}

  test "round trip ip address" do
  	{result, _} = RakNet.DataTypes.encode_ip_address(@address)
  		         |> RakNet.DataTypes.decode_ip_address

  	assert result == @address
  end
  
  test "round trip triad" do
  	{result, _} = RakNet.DataTypes.encode_triad(@triad)
  	           |> RakNet.DataTypes.decode_triad

  	assert result == @triad
  end
    
  test "round trip ltriad" do
  	{result, _} = RakNet.DataTypes.encode_ltriad(@triad)
  		         |> RakNet.DataTypes.decode_ltriad

  	assert result == @triad
  end
  
  test "round trip string" do
  	{result, _} = RakNet.DataTypes.encode_string(@string)
  		         |> RakNet.DataTypes.decode_string

  	assert result == @string
  end
  
  test "round trip bstring" do
  	{result, _} = RakNet.DataTypes.encode_bstring(@string)
  		         |> RakNet.DataTypes.decode_bstring

  	assert result == @string
  end

  test "round trip address port" do
    {result, _} = RakNet.DataTypes.encode_address_port(@destination)
               |> RakNet.DataTypes.decode_address_port

    assert result == @destination
  end
end