WITH race_percentiles AS (
    SELECT
        r.raceid,
        r.driverid,
        ra.year,
        1 - PERCENT_RANK() OVER (PARTITION BY r.raceid ORDER BY r.positionorder) AS dominance_score
    FROM results r
    JOIN races ra ON ra.raceid = r.raceid
)
SELECT
    d.forename || ' ' || d.surname AS driver_name,
    rp.year,
    COUNT(*) AS races,
    ROUND((AVG(rp.dominance_score) * 100)::numeric, 2) AS avg_dominance_pct
FROM race_percentiles rp
JOIN drivers d ON d.driverid = rp.driverid
GROUP BY d.forename, d.surname, rp.year
HAVING COUNT(*) >= 10
ORDER BY avg_dominance_pct DESC
LIMIT 20;