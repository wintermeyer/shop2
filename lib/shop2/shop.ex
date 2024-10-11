defmodule Shop2.Shop do
  use Ash.Domain

  resources do
    resource Shop2.Shop.Category
  end
end
