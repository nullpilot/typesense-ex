defmodule Typesense.ApiCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  alias Typesense.Config

  using do
    quote do
      import Typesense.Factory

      alias Typesense.Error.{
        HTTPError,
        MissingConfiguration,
        ObjectAlreadyExists,
        ObjectNotFound,
        ObjectUnprocessable,
        RequestMalformed,
        RequestUnauthorized,
        ServerError,
        TimeoutError
      }
    end
  end

  setup_all do
    middleware = [
      Typesense.Middleware.FormatResponse,
      {Tesla.Middleware.Headers, [{"x-typesense-api-key", Config.resolve(:api_key)}]},
      {Tesla.Middleware.BaseUrl, node_url(Config.resolve(:nearest_node))},
      Tesla.Middleware.JSON
    ]

    client = Tesla.client(middleware)

    {:ok, %{client: client}}
  end

  defp node_url(raw_node) do
    node = Enum.into(raw_node, %{})
    "#{node.protocol}://#{node.host}:#{node.port}/"
  end
end
