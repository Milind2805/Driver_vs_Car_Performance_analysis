-- F1 SQL Analytics: "Driver vs. Car" Performance Analysis
-- Schema for the Ergast / Kaggle "Formula 1 World Championship 1950-2024" dataset
-- Run this in pgAdmin's Query Tool against the f1_analytics database

-- ===== Dimension tables =====

CREATE TABLE seasons (
    year INTEGER PRIMARY KEY,
    url  VARCHAR(200)
);

CREATE TABLE circuits (
    circuitId   INTEGER PRIMARY KEY,
    circuitRef  VARCHAR(100),
    name        VARCHAR(200),
    location    VARCHAR(100),
    country     VARCHAR(100),
    lat         NUMERIC(10,6),
    lng         NUMERIC(10,6),
    alt         INTEGER,
    url         VARCHAR(200)
);

CREATE TABLE constructors (
    constructorId  INTEGER PRIMARY KEY,
    constructorRef VARCHAR(100),
    name           VARCHAR(200),
    nationality    VARCHAR(100),
    url            VARCHAR(200)
);

CREATE TABLE drivers (
    driverId    INTEGER PRIMARY KEY,
    driverRef   VARCHAR(100),
    number      INTEGER,
    code        VARCHAR(10),
    forename    VARCHAR(100),
    surname     VARCHAR(100),
    dob         DATE,
    nationality VARCHAR(100),
    url         VARCHAR(200)
);

CREATE TABLE status (
    statusId INTEGER PRIMARY KEY,
    status   VARCHAR(100)
);

CREATE TABLE races (
    raceId      INTEGER PRIMARY KEY,
    year        INTEGER REFERENCES seasons(year),
    round       INTEGER,
    circuitId   INTEGER REFERENCES circuits(circuitId),
    name        VARCHAR(200),
    date        DATE,
    time        TIME,
    url         VARCHAR(200),
    fp1_date    DATE,
    fp1_time    TIME,
    fp2_date    DATE,
    fp2_time    TIME,
    fp3_date    DATE,
    fp3_time    TIME,
    quali_date  DATE,
    quali_time  TIME,
    sprint_date DATE,
    sprint_time TIME
);

-- ===== Fact / event tables =====

CREATE TABLE results (
    resultId        INTEGER PRIMARY KEY,
    raceId          INTEGER REFERENCES races(raceId),
    driverId        INTEGER REFERENCES drivers(driverId),
    constructorId   INTEGER REFERENCES constructors(constructorId),
    number          INTEGER,
    grid            INTEGER,
    position        INTEGER,
    positionText    VARCHAR(10),
    positionOrder   INTEGER,
    points          NUMERIC(6,2),
    laps            INTEGER,
    time            VARCHAR(20),
    milliseconds    INTEGER,
    fastestLap      INTEGER,
    rank            INTEGER,
    fastestLapTime  VARCHAR(20),
    fastestLapSpeed NUMERIC(6,3),
    statusId        INTEGER REFERENCES status(statusId)
);

CREATE TABLE sprint_results (
    resultId        INTEGER PRIMARY KEY,
    raceId          INTEGER REFERENCES races(raceId),
    driverId        INTEGER REFERENCES drivers(driverId),
    constructorId   INTEGER REFERENCES constructors(constructorId),
    number          INTEGER,
    grid            INTEGER,
    position        INTEGER,
    positionText    VARCHAR(10),
    positionOrder   INTEGER,
    points          NUMERIC(6,2),
    laps            INTEGER,
    time            VARCHAR(20),
    milliseconds    INTEGER,
    fastestLap      INTEGER,
    fastestLapTime  VARCHAR(20),
    statusId        INTEGER REFERENCES status(statusId)
);

CREATE TABLE qualifying (
    qualifyId      INTEGER PRIMARY KEY,
    raceId         INTEGER REFERENCES races(raceId),
    driverId       INTEGER REFERENCES drivers(driverId),
    constructorId  INTEGER REFERENCES constructors(constructorId),
    number         INTEGER,
    position       INTEGER,
    q1             VARCHAR(20),
    q2             VARCHAR(20),
    q3             VARCHAR(20)
);

CREATE TABLE driver_standings (
    driverStandingsId INTEGER PRIMARY KEY,
    raceId            INTEGER REFERENCES races(raceId),
    driverId          INTEGER REFERENCES drivers(driverId),
    points            NUMERIC(6,2),
    position          INTEGER,
    positionText      VARCHAR(10),
    wins              INTEGER
);

CREATE TABLE constructor_standings (
    constructorStandingsId INTEGER PRIMARY KEY,
    raceId                 INTEGER REFERENCES races(raceId),
    constructorId          INTEGER REFERENCES constructors(constructorId),
    points                 NUMERIC(6,2),
    position               INTEGER,
    positionText           VARCHAR(10),
    wins                   INTEGER
);

CREATE TABLE constructor_results (
    constructorResultsId INTEGER PRIMARY KEY,
    raceId               INTEGER REFERENCES races(raceId),
    constructorId        INTEGER REFERENCES constructors(constructorId),
    points               NUMERIC(6,2),
    status               VARCHAR(50)
);

CREATE TABLE lap_times (
    raceId       INTEGER REFERENCES races(raceId),
    driverId     INTEGER REFERENCES drivers(driverId),
    lap          INTEGER,
    position     INTEGER,
    time         VARCHAR(20),
    milliseconds INTEGER,
    PRIMARY KEY (raceId, driverId, lap)
);

CREATE TABLE pit_stops (
    raceId       INTEGER REFERENCES races(raceId),
    driverId     INTEGER REFERENCES drivers(driverId),
    stop         INTEGER,
    lap          INTEGER,
    time         TIME,
    duration     VARCHAR(20),
    milliseconds INTEGER,
    PRIMARY KEY (raceId, driverId, stop)
);