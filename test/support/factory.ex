defmodule Typesense.Factory do
  @moduledoc false

  use ExMachina

  def collection_factory do
    random_name = "collection-" <> Base.encode16(:crypto.strong_rand_bytes(4))

    %{
      "name" => random_name,
      "default_sorting_field" => "order",
      "fields" => [
        build(:field, %{
          "name" => "order",
          "type" => "int32",
          "facet" => false
        })
      ]
    }
  end

  def field_factory do
    %{
      "name" => sequence("field"),
      "type" => "int32",
      "facet" => false
    }
  end

  def document_factory do
    %{
      "id" => sequence("doc_id_"),
      "order" => sequence(:doc_order, & &1)
    }
  end

  def search_factory do
    %{
      "q" => "",
      "query_by" => "name"
    }
  end

  def alias_factory(_attrs) do
    "alias-" <> Base.encode16(:crypto.strong_rand_bytes(4))
  end
end
