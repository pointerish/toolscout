defmodule Toolscout.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ToolscoutWeb.Telemetry,
      Toolscout.Repo,
      {DNSCluster, query: Application.get_env(:toolscout, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Toolscout.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Toolscout.Finch},
      # Start a worker by calling: Toolscout.Worker.start_link(arg)
      # {Toolscout.Worker, arg},
      # Start to serve requests, typically the last entry
      ToolscoutWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Toolscout.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ToolscoutWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
