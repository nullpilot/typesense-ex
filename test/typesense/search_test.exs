defmodule Typesense.SearchTest do
  use ExUnit.Case

  import Typesense.Factory

  setup_all do
    client = Typesense.client()
    collection_name = "searchcollection"

    order_field =
      build(:field, %{
        "name" => "order",
        "type" => "int32"
      })

    text_field =
      build(:field, %{
        "name" => "name",
        "type" => "string"
      })

    schema =
      build(:collection, %{
        "name" => collection_name,
        "fields" => [
          order_field,
          text_field
        ]
      })

    {:ok, %{status: 201}} = Typesense.Collections.create(client, schema)

    insert_fruit(client, collection_name, "Pears")
    insert_fruit(client, collection_name, "Peas")
    insert_fruit(client, collection_name, "Orange")
    insert_fruit(client, collection_name, "Apple")
    insert_fruit(client, collection_name, "Apple")
    insert_fruit(client, collection_name, "Blueberries")
    insert_fruit(client, collection_name, "Cherries")
    insert_fruit(client, collection_name, "Strawberries")

    on_exit(fn -> Typesense.Collections.delete(client, collection_name) end)

    {:ok, %{client: client, collection: collection_name}}
  end

  test "search a collection and return results", %{client: client, collection: collection} do
    search_params = build(:search, %{"q" => "pea", "query_by" => "name"})

    assert {:ok, %Tesla.Env{} = env} =
             Typesense.Documents.search(client, collection, search_params)

    assert 200 == env.status
  end

  test "search a collection using multisearch and return results", %{
    client: client,
    collection: collection
  } do
    common_params = %{"collection" => collection, "query_by" => "name"}

    search_requests = [
      %{"q" => "pea"},
      %{"q" => "berr"}
    ]

    assert {:ok, %Tesla.Env{} = env} =
             Typesense.Documents.multi_search(client, search_requests, common_params)

    assert 200 == env.status
    assert 2 = length(env.body["results"])
  end

  defp insert_fruit(client, collection_name, name) do
    {:ok, %{status: 201}} =
      Typesense.Documents.create(
        client,
        collection_name,
        build(:document, %{
          "name" => name
        })
      )
  end
end
