defmodule RakNet.DataTypes do 

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
end