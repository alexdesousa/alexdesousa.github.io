defmodule F1.Config do
  @moduledoc """
  Configuration variables for F1 application.
  """
  use Skogsra

  @envdoc """
  Database hostname.
  """
  app_env :hostname, :f1, :hostname, default: "localhost"

  @envdoc """
  Database port.
  """
  app_env :port, :f1, :port, default: 5432

  @envdoc """
  Database name.
  """
  app_env :database, :f1, :database, default: "f1db"

  @envdoc """
  Database username.
  """
  app_env :username, :f1, :username, default: "postgres"

  @envdoc """
  Database password.
  """
  app_env :password, :f1, :password, default: "postgres"
end
