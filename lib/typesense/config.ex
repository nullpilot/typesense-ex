defmodule Typesense.Config do
  @moduledoc false

  def resolve(key, opts \\ []) when is_atom(key) do
    expand_value(key, Keyword.get(opts, key) || runtime_opt(key))
  end

  defp runtime_opt(opt_key) do
    case Application.get_env(:typesense, opt_key) do
      {:system, env_key} -> System.get_env(env_key) || {:error, env_key}
      opt -> opt
    end
  end

  defp expand_value(key, {:error, env_key}), do: raise(opt_error(key, env_key))
  defp expand_value(key, nil), do: raise(opt_error(key))
  defp expand_value(_key, value), do: value

  defp opt_error(opt_key), do: "Required option `#{opt_key}` not configured."

  defp opt_error(opt_key, env_key),
    do: """
      #{env_key} is not set at runtime. Set environment variable or set #{opt_key} in your config.
    """
end
