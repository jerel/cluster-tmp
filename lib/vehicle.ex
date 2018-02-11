defmodule Lonestar.Vehicle do
  use GenServer

  def run(id) do
    name = {:vehicle, id}
    with :undefined <- Swarm.whereis_name(name),
      {:ok, pid} <- Swarm.register_name(name, __MODULE__, :start, ["#{id}"])
    do
      {:ok, pid}
    else
      pid when is_pid(pid) ->
        {:ok, pid}
      {:error, {:already_registered, pid}} ->
        {:ok, pid}
      {:error, _} = err ->
        err
    end
  end

  def start(id) do
    GenServer.start(__MODULE__, id)
  end

  def init(id) do
    {:ok, id}
  end

  def handle_call({:swarm, :begin_handoff}, _from, state) do
    {:reply, {:resume, state}, state}
  end

  def handle_cast({:swarm, :end_handoff, _old_state}, state) do
    {:noreply, state}
  end

  def handle_cast({:swarm, :resolve_conflict, _other_state}, state) do
    {:noreply, state}
  end

  def handle_info({:swarm, :die}, state) do
    {:stop, :shutdown, state}
  end
end
