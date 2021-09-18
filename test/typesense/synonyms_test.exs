defmodule Typesense.SynonymsTest do
  use Typesense.ApiCase

  setup_all %{client: client} do
    schema = build(:collection)
    collection_name = schema["name"]

    {:ok, _response} = Typesense.Collections.create(client, schema)

    on_exit(fn -> Typesense.Collections.delete(client, collection_name) end)

    {:ok, %{client: client, collection: collection_name}}
  end

  test "create new multi-way synonym", %{client: client, collection: collection} do
    synonyms = %{
      synonyms: ["blazer", "coat", "jacket"]
    }

    assert {:ok, _response} =
             Typesense.Synonyms.upsert(client, collection, "coat-synonyms", synonyms)
  end

  test "create new one-way synonym", %{client: client, collection: collection} do
    synonyms = %{
      root: "smart phone",
      synonyms: ["iphone", "android"]
    }

    assert {:ok, _response} =
             Typesense.Synonyms.upsert(client, collection, "smart-phone-synonyms", synonyms)
  end

  test "list existing synonym", %{client: client, collection: collection} do
    assert {:ok, response} = Typesense.Synonyms.list(client, collection)
    assert is_list(response["synonyms"])
  end

  test "retrieve existing synonym", %{client: client, collection: collection} do
    synonym_id = "coat-synonyms"

    synonyms = %{
      synonyms: ["blazer", "coat", "jacket"]
    }

    Typesense.Synonyms.upsert(client, collection, synonym_id, synonyms)

    assert {:ok, _response} = Typesense.Synonyms.retrieve(client, collection, synonym_id)
  end

  test "delete existing synonym", %{client: client, collection: collection} do
    synonym_id = "fruit-synonyms"

    synonyms = %{
      synonyms: ["ananas", "pineapple"]
    }

    Typesense.Synonyms.upsert(client, collection, synonym_id, synonyms)

    assert {:ok, _response} = Typesense.Synonyms.delete(client, collection, synonym_id)
  end
end
