defmodule Typesense.Factory do
  @moduledoc false

  use ExMachina

  def collection_factory do
    %{
      "name" => sequence("collection"),
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
      "order" => 1
    }
  end
end
