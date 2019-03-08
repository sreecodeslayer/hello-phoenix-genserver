defmodule HelloGenserver.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @name "hello-genserver"

  def start(_type, _args) do
    # List all child processes to be supervised
    children =
      [
        # Start the endpoint when the application starts
        HelloGenserverWeb.Endpoint
      ]
      |> register_or_skip

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HelloGenserver.Spv]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    HelloGenserverWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp register_or_skip(children) do
    # Libcluster configuration

    topologies = [
      nodes: [
        strategy: Cluster.Strategy.Gossip
      ]
    ]

    case Swarm.whereis_name(@name) do
      {:ok, _pid} ->
        Logger.info("GenServer won't be spawned here")
        children

      :undefined ->
        Logger.info("No GenServer found in registry, making one")

        case Swarm.register_name(@name, HelloGenserver.Supervisor, :register, [@name]) do
          {:ok, _pid} ->
            [
              # Start the cluster supervisor
              {Cluster.Supervisor, [topologies, [name: HelloGenserver.ClusterSupervisor]]}
              | children
            ]

          {:error, reason} ->
            Logger.error("Error registering name from Swarm: #{inspect(reason)}")
            children
        end
    end
  end
end
