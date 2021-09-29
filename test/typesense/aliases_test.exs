defmodule Typesense.AliasesTest do
  use Typesense.ApiCase

  setup_all %{client: client} do
    schema = build(:collection)
    collection_name = schema["name"]

    {:ok, _} = Typesense.Collections.create(client, schema)

    on_exit(fn -> Typesense.Collections.delete(client, collection_name) end)

    {:ok, %{collection: collection_name}}
  end

  test "create new alias", %{client: client, collection: collection} do
    collection_alias = build(:alias)

    {:ok, response} = Typesense.Aliases.upsert(client, collection_alias, collection)
    assert %{"name" => ^collection_alias, "collection_name" => ^collection} = response
  end

  test "list existing aliases", %{client: client} do
    {:ok, response} = Typesense.Aliases.list(client)
    assert is_list(response["aliases"])
  end

  test "retrieve existing alias", %{client: client, collection: collection} do
    collection_alias = build(:alias)
    Typesense.Aliases.upsert(client, collection_alias, collection)

    {:ok, response} = Typesense.Aliases.retrieve(client, collection_alias)
    assert %{"name" => ^collection_alias, "collection_name" => ^collection} = response
  end

  test "delete existing alias", %{client: client, collection: collection} do
    collection_alias = build(:alias)
    Typesense.Aliases.upsert(client, collection_alias, collection)

    {:ok, response} = Typesense.Aliases.delete(client, collection_alias)
    assert %{"name" => ^collection_alias, "collection_name" => ^collection} = response
  end

  test "delete alias that does not exist", %{client: client} do
    collection_alias = build(:alias)
    assert {:error, %ObjectNotFound{}} = Typesense.Aliases.delete(client, collection_alias)
  end

  test "delete alias from collection that does not exist", %{client: client} do
    collection_alias = build(:alias)
    assert {:error, %ObjectNotFound{}} = Typesense.Aliases.delete(client, collection_alias)
  end
end
