defmodule Typesense.Middleware.CycleNodes do
  @moduledoc """
  Internal middleware that combines Tesla's Retry and BaseURL middlewares to try different nodes whenever requests fail.

  The base URL is set based on the first available node, preferring the nearest node option when set.
  Whenever a request fails, that node will be marked as unavailable and the next node will be chosen, based on order in the config and availability.

  A node is considered available as long as no requests to it failed within the configured `healthcheck_interval`.
  """

  alias Typesense.Healthcheck

  @behaviour Tesla.Middleware

  @impl Tesla.Middleware
  def call(env, next, opts) do
    opts = opts || []

    context = %{
      retries: 0,
      nearest_node: Keyword.get(opts, :nearest_node) |> node_url(),
      nodes: Keyword.get(opts, :nodes, []) |> Enum.map(&node_url/1),
      delay: Keyword.get(opts, :retry_interval, 1),
      max_retries: Keyword.get(opts, :max_retries, 0),
      should_retry: Keyword.get(opts, :should_retry, &match?({:error, _}, &1)),
      healthcheck_interval: Keyword.get(opts, :healthcheck_interval, 2_000),
      url: env.url,
      current_node: nil,
      current_node_index: -1,
      fallback_attempts: 0
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
      :timer.sleep(context.delay)
      context = update_in(context, [:retries], &(&1 + 1))
      {env, context} = apply_next_node(env, context)
      retry(env, next, context)
    else
      res
    end
  end

  defp apply_next_node(env, context) do
    fail_health_check(context)
    {context, node} = get_next_node(context)

    apply_node(env, context, node)
  end

  defp get_next_node(%{nearest_node: nearest_node} = context) when nearest_node !== nil do
    if Healthcheck.is_viable(
         context.nearest_node,
         context.healthcheck_interval
       ) do
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
           healthcheck_interval: healthcheck_interval,
           current_node_index: index,
           fallback_attempts: attempts
         } = context
       ) do
    index = Integer.mod(index + 1, length(nodes))
    node_url = Enum.at(nodes, index)

    context = %{context | current_node_index: index, fallback_attempts: attempts - 1}

    cond do
      Healthcheck.is_viable(node_url, healthcheck_interval) ->
        {context, node_url}

      attempts > 1 ->
        fallback_node(%{context | fallback_attempts: attempts - 1})

      true ->
        {context, node_url}
    end
  end

  # Set the base url in env and update context
  def apply_node(env, context, current_node) do
    {%{env | url: join_paths(current_node, context.url)}, %{context | current_node: current_node}}
  end

  defp node_url(nil), do: nil

  defp node_url(raw_node) do
    node = Enum.into(raw_node, %{})
    "#{node.protocol}://#{node.host}:#{node.port}/"
  end

  defp fail_health_check(%{current_node: nil}), do: nil

  defp fail_health_check(%{current_node: current_node}) do
    Healthcheck.fail_check(current_node)
  end

  # Join paths, from Tesla.Middleware.BaseUrl
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
end
