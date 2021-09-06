defmodule Typesense do
  @moduledoc """
  Documentation for `Typesense`.
  """

  alias Typesense.Config

  # build dynamic client based on runtime arguments
  def client(opts \\ []) do
    middleware = [
      Typesense.Middleware.FormatResponse,
      {Tesla.Middleware.BaseUrl, Config.resolve(:base_url, opts)},
      {Tesla.Middleware.Headers, [{"x-typesense-api-key", Config.resolve(:api_key, opts)}]},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware)
  end
end
