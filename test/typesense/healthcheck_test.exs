defmodule Typesense.HealthcheckTest do
  use ExUnit.Case, async: true

  alias Typesense.Healthcheck

  @node "http://localhost:8108/"
  @interval 50

  setup_all context do
    start_supervised!(Healthcheck)
    context
  end

  test "confirm viability of new node" do
    assert true == Healthcheck.is_viable(@node, @interval)
  end

  test "confirm viability of a healthy node" do
    Healthcheck.pass_check(@node)

    assert true == Healthcheck.is_viable(@node, @interval)
  end

  test "confirm viability of a non-healthy node after the healthcheck interval" do
    Healthcheck.fail_check(@node)

    :timer.sleep(@interval + 100)

    assert true == Healthcheck.is_viable(@node, @interval)
  end

  test "refute viability of a non-healthy node" do
    Healthcheck.fail_check(@node)

    assert false == Healthcheck.is_viable(@node, @interval)
  end
end
