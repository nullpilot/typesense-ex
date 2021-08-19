defmodule Typesense.Documents do
  @moduledoc """
  Index, search and manage documents
  """

  def create(client, collection, document) do
    client
    |> Tesla.post("/collections/#{collection}/documents", document)
  end

  def upsert(client, collection, document) do
    client
    |> Tesla.post("/collections/#{collection}/documents", document, query: [action: "upsert"])
  end
end
