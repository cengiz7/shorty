defmodule Shorty.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ShortyWeb.Telemetry,
      Shorty.Repo,
      {DNSCluster, query: Application.get_env(:shorty, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Shorty.PubSub},
      # Start a worker by calling: Shorty.Worker.start_link(arg)
      # {Shorty.Worker, arg},
      # Start to serve requests, typically the last entry
      ShortyWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Shorty.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ShortyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
