defmodule Typesense.Cluster do
  @moduledoc """
  Cluster and node operations
  """

  @doc """
  Get health information about a Typesense node.

  ## Examples

      iex> Typesense.health()
      :ok

  """

  def health(client) do
    client
    |> Tesla.get("/health")
  end
end
