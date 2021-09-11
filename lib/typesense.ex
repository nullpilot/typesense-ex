defmodule Typesense do
  @moduledoc """
  Documentation for `Typesense`.
  """

  alias Typesense.Config

  # build dynamic client based on runtime arguments
  def client(opts \\ []) do
    middleware = [
      Typesense.Middleware.FormatResponse,
      {Typesense.Middleware.CycleNodes,
       [
         nearest_node: Config.resolve(:nearest_node, opts),
         nodes: Config.resolve(:nodes, opts),
         max_retries: Config.resolve(:max_retries, opts),
         retry_interval: Config.resolve(:retry_interval, opts),
         healthcheck_interval: Config.resolve(:healthcheck_interval, opts),
         should_retry: fn
           {:ok, %{status: status}} when status in 500..599 -> true
           {:ok, _} -> false
           {:error, _} -> true
         end
       ]},
      {Tesla.Middleware.Logger, []},
      {Tesla.Middleware.Headers, [{"x-typesense-api-key", Config.resolve(:api_key, opts)}]},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware)
  end
end
