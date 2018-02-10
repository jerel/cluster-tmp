defmodule LonestarTest do
  use ExUnit.Case
  doctest Lonestar

  test "greets the world" do
    assert Lonestar.hello() == :world
  end
end
