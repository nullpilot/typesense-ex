defmodule Typesense.CycleNodesTest do
  use ExUnit.Case, async: true

  alias Tesla.Env
  alias Typesense.Healthcheck

  @middleware Typesense.Middleware.CycleNodes

  test "set base url from nearest node" do
    assert {:ok, env} =
             @middleware.call(%Env{url: ""}, [],
               nearest_node: [
                 protocol: "http",
                 host: "localhost",
                 port: "8108"
               ],
               nodes: []
             )

    assert env.url == "http://localhost:8108/"
  end

  test "set base url with retries" do
    assert {:ok, env} =
             @middleware.call(%Env{url: ""}, [],
               max_retries: 3,
               nearest_node: [
                 protocol: "http",
                 host: "localhost",
                 port: "8108"
               ],
               nodes: []
             )

    assert env.url == "http://localhost:8108/"
  end

  test "set base url from fallback node" do
    assert {:ok, env} =
             @middleware.call(%Env{url: ""}, [],
               nearest_node: nil,
               nodes: [
                 [
                   protocol: "http",
                   host: "localhost",
                   port: "8108"
                 ]
               ]
             )

    assert env.url == "http://localhost:8108/"
  end

  test "pick fallback node if nearest node is unhealthy" do
    node = "http://unhealthy-node:8108/"
    Healthcheck.fail_check(node)

    assert {:ok, env} =
             @middleware.call(%Env{url: ""}, [],
               nearest_node: [
                 protocol: "http",
                 host: "unhealthy-node",
                 port: 8108
               ],
               nodes: [
                 [
                   protocol: "http",
                   host: "localhost",
                   port: 8108
                 ]
               ]
             )

    assert env.url == "http://localhost:8108/"
  end
end
