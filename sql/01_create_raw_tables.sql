DROP TABLE IF EXISTS policies_raw;
DROP TABLE IF EXISTS claims_raw;

CREATE TABLE policies_raw (
    IDpol REAL,
    ClaimNb INTEGER,
    Exposure REAL,
    Area TEXT,
    VehPower INTEGER,
    VehAge INTEGER,
    DrivAge INTEGER,
    BonusMalus INTEGER,
    VehBrand TEXT,
    VehGas TEXT,
    Density REAL,
    Region TEXT
);

CREATE TABLE claims_raw (
    IDpol REAL,
    ClaimAmount REAL
);