-- Rebuild the temp table with the Indianapolis-500-era exclusion
DROP TABLE IF EXISTS home_race_results;

CREATE TEMP TABLE home_race_results AS
SELECT
    r.driverid,
    d.forename || ' ' || d.surname AS driver_name,
    ra.raceid,
    ra.year,
    r.positionorder,
    CASE WHEN ntc.country = c.country THEN 1 ELSE 0 END AS is_home_race
FROM results r
JOIN drivers d ON d.driverid = r.driverid
JOIN races ra ON ra.raceid = r.raceid
JOIN circuits c ON c.circuitid = ra.circuitid
LEFT JOIN nationality_to_country ntc ON ntc.nationality = d.nationality
WHERE r.positionorder IS NOT NULL
  AND ra.year >= 1961;   -- excludes the Indy-500-only American entrants

-- Re-run the comparison
SELECT
    driver_name,
    COUNT(*) FILTER (WHERE is_home_race = 1) AS home_races,
    ROUND(AVG(positionorder) FILTER (WHERE is_home_race = 1), 2) AS avg_finish_home,
    ROUND(AVG(positionorder) FILTER (WHERE is_home_race = 0), 2) AS avg_finish_away,
    ROUND(
        AVG(positionorder) FILTER (WHERE is_home_race = 0) -
        AVG(positionorder) FILTER (WHERE is_home_race = 1), 2
    ) AS home_advantage
FROM home_race_results
GROUP BY driver_name
HAVING COUNT(*) FILTER (WHERE is_home_race = 1) >= 3
   AND COUNT(*) FILTER (WHERE is_home_race = 0) >= 3   -- also require a real away sample
ORDER BY home_advantage DESC;