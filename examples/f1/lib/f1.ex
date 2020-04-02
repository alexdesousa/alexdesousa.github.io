defmodule F1 do
  @moduledoc """
  Ecto implementation of `F1.Query.Season`
  """
  import Ecto.Query

  alias F1.Schema.Result

  def get_accidents(from, to) do
    accidents =
      from re in Result,
        join: st in assoc(re, :status),
        join: ra in assoc(re, :race),
        group_by: fragment("season"),
        select: %{
          season: fragment("EXTRACT(year from ?)", ra.date),
          participants: fragment("COUNT(*)"),
          accidents: fragment("COUNT(*) FILTER(WHERE status = 'Accident')")
        }

    query =
      from a in subquery(accidents),
        where: fragment("? BETWEEN ? AND ?", a.season, ^from, ^to),
        select: %{
          season: a.season,
          percentage: fragment("ROUND(100.0 * ? / ?, 2)", a.accidents, a.participants)
        }

    F1.Repo.all(query)
  end
end
