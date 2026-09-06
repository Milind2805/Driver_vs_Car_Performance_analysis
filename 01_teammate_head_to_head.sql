-- =====================================================================
-- Analysis 1: Teammate Head-to-Head
-- Since teammates share identical machinery, comparing a driver against
-- their own teammate isolates driver skill from car performance.
-- =====================================================================

-- Step 1: For each race, pair up teammates within the same constructor
-- and compare their finishing positions (positionOrder is used over
-- 'position' because it's never null -- DNFs get a high number instead
-- of a null, so the comparison always resolves).

WITH teammate_pairs AS (
    SELECT
        r.raceid,
        ra.year,
        r.constructorid,
        r.driverid        AS driver_a,
        r.positionorder   AS pos_a,
        r2.driverid       AS driver_b,
        r2.positionorder  AS pos_b
    FROM results r
    JOIN results r2
        ON r.raceid = r2.raceid
        AND r.constructorid = r2.constructorid
        AND r.driverid < r2.driverid   -- avoids duplicate mirrored pairs
    JOIN races ra ON ra.raceid = r.raceid
),

-- Step 2: Unpivot into one row per driver per comparison, with a
-- win/loss flag against their teammate for that race.
head_to_head AS (
    SELECT year, constructorid, driver_a AS driverid, driver_b AS opponent,
           CASE WHEN pos_a < pos_b THEN 1 ELSE 0 END AS beat_teammate
    FROM teammate_pairs
    UNION ALL
    SELECT year, constructorid, driver_b AS driverid, driver_a AS opponent,
           CASE WHEN pos_b < pos_a THEN 1 ELSE 0 END AS beat_teammate
    FROM teammate_pairs
)

-- Step 3: Aggregate to a win rate per driver per season, with driver name
-- and only including pairings with a meaningful sample size.
SELECT
    d.forename || ' ' || d.surname AS driver_name,
    c.name AS constructor_name,
    h.year,
    COUNT(*) AS races_compared,
    SUM(h.beat_teammate) AS races_beat_teammate,
    ROUND(100.0 * SUM(h.beat_teammate) / COUNT(*), 1) AS win_rate_pct
FROM head_to_head h
JOIN drivers d ON d.driverid = h.driverid
JOIN constructors c ON c.constructorid = h.constructorid
GROUP BY d.forename, d.surname, c.name, h.year
HAVING COUNT(*) >= 5   -- filter out mid-season driver swaps with tiny samples
ORDER BY h.year DESC, win_rate_pct DESC;