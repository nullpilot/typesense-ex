defmodule Typesense.CollectionsTest do
  use ExUnit.Case

  import Typesense.Factory

  setup do
    client = Typesense.client()

    {:ok, %{client: client}}
  end

  test "creates a new collection", %{client: client} do
    schema = build(:collection, %{"name" => "createcollection"})

    assert {:ok, %Tesla.Env{} = env} = Typesense.Collections.create(client, schema)
    assert env.status == 201

    assert %{
      "name" => "createcollection",
      "num_documents" => _,
      "created_at" => _,
      "fields" => _,
      "default_sorting_field" => _,
      "num_memory_shards" => _
    } = env.body
  end

  test "retrieves an existing collection", %{client: client} do
    schema = build(:collection, %{"name" => "retrievecollection"})

    Typesense.Collections.create(client, schema)

    assert {:ok, %Tesla.Env{} = env} = Typesense.Collections.retrieve(client, "retrievecollection")
    assert env.status == 200

    assert %{
      "name" => "retrievecollection",
      "num_documents" => _,
      "created_at" => _,
      "fields" => _,
      "default_sorting_field" => _,
      "num_memory_shards" => _
    } = env.body
  end

  test "lists all existing collections", %{client: client} do
    schema1 = build(:collection, %{"name" => "listcollection1"})
    schema2 = build(:collection, %{"name" => "listcollection2"})

    Typesense.Collections.create(client, schema1)
    Typesense.Collections.create(client, schema2)

    assert {:ok, %Tesla.Env{} = env} = Typesense.Collections.list(client)
    assert env.status == 200
    assert is_list(env.body)

    collection_names = env.body
    |> Enum.map(&(Map.fetch!(&1, "name")))

    assert Enum.member?(collection_names, "listcollection1")
    assert Enum.member?(collection_names, "listcollection2")
  end
end
