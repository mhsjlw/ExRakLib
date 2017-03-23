defmodule RakNetTest do
  use ExUnit.Case
  doctest RakNet

  test "the truth" do
    assert 1 + 1 == 2
  end

  test "round trip ip address" do
  	ip = "192.168.0.1"

  	result = RakNet.Packet.write_ip_address(ip)
  		  |> RakNet.Packet.read_ip_address

  	assert ip == result
  end
  
  test "round trip triad" do
  	triad = [1, 2, 3]

  	result = RakNet.Packet.write_triad(triad)
  		  |> RakNet.Packet.read_triad

  	assert triad == result
  end
    
  test "round trip ltriad" do
  	triad = [1, 2, 3]

  	result = RakNet.Packet.write_ltriad(triad)
  		  |> RakNet.Packet.read_ltriad

  	assert triad == result
  end
  
  test "round trip string" do
  	string = "Hello!"

  	result = RakNet.Packet.write_string(string)
  		  |> RakNet.Packet.read_string

  	assert string == result
  end
  
  test "round trip bstring" do
  	string = "Hello!"

  	result = RakNet.Packet.write_bstring(string)
  		  |> RakNet.Packet.read_bstring

  	assert string == result
  end
end