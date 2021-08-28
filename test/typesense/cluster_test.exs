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

  test "creates a snapshot", %{client: client} do
    snapshot_path = "/tmp/typesense-data-snapshot"

    assert {:ok, %Tesla.Env{} = env} = Typesense.Cluster.snapshot(client, snapshot_path)
    assert env.status == 201
    assert env.body == %{"success" => true}
  end

  test "initiates leader vote", %{client: client} do
    assert {:ok, %Tesla.Env{} = env} = Typesense.Cluster.perform_vote(client)
    assert env.status == 200
    assert env.body == %{"success" => true}
  end
end
