defmodule Typesense.HealthcheckTest do
  use ExUnit.Case

  alias Typesense.Healthcheck

  @interval 50

  test "confirm viability of new node" do
    assert true == Healthcheck.is_viable("http://new-node:8108/", @interval)
  end

  test "confirm viability of a healthy node" do
    node = "http://healthy-node:8108/"
    Healthcheck.pass_check(node)

    assert true == Healthcheck.is_viable(node, @interval)
  end

  test "confirm viability of a non-healthy node after the healthcheck interval" do
    node = "http://unhealthy-node:8108/"
    Healthcheck.fail_check(node)

    :timer.sleep(@interval + 100)

    assert true == Healthcheck.is_viable(node, @interval)
  end

  test "refute viability of a non-healthy node" do
    node = "http://unhealthy-node:8208/"
    Healthcheck.fail_check(node)

    assert false == Healthcheck.is_viable(node, @interval)
  end
end
