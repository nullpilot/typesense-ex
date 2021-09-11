defmodule Typesense.Middleware.CycleNodes do
  @moduledoc """
  Cycle through a list of node if requests fail.

  Heavily based on Tesla's Retry middleware.

  ## Options

  - `:delay` - The base delay in milliseconds (positive integer, defaults to 50)
  - `:max_retries` - maximum number of retries (non-negative integer, defaults to 5)
  - `:max_delay` - maximum delay in milliseconds (positive integer, defaults to 5000)
  - `:should_retry` - function to determine if request should be retried
  - `:jitter_factor` - additive noise proportionality constant
      (float between 0 and 1, defaults to 0.2)
  """

  @behaviour Tesla.Middleware

  @defaults [
    delay: 50,
    max_retries: 5,
    max_delay: 5_000,
    jitter_factor: 0.2
  ]

  @impl Tesla.Middleware
  def call(env, next, opts) do
    opts = opts || []

    context = %{
      retries: 0,
      nearest_node: Keyword.get(opts, :nearest_node) |> valid_node(),
      nodes: Keyword.get(opts, :nodes, []) |> Enum.map(&valid_node/1),
      delay: integer_opt!(opts, :retry_interval, 1),
      max_retries: integer_opt!(opts, :max_retries, 0),
      should_retry: Keyword.get(opts, :should_retry, &match?({:error, _}, &1)),
      healthcheck_interval: integer_opt!(opts, :healthcheck_interval, 2_000),
      url: env.url,
      current_node: nil,
      current_node_index: -1,
      fallback_attempts: 0,
      node_health: %{}
    }

    {env, context} = apply_next_node(env, context)

    retry(env, next, context)
  end

  # If we have max retries set to 0 don't retry
  defp retry(env, next, %{max_retries: 0}) do
    Tesla.run(env, next)
  end

  # If we're on our last retry then just run and don't handle the error
  defp retry(env, next, %{max_retries: max, retries: max}) do
    Tesla.run(env, next)
  end

  # Otherwise we retry if we get a retriable error
  defp retry(env, next, context) do
    res = Tesla.run(env, next)

    if context.should_retry.(res) do
      backoff(context.delay)
      context = update_in(context, [:retries], &(&1 + 1))
      {env, context} = apply_next_node(env, context)
      retry(env, next, context)
    else
      res
    end
  end

  # Exponential backoff with jitter
  defp backoff(delay) do
    :timer.sleep(delay)
  end

  defp apply_next_node(env, context) do
    context = fail_health_check(context)
    {context, node} = get_next_node(context)

    apply_node(env, context, node)
  end

  defp get_next_node(%{nearest_node: nearest_node} = context) when nearest_node !== nil do
    if is_node_viable(context.node_health, context.nearest_node, context.healthcheck_interval) do
      {context, nearest_node}
    else
      fallback_node(%{context | fallback_attempts: length(context.nodes)})
    end
  end

  defp get_next_node(context),
    do: fallback_node(%{context | fallback_attempts: length(context.nodes)})

  defp fallback_node(
         %{
           nodes: nodes,
           node_health: node_health,
           healthcheck_interval: healthcheck_interval,
           current_node_index: index,
           fallback_attempts: attempts
         } = context
       ) do
    index = Integer.mod(index + 1, length(nodes))
    node = Enum.at(nodes, index)

    context = %{context | current_node_index: index, fallback_attempts: attempts - 1}

    cond do
      is_node_viable(node_health, node, healthcheck_interval) -> {context, node}
      attempts > 1 -> fallback_node(%{context | fallback_attempts: attempts - 1})
      true -> {context, node}
    end
  end

  # Checks if the node is either healthy, or enough time has passed to check if it has recovered.
  defp is_node_viable(node_health, node_url, healthcheck_interval) do
    case Map.get(node_health, node_url) do
      nil -> true
      last_failure -> System.system_time(:millisecond) - healthcheck_interval > last_failure
    end
  end

  # Set the base url in env and update context
  def apply_node(env, context, current_node) do
    {%{env | url: join_paths(current_node, context.url)}, %{context | current_node: current_node}}
  end

  defp valid_node(nil), do: nil

  defp valid_node(raw_node) do
    node = Enum.into(raw_node, %{})
    "#{node.protocol}://#{node.host}:#{node.port}/"
  end

  defp fail_health_check(%{current_node: nil} = context), do: context

  defp fail_health_check(%{current_node: current_node, node_health: node_health} = context) do
    node_health = Map.put(node_health, current_node, System.system_time(:millisecond))
    %{context | node_health: node_health}
  end

  # Join paths, taken from Tesla.Middleware.BaseUrl
  defp join_paths(base, url) do
    case {String.last(to_string(base)), url} do
      {nil, url} -> url
      {"/", "/" <> rest} -> base <> rest
      {"/", rest} -> base <> rest
      {_, ""} -> base
      {_, "/" <> rest} -> base <> "/" <> rest
      {_, rest} -> base <> "/" <> rest
    end
  end

  defp integer_opt!(opts, key, min) do
    case Keyword.fetch(opts, key) do
      {:ok, value} when is_integer(value) and value >= min -> value
      {:ok, invalid} -> invalid_integer(key, invalid, min)
      :error -> @defaults[key]
    end
  end

  defp invalid_integer(key, value, min) do
    raise(ArgumentError, "expected :#{key} to be an integer >= #{min}, got #{inspect(value)}")
  end
end
