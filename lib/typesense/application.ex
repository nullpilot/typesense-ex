defmodule Typesense.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Typesense.Worker.start_link(arg)
      # {Typesense.Worker, arg}
      :hackney_pool.child_spec(__MODULE__, Typesense.Config.resolve(:pool_options)),
      Typesense.Healthcheck
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Typesense.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
