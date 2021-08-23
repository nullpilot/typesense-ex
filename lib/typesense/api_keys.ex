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

  def list(client) do
    client
    |> Tesla.get("/keys")
  end

  def delete(client, key_id) do
    client
    |> Tesla.delete("/keys/#{key_id}")
  end

  def generate_scoped_search_key(search_key, embedded_params) do
    digest = Base.encode64(:crypto.mac(:hmac, :sha256, search_key, embedded_params))
    trimmed_api_key = String.slice(search_key, 0, 4)

    "#{digest}#{trimmed_api_key}#{embedded_params}"
    |> Base.encode64()
  end
end
