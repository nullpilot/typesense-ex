defmodule Typesense.Cluster do
  @moduledoc """
  Cluster and node operations
  """

  @doc """
  Get health information about a Typesense node.

  ## Examples

      iex> Typesense.health()
      :ok

  """

  def health(client) do
    client
    |> Tesla.get("/health")
    |> Typesense.ApiCall.handle_response()
  end

  def snapshot(client, snapshot_path) do
    client
    |> Tesla.post("/operations/snapshot", "", query: [snapshot_path: snapshot_path])
  end

  def perform_vote(client) do
    client
    |> Tesla.post("/operations/vote", "")
  end

  def toggle_slow_request_log(client, threshold_in_ms) do
    client
    |> Tesla.post("/config", %{
      "log-slow-requests-time-ms" => threshold_in_ms
    })
  end

  def metrics(client) do
    client
    |> Tesla.get("/metrics.json")
  end

  def stats(client) do
    client
    |> Tesla.get("/stats.json")
  end
end
