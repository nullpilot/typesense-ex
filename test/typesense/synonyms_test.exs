defmodule Typesense.SynonymsTest do
  use ExUnit.Case

  import Typesense.Factory

  setup_all do
    client = Typesense.client()
    schema = build(:collection)
    collection_name = schema["name"]

    {:ok, %{status: 201}} = Typesense.Collections.create(client, schema)

    on_exit(fn -> Typesense.Collections.delete(client, collection_name) end)

    {:ok, %{client: client, collection: collection_name}}
  end

  test "create new multi-way synonym", %{client: client, collection: collection} do
    synonyms = %{
      synonyms: ["blazer", "coat", "jacket"]
    }

    assert {:ok, %Tesla.Env{} = env} =
             Typesense.Synonyms.upsert(client, collection, "coat-synonyms", synonyms)

    assert env.status == 200
  end

  test "create new one-way synonym", %{client: client, collection: collection} do
    synonyms = %{
      root: "smart phone",
      synonyms: ["iphone", "android"]
    }

    assert {:ok, %Tesla.Env{} = env} =
             Typesense.Synonyms.upsert(client, collection, "smart-phone-synonyms", synonyms)

    assert env.status == 200
  end

  test "list existing synonym", %{client: client, collection: collection} do
    assert {:ok, %Tesla.Env{} = env} = Typesense.Synonyms.list(client, collection)
    assert env.status == 200
    assert is_list(env.body["synonyms"])
  end

  test "retrieve existing synonym", %{client: client, collection: collection} do
    synonym_id = "coat-synonyms"

    synonyms = %{
      synonyms: ["blazer", "coat", "jacket"]
    }

    Typesense.Synonyms.upsert(client, collection, synonym_id, synonyms)

    assert {:ok, %Tesla.Env{} = env} = Typesense.Synonyms.retrieve(client, collection, synonym_id)
    assert env.status == 200
  end

  test "delete existing synonym", %{client: client, collection: collection} do
    synonym_id = "fruit-synonyms"

    synonyms = %{
      synonyms: ["ananas", "pineapple"]
    }

    Typesense.Synonyms.upsert(client, collection, synonym_id, synonyms)

    assert {:ok, %Tesla.Env{} = env} = Typesense.Synonyms.delete(client, collection, synonym_id)
    assert env.status == 200
  end
end
