defmodule Shop2.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Shop2Web.Telemetry,
      Shop2.Repo,
      {DNSCluster, query: Application.get_env(:shop2, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Shop2.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Shop2.Finch},
      # Start a worker by calling: Shop2.Worker.start_link(arg)
      # {Shop2.Worker, arg},
      # Start to serve requests, typically the last entry
      Shop2Web.Endpoint,
      {AshAuthentication.Supervisor, [otp_app: :shop2]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Shop2.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    Shop2Web.Endpoint.config_change(changed, removed)
    :ok
  end
end
