defmodule Typesense.Synonyms do
  @moduledoc """
  Manage synonyms for search terms.
  """

  def upsert(client, collection_id, synonym_id, synonyms) do
    client
    |> Tesla.put("/collections/#{collection_id}/synonyms/#{synonym_id}", synonyms)
  end

  def list(client, collection_id) do
    client
    |> Tesla.get("/collections/#{collection_id}/synonyms")
  end

  def retrieve(client, collection_id, synonym_id) do
    client
    |> Tesla.get("/collections/#{collection_id}/synonyms/#{synonym_id}")
  end

  def delete(client, collection_id, synonym_id) do
    client
    |> Tesla.delete("/collections/#{collection_id}/synonyms/#{synonym_id}")
  end
end
