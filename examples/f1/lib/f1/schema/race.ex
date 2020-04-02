defmodule F1.Schema.Race do
  @moduledoc """
  Race schema.
  """
  use Ecto.Schema

  @schema_prefix "f1db"
  @primary_key false
  schema "races" do
    field :id, :id, primary_key: true, source: :raceid
    field :date, :date
  end
end
