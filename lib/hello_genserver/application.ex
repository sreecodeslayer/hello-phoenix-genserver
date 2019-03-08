defmodule HelloGenserver.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # Libcluster configuration
    topologies = [
      chat: [
        strategy: Cluster.Strategy.Gossip
      ]
    ]

    # List all child processes to be supervised
    children = [
      # Start the cluster supervisor
      {Cluster.Supervisor, [topologies, [name: HelloGenserver.ClusterSupervisor]]},
      # Start the endpoint when the application starts
      HelloGenserverWeb.Endpoint,
      # Starts a worker by calling: HelloGenserver.Worker.start_link(arg)
      HelloGenserver.Worker
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HelloGenserver.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    HelloGenserverWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
