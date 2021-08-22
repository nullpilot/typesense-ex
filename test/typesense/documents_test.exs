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

  test "update an existing document", %{client: client, collection: collection} do
    doc =
      build(:document, %{
        "id" => "update",
        "order" => 10
      })

    Typesense.Documents.create(client, collection, doc)

    update_doc = %{doc | "order" => 11}

    assert {:ok, %Tesla.Env{} = env} =
             Typesense.Documents.update(client, collection, doc["id"], update_doc)

    assert env.status == 201
    assert env.body == %{"id" => "update", "order" => 11}
  end

  test "delete an existing document", %{client: client, collection: collection} do
    doc = build(:document)

    Typesense.Documents.create(client, collection, doc)

    assert {:ok, %Tesla.Env{} = env} = Typesense.Documents.delete(client, collection, doc["id"])

    assert env.status == 200
  end

  test "delete documents by query", %{client: client, collection: collection} do
    doc1 = build(:document, %{"order" => 700})
    doc2 = build(:document, %{"order" => 700})
    filter = "order:=700"

    Typesense.Documents.create(client, collection, doc1)
    Typesense.Documents.create(client, collection, doc2)

    assert {:ok, %Tesla.Env{} = env} =
             Typesense.Documents.delete_by_query(client, collection, filter)

    assert env.status == 200
    assert env.body == %{"num_deleted" => 2}
  end

  test "export documents", %{client: client, collection: collection} do
    doc1 = build(:document)
    doc2 = build(:document)

    Typesense.Documents.create(client, collection, doc1)
    Typesense.Documents.create(client, collection, doc2)

    assert {:ok, %Tesla.Env{} = env} =
             Typesense.Documents.export(client, collection)

    assert env.status == 200
  end
end
