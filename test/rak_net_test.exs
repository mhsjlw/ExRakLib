defmodule RakNetTest do
  use ExUnit.Case
  doctest RakNet

  test "round trip ip address" do
  	ip = {192, 168, 0, 1}

  	result = RakNet.DataTypes.write_ip_address(ip)
  		  |> RakNet.DataTypes.read_ip_address

  	assert ip == result
  end
  
  test "round trip triad" do
  	triad = 1

  	result = RakNet.DataTypes.write_triad(triad)
  		  |> RakNet.DataTypes.read_triad

  	assert triad == result
  end
    
  test "round trip ltriad" do
  	triad = 1

  	result = RakNet.DataTypes.write_ltriad(triad)
  		  |> RakNet.DataTypes.read_ltriad

  	assert triad == result
  end
  
  test "round trip string" do
  	string = "Hello!"

  	result = RakNet.DataTypes.write_string(string)
  		  |> RakNet.DataTypes.read_string

  	assert string == result
  end
  
  test "round trip bstring" do
  	string = "Hello!"

  	result = RakNet.DataTypes.write_bstring(string)
  		  |> RakNet.DataTypes.read_bstring

  	assert string == result
  end

  test "round trip address port" do
    destination = %{version: 4, address: {192, 168, 0, 1}, port: 12345}

    result = RakNet.DataTypes.write_address_port(destination)
        |> RakNet.DataTypes.read_address_port

    assert destination == result
  end
end