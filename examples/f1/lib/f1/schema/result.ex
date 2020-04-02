defmodule F1.Schema.Result do
  @moduledoc """
  Result schema.
  """
  use Ecto.Schema

  alias F1.Schema.Race
  alias F1.Schema.Status

  @schema_prefix "f1db"
  @primary_key false
  schema "results" do
    field :id, :id, primary_key: true, source: :resultid
    belongs_to :race, Race, source: :raceid
    belongs_to :status, Status, source: :statusid
  end
end
