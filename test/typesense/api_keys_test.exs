defmodule Typesense.ApiKeysTest do
  use ExUnit.Case

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

  test "retrieve data of an existing api key", %{client: client} do
    key_props = %{
      "description" => "Admin key.",
      "actions" => ["*"],
      "collections" => ["*"]
    }

    {:ok, %{body: %{"id" => key_id}}} = Typesense.ApiKeys.create(client, key_props)

    assert {:ok, %Tesla.Env{} = env} = Typesense.ApiKeys.retrieve(client, key_id)
    assert env.status == 200
  end
end
