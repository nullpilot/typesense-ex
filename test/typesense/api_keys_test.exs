defmodule Typesense.ApiKeysTest do
  use ExUnit.Case

  import Typesense.Factory

  setup do
    client = Typesense.client()

    {:ok, %{client: client}}
  end

  test "create new api key", %{client: client} do
    key_props = %{
      "description" => "Admin key.",
      "actions" => ["*"],
      "collections" => ["*"]
    }

    assert {:ok, %Tesla.Env{} = env} = Typesense.ApiKeys.create(client, key_props)
    assert env.status == 201
  end
end
