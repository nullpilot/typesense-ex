defmodule Typesense.ClusterTest do
  use ExUnit.Case

  setup do
    client = Typesense.client()

    {:ok, %{client: client}}
  end

  test "checks connectivity to healthy Typesense node", %{client: client} do
    assert {:ok, %{"ok" => true}} = Typesense.Cluster.health(client)
  end

  test "creates a snapshot", %{client: client} do
    snapshot_path = "/tmp/typesense-data-snapshot"
    assert {:ok, %{"success" => true}} = Typesense.Cluster.snapshot(client, snapshot_path)
  end

  test "initiates leader vote", %{client: client} do
    assert {:ok, %{"success" => _}} = Typesense.Cluster.perform_vote(client)
  end

  test "toggle slow request logs", %{client: client} do
    assert {:ok, %{"success" => true}} = Typesense.Cluster.toggle_slow_request_log(client, 50)
  end

  test "get cluster metrics", %{client: client} do
    assert {:ok, %{"system_disk_used_bytes" => _}} = Typesense.Cluster.metrics(client)
  end

  test "get api stats", %{client: client} do
    assert {:ok, %{"latency_ms" => _}} = Typesense.Cluster.stats(client)
  end
end
