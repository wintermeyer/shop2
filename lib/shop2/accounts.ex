defmodule Shop2.Accounts do
  use Ash.Domain

  resources do
    resource Shop2.Accounts.Token
    resource Shop2.Accounts.User
  end
end
