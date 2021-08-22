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

  def update(client, collection, document_id, document) do
    client
    |> Tesla.patch("/collections/#{collection}/documents/#{document_id}", document)
  end

  def retrieve(client, collection, document_id) do
    client
    |> Tesla.get("/collections/#{collection}/documents/#{document_id}")
  end

  def search(client, collection, search_params) do
    client
    |> Tesla.get("/collections/#{collection}/documents/search", query: search_params)
  end

  def multi_search(client, search_requests, common_params \\ %{}) do
    client
    |> Tesla.post("/multi_search", %{searches: search_requests}, query: common_params)
  end
end
