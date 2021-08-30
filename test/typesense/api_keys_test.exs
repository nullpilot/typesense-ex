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

    assert {:ok, %{"value" => _}} = Typesense.ApiKeys.create(client, key_props)
  end

  test "retrieve data of an existing api key", %{client: client} do
    key_props = %{
      "description" => "Admin key.",
      "actions" => ["*"],
      "collections" => ["*"]
    }

    {:ok, %{"id" => key_id}} = Typesense.ApiKeys.create(client, key_props)

    assert {:ok, %{"value_prefix" => _}} = Typesense.ApiKeys.retrieve(client, key_id)
  end

  test "list api keys", %{client: client} do
    assert {:ok, response} = Typesense.ApiKeys.list(client)
    assert is_list(response["keys"])
  end

  test "delete existing api key", %{client: client} do
    key_props = %{
      "description" => "Search Key.",
      "actions" => ["document:search"],
      "collections" => ["*"]
    }

    {:ok, %{"id" => key_id}} = Typesense.ApiKeys.create(client, key_props)

    assert {:ok, %{"id" => ^key_id}} = Typesense.ApiKeys.delete(client, key_id)
  end

  test "create scoped search key" do
    search_key = "RN23GFr1s6jQ9kgSNg2O7fYcAUXU7127"
    embedded_params = ~s({"filter_by":"company_id:124","expires_at":1906054106})

    expected_key =
      "OW9DYWZGS1Q1RGdSbmo0S1QrOWxhbk9PL2kxbTU1eXA3bCthdmE5eXJKRT1STjIzeyJmaWx0ZXJfYnkiOiJjb21wYW55X2lkOjEyNCIsImV4cGlyZXNfYXQiOjE5MDYwNTQxMDZ9"

    scoped_key = Typesense.ApiKeys.generate_scoped_search_key(search_key, embedded_params)

    assert scoped_key == expected_key
  end
end
