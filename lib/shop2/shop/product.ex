defmodule Shop2.Shop.Product do
  use Ash.Resource,
    otp_app: :shop2,
    domain: Shop2.Shop,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "products"
    repo Shop2.Repo
  end

  actions do
    defaults [
      :read,
      :destroy,
      update: [:name, :description, :image, :price, :quantity_stored],
      create: [:name, :description, :image, :price, :quantity_stored]
    ]
  end

  policies do
    policy action_type([:create, :update, :destroy]) do
      authorize_if actor_attribute_equals(:role, :admin)
    end

    policy action_type(:read) do
      authorize_if always()
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :description, :string do
      allow_nil? false
      public? true
    end

    attribute :image, :string do
      public? true
    end

    attribute :price, :money do
      allow_nil? false
      public? true
    end

    attribute :quantity_stored, :integer do
      allow_nil? false
      public? true
    end
  end

  relationships do
    belongs_to :category, Shop2.Shop.Category do
      public? true
      allow_nil? false
    end
  end
end
