defmodule Typesense.DocumentsTest do
  use ExUnit.Case

  import Typesense.Factory

  setup do
    client = Typesense.client()

    {:ok, %{client: client}}
  end

  test "create a new document", %{client: client} do
    order_field = build(:field, %{
      "name" => "order",
      "type" => "int32"
    })

    schema = build(:collection, %{
      "name" => "createdoc_collection",
      "default_sorting_field" => "order",
      "fields" => [order_field]
    })

    doc = build(:document, %{
      "order" => 1
    })

    Typesense.Collections.create(client, schema)

    assert {:ok, %Tesla.Env{} = env} = Typesense.Documents.create(client, "createdoc_collection", doc)
    assert env.status == 201
  end

  test "upsert an existing document", %{client: client} do
    order_field = build(:field, %{
      "name" => "order",
      "type" => "int32"
    })

    schema = build(:collection, %{
      "name" => "upsertdoc_collection",
      "default_sorting_field" => "order",
      "fields" => [order_field]
    })

    doc = build(:document, %{
      "id" => "1",
      "order" => 1
    })

    updated_doc = build(:document, %{
      "id" => "1",
      "order" => 2
    })

    Typesense.Collections.create(client, schema)
    Typesense.Documents.create(client, "upsertdoc_collection", doc)

    {:ok, %Tesla.Env{} = env} = Typesense.Documents.upsert(client, "upsertdoc_collection", updated_doc)

    assert env.status == 201
    assert env.body == %{"id" => "1", "order" => 2}

  end
end
