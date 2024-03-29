defmodule BigCentral.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BigCentralWeb.Telemetry,
      BigCentral.Repo,
      {DNSCluster, query: Application.get_env(:big_central, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: BigCentral.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: BigCentral.Finch},
      # Start a worker by calling: BigCentral.Worker.start_link(arg)
      # {BigCentral.Worker, arg},
      # Start to serve requests, typically the last entry
      BigCentralWeb.Endpoint,
      EncryptedFileServer
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BigCentral.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BigCentralWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
