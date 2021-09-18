defmodule Typesense.DocumentsTest do
  use Typesense.ApiCase

  setup_all %{client: client} do
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

    {:ok, _response} = Typesense.Collections.create(client, schema)

    on_exit(fn -> Typesense.Collections.delete(client, collection_name) end)

    {:ok, %{client: client, collection: collection_name}}
  end

  test "create a new document", %{client: client, collection: collection} do
    doc = build(:document)

    assert {:ok, ^doc} = Typesense.Documents.create(client, collection, doc)
  end

  test "upsert an existing document", %{client: client, collection: collection} do
    doc = build(:document)
    updated_doc = %{doc | "order" => 11}

    Typesense.Documents.create(client, collection, doc)
    assert {:ok, ^updated_doc} = Typesense.Documents.upsert(client, collection, updated_doc)
  end

  test "retrieve an existing document", %{client: client, collection: collection} do
    doc = build(:document)

    Typesense.Documents.create(client, collection, doc)

    assert {:ok, ^doc} = Typesense.Documents.retrieve(client, collection, doc["id"])
  end

  test "update an existing document", %{client: client, collection: collection} do
    doc = build(:document)

    Typesense.Documents.create(client, collection, doc)

    updated_doc = %{doc | "order" => 11}

    assert {:ok, ^updated_doc} =
             Typesense.Documents.update(client, collection, doc["id"], updated_doc)
  end

  test "delete an existing document", %{client: client, collection: collection} do
    doc = build(:document)

    Typesense.Documents.create(client, collection, doc)

    assert {:ok, ^doc} = Typesense.Documents.delete(client, collection, doc["id"])
  end

  test "delete documents by query", %{client: client, collection: collection} do
    doc1 = build(:document, %{"order" => 700})
    doc2 = build(:document, %{"order" => 700})
    filter = "order:=700"

    Typesense.Documents.create(client, collection, doc1)
    Typesense.Documents.create(client, collection, doc2)

    assert {:ok, %{"num_deleted" => 2}} =
             Typesense.Documents.delete_by_query(client, collection, filter)
  end

  test "export documents", %{client: client, collection: collection} do
    doc1 = build(:document)
    doc2 = build(:document)

    Typesense.Documents.create(client, collection, doc1)
    Typesense.Documents.create(client, collection, doc2)

    assert {:ok, _response} = Typesense.Documents.export(client, collection)
  end

  test "import documents", %{client: client, collection: collection} do
    doc1 = build(:document)
    doc2 = build(:document)

    assert {:ok, _response} =
             Typesense.Documents.import(client, collection, [doc1, doc2],
               action: "create",
               batch_size: 5
             )
  end
end
