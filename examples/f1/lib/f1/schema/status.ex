defmodule F1.Schema.Status do
  @moduledoc """
  Status schema.
  """
  use Ecto.Schema

  alias F1.Schema.Race

  @schema_prefix "f1db"
  @primary_key false
  schema "status" do
    field :id, :id, primary_key: true, source: :statusid
    field :status, :string
  end
end
