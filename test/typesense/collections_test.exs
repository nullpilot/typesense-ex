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

    {:ok, %Tesla.Env{} = _} = Typesense.Collections.create(client, schema)

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
end
