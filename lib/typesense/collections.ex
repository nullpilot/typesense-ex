defmodule Typesense.Collections do
  @moduledoc """
  Create and retrieve collections
  """

  def create(client, schema) do
    client
    |> Tesla.post("/collections", schema)
  end

  def retrieve(client, collection) do
    client
    |> Tesla.get("/collections/#{collection}")
  end

  def list(client) do
    client
    |> Tesla.get("/collections")
  end

  def delete(client, collection) do
    client
    |> Tesla.delete("/collections/#{collection}")
  end
end
