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

    assert {:ok, %Tesla.Env{} = env} =
             Typesense.Collections.retrieve(client, "retrievecollection")

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

    assert contains?(env.body, ["listcollection1", "listcollection2"])
  end

  test "deletes an existing collection", %{client: client} do
    schema = build(:collection, %{"name" => "deletecollection"})

    # make sure collection is added successfully
    assert {:ok, %Tesla.Env{} = env} = Typesense.Collections.create(client, schema)
    assert env.status == 201

    # confirm
    assert {:ok, %Tesla.Env{} = env} = Typesense.Collections.list(client)
    assert contains?(env.body, ["deletecollection"])

    # delete collection again
    assert {:ok, %Tesla.Env{} = env} = Typesense.Collections.delete(client, "deletecollection")
    assert env.status == 200

    # confirm
    assert {:ok, %Tesla.Env{} = env} = Typesense.Collections.list(client)
    refute contains?(env.body, ["deletecollection"])
  end

  defp contains?(collection_list, names_to_check) when is_list(names_to_check) do
    collection_names =
      collection_list
      |> Enum.map(&Map.fetch!(&1, "name"))

    names_to_check
    |> Enum.all?(&Enum.member?(collection_names, &1))
  end
end
