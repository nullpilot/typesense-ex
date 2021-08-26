defmodule Typesense.Aliases do
  @moduledoc """
  Manage collection aliases.
  """

  def upsert(client, collection_alias, collection_name) do
    client
    |> Tesla.put("/aliases/#{collection_alias}", %{collection_name: collection_name})
  end
end
