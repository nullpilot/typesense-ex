defmodule Typesense.Factory do
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
        }),
        build(:field),
        build(:field)
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
end
