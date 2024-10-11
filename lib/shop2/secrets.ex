defmodule Shop2.Secrets do
  use AshAuthentication.Secret

  def secret_for([:authentication, :tokens, :signing_secret], Shop2.Accounts.User, _opts) do
    Application.fetch_env(:shop2, :token_signing_secret)
  end
end
