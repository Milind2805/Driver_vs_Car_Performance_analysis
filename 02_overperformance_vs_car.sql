-- =====================================================================
-- Analysis 2: Over/Underperformance vs. Car Pace
-- For each race, compare a driver's finishing position to their
-- constructor's average grid position that season. Consistently
-- finishing better than the car's average starting spot = a driver
-- "punching above" the car.
-- =====================================================================

WITH constructor_season_baseline AS (
    -- The car's average starting position across the whole season,
    -- using BOTH teammates' grid results -- this represents the car's
    -- raw pace, independent of any one driver's race-day performance.
    SELECT
        ra.year,
        r.constructorid,
        AVG(r.grid) AS avg_car_grid
    FROM results r
    JOIN races ra ON ra.raceid = r.raceid
    WHERE r.grid > 0   -- exclude pit-lane starts (grid = 0) which distort the average
    GROUP BY ra.year, r.constructorid
),

driver_race_delta AS (
    SELECT
        ra.year,
        r.driverid,
        r.constructorid,
        r.raceid,
        r.positionorder,
        csb.avg_car_grid,
        -- Positive value = finished better than the car's average grid spot
        (csb.avg_car_grid - r.positionorder) AS overperformance
    FROM results r
    JOIN races ra ON ra.raceid = r.raceid
    JOIN constructor_season_baseline csb
        ON csb.year = ra.year AND csb.constructorid = r.constructorid
)

SELECT
    d.forename || ' ' || d.surname AS driver_name,
    c.name AS constructor_name,
    drd.year,
    COUNT(*) AS races,
    ROUND(AVG(drd.avg_car_grid), 2) AS car_avg_grid,
    ROUND(AVG(drd.positionorder), 2) AS driver_avg_finish,
    ROUND(AVG(drd.overperformance), 2) AS avg_overperformance
FROM driver_race_delta drd
JOIN drivers d ON d.driverid = drd.driverid
JOIN constructors c ON c.constructorid = drd.constructorid
GROUP BY d.forename, d.surname, c.name, drd.year
HAVING COUNT(*) >= 5
ORDER BY avg_overperformance DESC
LIMIT 25;