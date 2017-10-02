defmodule Util.Pid do
  def serialize(pid) when is_pid(pid) do
    pid
    |> :erlang.pid_to_list
    |> :erlang.list_to_binary
  end

  def deserialize("#PID" <> string), do: deserialize(string)
  def deserialize(string) do
    string
    |> :erlang.binary_to_list
    |> :erlang.list_to_pid
  end
end
