defmodule Typesense.Overrides do
  @moduledoc """
  Create API Keys with fine-grain access control. You can restrict access on both a per-collection and per-action level.
  """

  def upsert(client, collection_id, override_id, override_props) do
    client
    |> Tesla.put("/collections/#{collection_id}/overrides/#{override_id}", override_props)
  end

  def list(client, collection_id) do
    client
    |> Tesla.get("/collections/#{collection_id}/overrides")
  end

  def retrieve(client, collection_id, override_id) do
    client
    |> Tesla.get("/collections/#{collection_id}/overrides/#{override_id}")
  end
end
