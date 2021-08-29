defmodule Typesense do
  @moduledoc """
  Documentation for `Typesense`.
  """

  # build dynamic client based on runtime arguments
  def client(opts \\ []) do
    middleware = [
      {Tesla.Middleware.BaseUrl, get_opt(opts, :base_url)},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.Headers, [{"x-typesense-api-key", get_opt(opts, :api_key)}]}
    ]

    Tesla.client(middleware)
  end

  defp get_opt(opts, key) do
    opt = Keyword.get(opts, key) || runtime_opt(key)

    case opt do
      {:error, env_key} -> raise opt_error(key, env_key)
      nil -> raise opt_error(key)
      opt -> opt
    end
  end

  defp runtime_opt(opt_key) do
    case Application.get_env(:typesense, opt_key) do
      {:system, env_key} -> System.get_env(env_key) || {:error, env_key}
      opt -> opt
    end
  end

  defp opt_error(opt_key), do: "Required option `#{opt_key}` not configured."

  defp opt_error(opt_key, env_key),
    do: """
      #{env_key} is not set at runtime. Set environment variable or set #{opt_key} in your config.
    """
end
