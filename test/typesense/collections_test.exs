defmodule Typesense.CollectionsTest do
  use Typesense.ApiCase

  test "creates a new collection", %{client: client} do
    schema = build(:collection)

    assert {:ok,
            %{
              "name" => _,
              "num_documents" => _,
              "created_at" => _,
              "fields" => _,
              "default_sorting_field" => _,
              "num_memory_shards" => _
            }} = Typesense.Collections.create(client, schema)
  end

  test "retrieves an existing collection", %{client: client} do
    schema = build(:collection, %{"name" => "retrievecollection"})

    Typesense.Collections.create(client, schema)

    assert {:ok,
            %{
              "name" => "retrievecollection",
              "num_documents" => _,
              "created_at" => _,
              "fields" => _,
              "default_sorting_field" => _,
              "num_memory_shards" => _
            }} = Typesense.Collections.retrieve(client, "retrievecollection")
  end

  test "lists all existing collections", %{client: client} do
    schema1 = build(:collection)
    schema2 = build(:collection)

    Typesense.Collections.create(client, schema1)
    Typesense.Collections.create(client, schema2)

    assert {:ok, response} = Typesense.Collections.list(client)
    assert is_list(response)
    assert contains?(response, [schema1["name"], schema2["name"]])
  end

  test "deletes an existing collection", %{client: client} do
    schema = build(:collection)
    collection_name = schema["name"]

    # make sure collection is added successfully
    assert {:ok, _response} = Typesense.Collections.create(client, schema)

    # delete collection again
    assert {:ok, _response} = Typesense.Collections.delete(client, collection_name)

    # confirm
    assert {:ok, response} = Typesense.Collections.list(client)
    refute contains?(response, [collection_name])
  end

  defp contains?(collection_list, names_to_check) when is_list(names_to_check) do
    collection_names =
      collection_list
      |> Enum.map(&Map.fetch!(&1, "name"))

    names_to_check
    |> Enum.all?(&Enum.member?(collection_names, &1))
  end
end
