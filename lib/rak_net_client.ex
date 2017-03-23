defmodule RakNet.Client do
  def start_link(socket, host, port) do
    {:ok, Task.start_link(fn -> loop(socket, host, port) end)}
  end

  defp loop(socket, host, port) do
    receive do
      {identifier, packet} ->
        case identifier do
          # handle all packet logic
          _ -> "shouldn't happen once every packet is implemented"
        end
    end
    loop(socket, host, port)
  end
end