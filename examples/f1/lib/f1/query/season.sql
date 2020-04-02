-- name: get_accidents
-- docs: Gets accidents in a season range.
WITH accidents AS
(
    SELECT EXTRACT(year from races.date) AS season,
           COUNT(*) AS participants,
           COUNT(*) FILTER(WHERE status = 'Accident') AS accidents
      FROM f1db.results AS results
      JOIN f1db.status AS status USING(statusid)
      JOIN f1db.races AS races USING(raceid)
  GROUP BY season
)
  SELECT season,
         ROUND(100.0 * accidents / participants, 2) AS percentage
    FROM accidents
   WHERE season BETWEEN :from AND :to
ORDER BY season
