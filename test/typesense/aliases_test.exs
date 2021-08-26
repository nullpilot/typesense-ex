defmodule Typesense.CurationTest do
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

  test "create new alias", %{client: client, collection: collection} do
    collection_alias = "alias-" <> Base.encode16(:crypto.strong_rand_bytes(4))

    assert {:ok, %Tesla.Env{} = env} =
             Typesense.Aliases.upsert(client, collection_alias, collection)

    assert env.status == 200
  end
end
