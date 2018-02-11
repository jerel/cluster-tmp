defmodule Lonestar.Debug do
  use GenServer

  def start_link(node_name) do
    GenServer.start_link(__MODULE__, node_name, name: __MODULE__)
  end

  def init(node_name) do
    {:ok, node_name, 500}
  end

  def handle_info(:timeout, :"debug@127.0.0.1" = state) do
    Logger.configure(level: :error)
    spawn_link(fn ->
      from = self()
      results =
        Node.list()
        |> Enum.sort()
        |> Enum.reverse()
        |> Enum.map(fn name ->
          pid = Node.spawn_link(name, fn ->
            count = local()

            send(from, {self(), count})
          end)
          {name, pid}
        end)
        |> Enum.map(fn {name, pid} ->
          receive do
            {^pid, count} -> {name, count}
          after 1_000 ->
            {name, 0}
          end
        end)

      results
      |> Keyword.keys()
      |> Enum.reduce("", fn name, acc ->
        "| #{name} " <> acc
      end)
      |> Kernel.<>("|       Total ")
      |> Kernel.<>("|       debug ")
      |> IO.inspect()

      values =
        results
        |> Keyword.values()

      [local(), Enum.sum(values) | values]
      |> fixed_width("")
      |> IO.inspect()
    end)

    {:noreply, state, 500}
  end

  def handle_info(:timeout, _) do
    {:noreply, :shutdown}
  end

  def fixed_width([head | tail], acc) do
    fixed_width(tail, "| #{:io_lib.format("~11.. B", [head])} " <> acc)
  end
  def fixed_width([], acc), do: acc

  def local() do
    Swarm.registered()
    |> Enum.filter(fn {_, pid} -> node(pid) == node() end)
    |> length()
  end
end
