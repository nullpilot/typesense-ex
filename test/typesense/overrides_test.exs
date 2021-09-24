defmodule Typesense.OverridesTest do
  use Typesense.ApiCase

  alias Typesense.Overrides

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

  test "create new override", %{client: client, collection: collection} do
    override = %{
      "rule" => %{
        "query" => "apple",
        "match" => "exact"
      },
      "includes" => [
        %{"id" => "422", "position" => 1},
        %{"id" => "54", "position" => 2}
      ],
      "excludes" => [
        %{"id" => "287"}
      ]
    }

    assert {:ok, _response} = Overrides.upsert(client, collection, "customize-apple", override)
  end

  test "list existing overrides", %{client: client, collection: collection} do
    assert {:ok, response} = Overrides.list(client, collection)
    assert is_list(response["overrides"])
  end

  test "retrieve existing override", %{client: client, collection: collection} do
    override = %{
      "rule" => %{
        "query" => "apple",
        "match" => "exact"
      },
      "includes" => [
        %{"id" => "1", "position" => 1}
      ]
    }

    Overrides.upsert(client, collection, "customize-apple", override)

    assert {:ok, _response} = Overrides.retrieve(client, collection, "customize-apple")
  end

  test "delete existing override", %{client: client, collection: collection} do
    override = %{
      "rule" => %{
        "query" => "cherry",
        "match" => "exact"
      },
      "includes" => [
        %{"id" => "1", "position" => 1}
      ]
    }

    Overrides.upsert(client, collection, "customize-cherry", override)

    assert {:ok, _response} = Overrides.delete(client, collection, "customize-cherry")
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
