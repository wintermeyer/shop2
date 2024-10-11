defmodule Shop2.Shop.Product do
  use Ash.Resource,
    otp_app: :shop2,
    domain: Shop2.Shop,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    notifiers: [Ash.Notifier.PubSub]

  postgres do
    table "products"
    repo Shop2.Repo
  end

  actions do
    defaults [
      :read,
      :destroy
    ]

    create :create do
      primary? true
      accept [:name, :description, :image, :price, :quantity_stored]
      argument :category, :string, allow_nil?: false

      change manage_relationship(:category,
               type: :append_and_remove,
               on_no_match: :create,
               value_is_key: :name
             )
    end

    update :update do
      primary? true
      require_atomic? false
      accept [:name, :description, :image, :price, :quantity_stored]
      argument :category, :string, allow_nil?: false

      change manage_relationship(:category,
               type: :append_and_remove,
               on_no_match: :create,
               value_is_key: :name
             )
    end
  end

  policies do
    policy action_type([:create, :update, :destroy]) do
      authorize_if actor_attribute_equals(:role, :admin)
    end

    policy action_type(:read) do
      authorize_if always()
    end
  end

  pub_sub do
    module Shop2Web.Endpoint
    prefix "product"

    publish :update, ["updated", :id]
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
