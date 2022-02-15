defmodule PlateSlateWeb.Schema.MenuTypes do
  use Absinthe.Schema.Notation
  alias PlateSlateWeb.Resolvers
  alias PlateSlateWeb.Schema.Middleware

  @desc "Filtering options for the menu item list"
  input_object :menu_item_filter do
    @desc "Matching a name"
    field :name, :string
    @desc "Matching a category name"
    field :category, :string
    @desc "Matching a tag"
    field :tag, :string
    @desc "Priced above a value"
    field :tag, :string
    @desc "Priced below a value"
    field :priced_below, :float
    @desc "Added to the menu before this date"
    field :added_before, :date
    @desc "Added to the menu after this date"
    field :added_after, :date
  end

  input_object :menu_item_input do
    field :name, non_null(:string)
    field :description, :string
    field :price, non_null(:decimal)
    field :category_id, non_null(:id)
  end

  input_object :order_item_input do
    field :menu_item_id, non_null(:id)
    field :quantity, non_null(:integer)
  end

  input_object :place_order_input do
    field :customer_number, :integer
    field :items, non_null(list_of(non_null(:order_item_input)))
  end

  object :menu_item do
    interfaces [:search_result]
    field :id, :id
    field :name, :string
    field :description, :string
    field :price, :decimal
    field :category, :category
    field :added_on, :date
  end

  object :order_result do
    field :order, :order
    field :errors, list_of(:input_error)
  end

  object :order do
    field :id, :id
    field :customer_number, :integer
    field :items, list_of(:order_item)
    field :state, :string
  end

  object :order_item do
    field :name, :string
    field :quantity, :integer
  end

  object :menu_queries do
    @desc "The list of available items on the menu"
    field :menu_items, list_of(:menu_item) do
      arg :filter, non_null(:menu_item_filter)
      arg :order, :sort_order, default_value: :asc
      resolve &Resolvers.Menu.menu_items/3
    end
  end

  object :category do
    interfaces [:search_result]
    field :name, :string
    field :description, :string

    field :items, list_of(:menu_item) do
      resolve &Resolvers.Menu.items_for_category/3
    end
  end

  interface :search_result do
    field :name, :string

    resolve_type fn
      %PlateSlate.Menu.Item{}, _ ->
        :menu_item

      %PlateSlate.Menu.Category{}, _ ->
        :category

      _, _ ->
        nil
    end
  end

  object :search_query do
    field :search, list_of(:search_result) do
      arg :matching, non_null(:string)
      resolve &Resolvers.Menu.search/3
    end
  end

  object :menu_item_mutation do
    field :create_menu_item, :menu_item_result do
      arg :input, non_null(:menu_item_input)
      resolve &Resolvers.Menu.create_item/3
      middleware Middleware.ChangesetErrors
    end
  end

  object :place_order_mutation do
    field :place_order, :order_result do
      arg :input, non_null(:place_order_input)
      resolve &Resolvers.Ordering.place_order/3
    end
  end

  object :ready_order_mutation do
    field :ready_order, :order_result do
      arg :id, non_null(:id)
      resolve &Resolvers.Ordering.ready_order/3
    end
  end

  object :complete_order_mutation do
    field :complete_order, :order_result do
      arg :id, non_null(:id)
      resolve &Resolvers.Ordering.complete_order/3
    end
  end

  object :menu_item_result do
    field :menu_item, :menu_item
    field :errors, list_of(:input_error)
  end

  @desc "An error encountered trying to persist input"
  object :input_error do
    field :key, non_null(:string)
    field :message, non_null(:string)
  end
end
