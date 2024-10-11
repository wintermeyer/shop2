defmodule Shop2.Shop.Category do
  use Ash.Resource,
    otp_app: :shop2,
    domain: Shop2.Shop,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "categories"
    repo Shop2.Repo
  end

  actions do
    defaults [:read, :destroy, update: [:name], create: [:name]]
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
    uuid_v7_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end
  end
end
