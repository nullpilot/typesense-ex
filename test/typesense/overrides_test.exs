defmodule Typesense.CurationTest do
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

    assert {:ok, %Tesla.Env{} = env} =
             Typesense.Overrides.upsert(client, collection, "customize-apple", override)

    assert env.status == 200
  end

  test "list existing overrides", %{client: client, collection: collection} do
    assert {:ok, %Tesla.Env{} = env} = Typesense.Overrides.list(client, collection)
    assert env.status == 200
    assert is_list(env.body["overrides"])
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
