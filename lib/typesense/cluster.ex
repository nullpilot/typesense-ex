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
  end

  def snapshot(client, snapshot_path) do
    client
    |> Tesla.post("/operations/snapshot", "", query: [snapshot_path: snapshot_path])
  end

  def perform_vote(client) do
    client
    |> Tesla.post("/operations/vote", "")
  end
end
