defmodule Lonestar.App do
  @moduledoc false
  use Supervisor

  def start(_, _) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    children = [
      {Lonestar.Debug, node()},
      {Task, &__MODULE__.load_vehicles/0},
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end

  def load_vehicles() do
    1..500
    |> Enum.each(fn id ->
      {:ok, pid} = Lonestar.Vehicle.run(id)
    end)
  end
end
