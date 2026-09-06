# F1 SQL Analytics: "Driver vs. Car" Performance Analysis

**Core question:** How much of a Formula 1 driver's success comes down to
the car, and how much is the driver? Five SQL-driven analyses, each
designed to isolate driver skill from car performance using a different
angle.

**Dataset:** [Formula 1 World Championship 1950-2024](https://www.kaggle.com/datasets/rohanrao/formula-1-world-championship-1950-2020)
(Ergast API data, mirrored on Kaggle as CSVs). 14 relational tables --
drivers, constructors, races, results, qualifying, lap times, pit stops,
and season/driver/constructor standings.

**Stack:** PostgreSQL 18 for the analysis, Python (pandas/scipy) for the
one hypothesis test that needed it, Power BI for the dashboard.

## Setup

1. Download the dataset CSVs from Kaggle (link above).
2. Create a PostgreSQL database and run `sql/schema.sql` to build the
   14-table schema.
3. Import each CSV into its matching table (pgAdmin's Import/Export
   Data tool, or `\copy` from psql).
4. Run the queries in `sql/` in numbered order.

## Analyses

| # | Question | Query | Key finding |
|---|----------|-------|-------------|
| 1 | Teammate head-to-head | `01_teammate_head_to_head.sql` | Verstappen's 2024-2025 seasons (95.8% win rate vs. teammate) rank alongside historically dominant seasons like Vettel 2013 and Clark 1963. |
| 2 | Over/underperformance vs. car pace | `02_overperformance_vs_car.sql` | Compares each driver's finishing position against their constructor's average grid position that season. |
| 3 | Home circuit advantage | `03b_home_circuit_fixed.sql` + `python/home_advantage_ttest*.py` | A paired t-test across 172 drivers found **no statistically significant home advantage** (p = 0.68), and restricting to established drivers with 10+ home races didn't change the conclusion (p = 0.83). Individual cases (Prost +4.4 positions, Senna -3.4) cancel out at the population level. |
| 4 | Era-adjusted dominance | `04_era_adjusted_dominance_fixed.sql` | Using percentile rank (not raw points, which aren't comparable across eras) Verstappen's 2023 season (98.56% average dominance) is the single most dominant season in F1 history, ahead of Schumacher 2002 (97.95%). |
| 5 | Reliability vs. performance | `05c_reliability_final.sql` | DNF rates by constructor/season, split into mechanical failures vs. other causes (crashes, disqualifications), after manually classifying all 139 distinct race-outcome statuses in the dataset. |

## Data

`data/` contains the exported result sets used to build the Power BI
dashboard (not the raw source CSVs, which are available directly from
Kaggle).

## Notes on data quality

- Analyses 1 and 3 exclude 1950-1960, when the Indianapolis 500 counted
  as an F1 championship round but wasn't contested by regular F1
  drivers/teams -- including it distorts both the teammate-pairing and
  home-country logic.
- Analysis 5 required manually classifying all 139 distinct values in
  the `status` table (e.g. "Halfshaft", "Magneto", "107% Rule") into
  Finished / Mechanical DNF / Other DNF / Non-starter, since the raw
  data doesn't group these.
