defmodule Typesense.CycleNodesTest do
  use ExUnit.Case, async: true

  alias Tesla.Env
  alias Typesense.Healthcheck

  @middleware Typesense.Middleware.CycleNodes
  @healthy_node_url "http://localhost:8108/"
  @healthy_node [
    protocol: "http",
    host: "localhost",
    port: "8108"
  ]
  @unhealthy_node_url "http://unhealthy-node:8108/"
  @unhealthy_node [
    protocol: "http",
    host: "unhealthy-node",
    port: 8108
  ]

  setup_all do
    node = @unhealthy_node_url
    Healthcheck.fail_check(node)

    %{}
  end

  test "set base url from nearest node" do
    assert {:ok, env} =
             @middleware.call(%Env{url: ""}, [],
               nearest_node: @healthy_node,
               nodes: []
             )

    assert env.url == @healthy_node_url
  end

  test "set base url with retries" do
    assert {:ok, env} =
             @middleware.call(%Env{url: ""}, [],
               max_retries: 3,
               nearest_node: @healthy_node,
               nodes: []
             )

    assert env.url == @healthy_node_url
  end

  test "set base url from fallback node" do
    assert {:ok, env} =
             @middleware.call(%Env{url: ""}, [],
               nearest_node: nil,
               nodes: [@healthy_node]
             )

    assert env.url == @healthy_node_url
  end

  test "return result if max_retries is hit" do
    assert {:ok, env} =
             @middleware.call(%Env{url: ""}, [],
               max_retries: 3,
               nodes: [@unhealthy_node]
             )

    assert env.url == @unhealthy_node_url
  end

  test "cycle through provided nodes" do
    assert {:ok, env} =
             @middleware.call(%Env{url: ""}, [],
               nodes: [@unhealthy_node, @unhealthy_node, @healthy_node]
             )

    assert env.url == @healthy_node_url
  end

  test "test retry when request fails" do
    middleware = [
      {@middleware,
       [
         max_retries: 1,
         nodes: [@unhealthy_node]
       ]}
    ]

    Tesla.Mock.mock(fn
      %{method: :get} = env ->
        %{env | status: 500}
    end)

    client = Tesla.client(middleware, Tesla.Mock)

    assert {:ok, %Tesla.Env{}} = Tesla.get(client, "/")
  end

  test "pick fallback node if nearest node is unhealthy" do
    assert {:ok, env} =
             @middleware.call(%Env{url: ""}, [],
               nearest_node: @unhealthy_node,
               nodes: [
                 @healthy_node
               ]
             )

    assert env.url == @healthy_node_url
  end
end
