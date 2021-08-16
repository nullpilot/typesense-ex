defmodule TypesenseTest do
  use ExUnit.Case
  # doctest Typesense

  test "checks connectivity to healthy Typesense node" do
    assert {:ok, %Tesla.Env{} = env} = Typesense.health()
    assert env.status == 200
    assert env.body == %{"ok" => true}
  end
end
