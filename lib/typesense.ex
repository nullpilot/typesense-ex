defmodule Typesense do
  @moduledoc """
  Documentation for `Typesense`.
  """

  # build dynamic client based on runtime arguments
  def client(opts \\ []) do
    middleware = [
      {Tesla.Middleware.BaseUrl, base_url(opts)},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"x-typesense-api-key", api_key(opts)}]}
    ]

    Tesla.client(middleware)
  end

  defp base_url(opts) do
    base_url = Keyword.get(opts, :base_url, false) || runtime_base_url()

    unless base_url do
      raise """
        No base URL configured.
      """
    end

    base_url
  end

  defp runtime_base_url do
    case Application.get_env(:typesense, :base_url) do
      {:system, env_key} -> System.get_env(env_key)
      key -> key
    end
  end

  defp api_key(opts) do
    api_key = Keyword.get(opts, :api_key) || runtime_api_key()

    unless api_key do
      raise """
        No API key configured.
      """
    end

    api_key
  end

  defp runtime_api_key do
    case Application.get_env(:typesense, :api_key) do
      {:system, env_key} -> System.get_env(env_key)
      key -> key
    end
  end
end
