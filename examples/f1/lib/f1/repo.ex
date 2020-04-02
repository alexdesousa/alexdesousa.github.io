defmodule F1.Repo do
  use Ecto.Repo,
    otp_app: :f1,
    adapter: Ecto.Adapters.Postgres

  def init(_type, config) do
    options = [
      hostname: F1.Config.hostname!(),
      port: F1.Config.port!(),
      database: F1.Config.database!(),
      username: F1.Config.username!(),
      password: F1.Config.password!()
    ]

    new_config = Keyword.merge(options, config)

    {:ok, new_config}
  end
end
