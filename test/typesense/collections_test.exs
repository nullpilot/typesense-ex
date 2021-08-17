defmodule Typesense.CollectionsTest do
  use ExUnit.Case

  setup do
    client = Typesense.client()

    {:ok, %{client: client}}
  end

  test "creates a new collection", %{client: client} do
    schema = %{
      "name" => "companies",
      "fields" => [
        %{
          "name" => "company_name",
          "type" => "string",
          "facet" => false
        },
        %{
          "name" => "num_employees",
          "type" => "int32",
          "facet" => false
        },
        %{
          "name" => "country",
          "type" => "string",
          "facet" => true
        }
      ],
      "default_sorting_field" => "num_employees"
    }

    assert {:ok, %Tesla.Env{} = env} = Typesense.Collections.create(client, schema)
    assert env.status == 201

    assert %{
             "name" => "companies",
             "num_documents" => 0,
             "fields" => [
               %{"name" => "company_name", "type" => "string"},
               %{"name" => "num_employees", "type" => "int32"},
               %{"name" => "country", "type" => "string", "facet" => true}
             ],
             "default_sorting_field" => "num_employees"
           } = env.body
  end

  test "retrieves an existing collection", %{client: client} do
    schema = %{
      "name" => "companies_ret",
      "fields" => [
        %{
          "name" => "company_name",
          "type" => "string",
          "facet" => false
        },
        %{
          "name" => "num_employees",
          "type" => "int32",
          "facet" => false
        },
        %{
          "name" => "country",
          "type" => "string",
          "facet" => true
        }
      ],
      "default_sorting_field" => "num_employees"
    }

    {:ok, %Tesla.Env{} = _} = Typesense.Collections.create(client, schema)

    assert {:ok, %Tesla.Env{} = env} = Typesense.Collections.retrieve(client, "companies_ret")
    assert env.status == 200

    assert %{
             "name" => "companies_ret",
             "num_documents" => 0,
             "fields" => [
               %{"name" => "company_name", "type" => "string"},
               %{"name" => "num_employees", "type" => "int32"},
               %{"name" => "country", "type" => "string", "facet" => true}
             ],
             "default_sorting_field" => "num_employees"
           } = env.body
  end
end
