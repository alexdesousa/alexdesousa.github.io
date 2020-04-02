import AyeSQL, only: [defqueries: 3]

defqueries(F1.Query.Season, "query/season.sql", repo: F1.Repo)
