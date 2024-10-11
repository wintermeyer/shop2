defmodule Shop2.Accounts.User.Types.Role do
  use Ash.Type.Enum, values: [:admin, :user]
end
