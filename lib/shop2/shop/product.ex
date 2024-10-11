defmodule Shop2.Shop.Product do
  use Ash.Resource, otp_app: :shop2, domain: Shop2.Shop, data_layer: AshPostgres.DataLayer

  postgres do
    table "products"
    repo Shop2.Repo
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
