defmodule Typesense.Aliases do
  @moduledoc """
  Manage collection aliases.
  """

  def upsert(client, collection_alias, collection_name) do
    client
    |> Tesla.put("/aliases/#{collection_alias}", %{collection_name: collection_name})
  end

  def list(client) do
    client
    |> Tesla.get("/aliases")
  end

  def retrieve(client, collection_alias) do
    client
    |> Tesla.get("/aliases/#{collection_alias}")
  end
end
