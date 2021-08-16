defmodule Typesense.ClusterTest do
  use ExUnit.Case

  setup do
    client = Typesense.client()

    {:ok, %{client: client}}
  end

  test "checks connectivity to healthy Typesense node", %{client: client} do
    assert {:ok, %Tesla.Env{} = env} = Typesense.Cluster.health(client)
    assert env.status == 200
    assert env.body == %{"ok" => true}
  end
end
