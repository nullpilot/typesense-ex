defmodule Typesense.DocumentsTest do
  use ExUnit.Case

  import Typesense.Factory

  setup_all do
    client = Typesense.client()
    collection_name = "doccollection"

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
          order_field
        ]
      })

    {:ok, %{status: 201}} = Typesense.Collections.create(client, schema)

    on_exit(fn -> Typesense.Collections.delete(client, collection_name) end)

    {:ok, %{client: client, collection: collection_name}}
  end

  test "create a new document", %{client: client, collection: collection} do
    doc =
      build(:document, %{
        "order" => 1
      })

    assert {:ok, %Tesla.Env{} = env} = Typesense.Documents.create(client, collection, doc)

    assert env.status == 201
  end

  test "upsert an existing document", %{client: client, collection: collection} do
    doc =
      build(:document, %{
        "id" => "1",
        "order" => 1
      })

    updated_doc =
      build(:document, %{
        "id" => "1",
        "order" => 2
      })

    Typesense.Documents.create(client, collection, doc)

    assert {:ok, %Tesla.Env{} = env} = Typesense.Documents.upsert(client, collection, updated_doc)
    assert env.status == 201
    assert env.body == %{"id" => "1", "order" => 2}
  end

  test "retrieve an existing document", %{client: client, collection: collection} do
    doc =
      build(:document, %{
        "id" => "ret"
      })

    Typesense.Documents.create(client, collection, doc)

    assert {:ok, %Tesla.Env{} = env} = Typesense.Documents.retrieve(client, collection, doc["id"])
    assert env.status == 200
  end
end
