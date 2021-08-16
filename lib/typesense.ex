defmodule Typesense do
  @moduledoc """
  Documentation for `Typesense`.
  """

  @doc """
  Get health information about a Typesense node.

  ## Examples

      iex> Typesense.health()
      :ok

  """
  def health() do
    client('xyz')
    |> Tesla.get("/health")
  end

  # build dynamic client based on runtime arguments
  def client(token) do
    middleware = [
      {Tesla.Middleware.BaseUrl, "http://localhost:8108"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"x-typesense-api-key", token}]}
    ]

    Tesla.client(middleware)
  end

end
