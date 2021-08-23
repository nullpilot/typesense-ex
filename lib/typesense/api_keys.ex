defmodule Typesense.ApiKeys do
  @moduledoc """
  Create API Keys with fine-grain access control. You can restrict access on both a per-collection and per-action level.
  """

  def create(client, key_props) do
    client
    |> Tesla.post("/keys", key_props)
  end

  def retrieve(client, key_id) do
    client
    |> Tesla.get("/keys/#{key_id}")
  end
end
