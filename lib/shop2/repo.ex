defmodule Shop2.Repo do
  use AshPostgres.Repo,
    otp_app: :shop2

  def installed_extensions do
    # Add extensions here, and the migration generator will install them.
    ["ash-functions"]
  end

  def min_pg_version do
    %Version{major: 13, minor: 4, patch: 0}
  end
end
