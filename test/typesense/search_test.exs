defmodule Typesense.SearchTest do
  use Typesense.ApiCase

  setup_all %{client: client} do
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
        "fields" => [
          order_field,
          text_field
        ]
      })

    {:ok, _response} = Typesense.Collections.create(client, schema)

    collection_name = schema["name"]
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

    assert {:ok, _response} = Typesense.Documents.search(client, collection, search_params)
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

    assert {:ok, response} =
             Typesense.Documents.multi_search(client, search_requests, common_params)

    assert 2 = length(response["results"])
  end

  defp insert_fruit(client, collection_name, name) do
    {:ok, _response} =
      Typesense.Documents.create(
        client,
        collection_name,
        build(:document, %{
          "name" => name
        })
      )
  end
end
