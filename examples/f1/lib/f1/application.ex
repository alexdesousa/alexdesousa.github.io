defmodule F1.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      F1.Repo
    ]

    opts = [strategy: :one_for_one, name: F1.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
