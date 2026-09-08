WITH classified_status AS (
    SELECT
        statusid,
        status,
        CASE
            WHEN status = 'Finished' OR status LIKE '+%Lap%' THEN 'Finished'
            WHEN status IN (
                -- Original list
                'Engine', 'Gearbox', 'Transmission', 'Clutch', 'Hydraulics',
                'Electrical', 'Suspension', 'Brakes', 'Differential',
                'Overheating', 'Mechanical', 'Fuel system', 'Fuel pressure',
                'Water leak', 'Oil leak', 'Radiator', 'Wheel', 'Puncture',
                'Tyre', 'Steering', 'Exhaust', 'Water pump', 'Alternator',
                'Turbo', 'Power Unit', 'Battery', 'Vibrations', 'Driveshaft',
                'Wheel nut', 'Throttle', 'Ignition', 'Fuel pump',
                -- Added after reviewing the full 139-value status list
                'Halfshaft', 'Oil pressure', 'Fuel leak', 'Wheel bearing',
                'Injection', 'Chassis', 'Magneto', 'Axle', 'Heat shield fire',
                'Power loss', 'Distributor', 'Oil pump', 'Oil pipe',
                'Water pressure', 'Fuel', 'Wheel rim', 'Spark plugs',
                'Fuel pipe', 'Track rod', 'Stalled', 'Cooling system',
                'Crankshaft', 'CV joint'
            ) THEN 'Mechanical DNF'
            WHEN status IN ('Did not qualify', 'Did not prequalify', 'Excluded',
                             'Withdrew', 'Not classified', '107% Rule') THEN 'Non-starter'
            ELSE 'Other DNF'   -- collisions, driver error, strategy, injury, disqualification
        END AS outcome_group
    FROM status
)

SELECT
    c.name AS constructor_name,
    ra.year,
    COUNT(*) AS race_starts,
    COUNT(*) FILTER (WHERE cs.outcome_group = 'Finished') AS finished,
    COUNT(*) FILTER (WHERE cs.outcome_group = 'Mechanical DNF') AS mechanical_dnf,
    COUNT(*) FILTER (WHERE cs.outcome_group = 'Other DNF') AS other_dnf,
    ROUND(
        (100.0 * COUNT(*) FILTER (WHERE cs.outcome_group = 'Mechanical DNF') / COUNT(*))::numeric, 1
    ) AS mechanical_dnf_pct
FROM results r
JOIN races ra ON ra.raceid = r.raceid
JOIN constructors c ON c.constructorid = r.constructorid
JOIN classified_status cs ON cs.statusid = r.statusid
WHERE cs.outcome_group != 'Non-starter'
GROUP BY c.name, ra.year
HAVING COUNT(*) >= 10
ORDER BY mechanical_dnf_pct DESC
LIMIT 25;