defmodule PlateSlateWeb.Schema.Query.MenuItemsTest do
  use PlateSlateWeb.ConnCase, async: true

  alias PlateSlate.Menu.Item

  setup do
    PlateSlate.Seeds.run()
  end

  @query """
  {
    menuItems(filter: {}) {
      name
    }
  }
  """

  test "menuItems field returns menu items" do
    conn = build_conn()
    conn = get(conn, "/api", query: @query)

    assert json_response(conn, 200) ==
             %{
               "data" => %{
                 "menuItems" => [
                   %{"name" => "Bánh mì"},
                   %{"name" => "Chocolate Milkshake"},
                   %{"name" => "Croque Monsieur"},
                   %{"name" => "French Fries"},
                   %{"name" => "Lemonade"},
                   %{"name" => "Masala Chai"},
                   %{"name" => "Muffuletta"},
                   %{"name" => "Papadum"},
                   %{"name" => "Pasta Salad"},
                   %{"name" => "Reuben"},
                   %{"name" => "Soft Drink"},
                   %{"name" => "Vada Pav"},
                   %{"name" => "Vanilla Milkshake"},
                   %{"name" => "Water"}
                 ]
               }
             }
  end

  @query """
  query ($order: SortOrder!){
    menuItems(order: $order, filter: {}) {
      name
    }
  }
  """
  @variables %{"order" => "DESC"}

  test "menuItems field returns items descending using literals" do
    response = get(build_conn(), "/api", query: @query, variables: @variables)

    assert %{
             "data" => %{"menuItems" => [%{"name" => "Water"} | _]}
           } = json_response(response, 200)
  end

  @query """
  query ($term: String) {
    menuItems(filter: {name: $term}) {
      name
    }
  }
  """
  @variables %{"term" => "reu"}
  test "menuItems field returns menu items filtered by name" do
    response = get(build_conn(), "/api", query: @query, variables: @variables)

    assert json_response(response, 200) == %{
             "data" => %{
               "menuItems" => [
                 %{"name" => "Reuben"}
               ]
             }
           }
  end

  @query """
  {
    menuItems(filter: {name: 123}) {
      name
    }
  }
  """

  test "menuItems field returns errors when using a bad value" do
    response = get(build_conn(), "/api", query: @query)

    assert %{
             "errors" => [
               %{"message" => message}
             ]
           } = json_response(response, 200)

    assert message ==
             "Argument \"filter\" has invalid value {name: 123}.\nIn field \"name\": Expected type \"String\", found 123."
  end

  @query """
  query ($filter: MenuItemFilter!) {
    menuItems(filter: $filter) {
      name
    }
  }
  """
  @variables %{filter: %{"tag" => "Vegetarian", "category" => "Sandwiches"}}
  test "menuItems field returns menuItems, fitlering with a literal" do
    response = get(build_conn(), "/api", query: @query, variables: @variables)

    assert %{
             "data" => %{"menuItems" => [%{"name" => "Vada Pav"}]}
           } == json_response(response, 200)
  end

  @query """
  query ($filter: MenuItemFilter!) {
    menuItems(filter: $filter) {
      name
      addedOn
    }
  }
  """
  @variables %{filter: %{"addedBefore" => "2017-01-20"}}
  test "menuItems filtered by custom scalar" do
    sides = PlateSlate.Repo.get_by!(PlateSlate.Menu.Category, name: "Sides")

    %Item{
      name: "Garlic Fries",
      added_on: ~D[2017-01-01],
      price: 2.50,
      category: sides
    }
    |> PlateSlate.Repo.insert!()

    response = get(build_conn(), "/api", query: @query, variables: @variables)

    assert %{
             "data" => %{
               "menuItems" => [%{"name" => "Garlic Fries", "addedOn" => "2017-01-01"}]
             }
           } == json_response(response, 200)
  end
end
