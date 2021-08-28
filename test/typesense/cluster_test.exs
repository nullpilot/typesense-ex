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
    assert match?(%{"success" => _}, env.body)
  end

  test "toggle slow request logs", %{client: client} do
    assert {:ok, %Tesla.Env{} = env} = Typesense.Cluster.toggle_slow_request_log(client, 50)
    assert env.status == 201
    assert match?(%{"success" => _}, env.body)
  end

  test "get cluster metrics", %{client: client} do
    assert {:ok, %Tesla.Env{} = env} = Typesense.Cluster.metrics(client)
    assert env.status == 200
    assert match?(%{"system_disk_used_bytes" => _}, env.body)
  end

  test "get api stats", %{client: client} do
    assert {:ok, %Tesla.Env{} = env} = Typesense.Cluster.stats(client)
    assert env.status == 200
    assert match?(%{"latency_ms" => _}, env.body)
  end
end
