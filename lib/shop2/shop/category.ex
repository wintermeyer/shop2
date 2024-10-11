defmodule Shop2.Shop.Category do
  use Ash.Resource, otp_app: :shop2, domain: Shop2.Shop, data_layer: AshPostgres.DataLayer

  postgres do
    table "categories"
    repo Shop2.Repo
  end

  actions do
    defaults [:read, :destroy, update: [:name], create: [:name]]
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end
  end
end
