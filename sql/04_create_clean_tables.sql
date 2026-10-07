-- ============================================================
-- Create Clean Analytical Tables
-- ============================================================

DROP TABLE IF EXISTS policies_clean;
DROP TABLE IF EXISTS claims_clean;
DROP TABLE IF EXISTS policy_claim_summary;


-- ============================================================
-- 1. Clean policy table
-- ============================================================

CREATE TABLE policies_clean AS

WITH actual_claim_counts AS (
    SELECT
        CAST(IDpol AS INTEGER) AS IDpol,
        COUNT(*) AS ActualClaimCount
    FROM claims_raw
    GROUP BY CAST(IDpol AS INTEGER)
)

SELECT
    CAST(p.IDpol AS INTEGER) AS IDpol,
    p.ClaimNb,
    COALESCE(a.ActualClaimCount, 0) AS ActualClaimCount,

    CASE
        WHEN p.ClaimNb != COALESCE(a.ActualClaimCount, 0)
        THEN 1
        ELSE 0
    END AS ClaimCountMismatchFlag,

    p.Exposure,

    CASE
        WHEN p.Exposure > 1
        THEN 1
        ELSE 0
    END AS ExposureOverOneFlag,

    p.Area,
    p.VehPower,
    p.VehAge,
    p.DrivAge,
    p.BonusMalus,
    p.VehBrand,
    p.VehGas,
    p.Density,
    p.Region

FROM policies_raw p

LEFT JOIN actual_claim_counts a
    ON CAST(p.IDpol AS INTEGER) = a.IDpol;


-- ============================================================
-- 2. Clean claims table
-- Exclude orphan claim records
-- ============================================================

CREATE TABLE claims_clean AS

SELECT
    CAST(c.IDpol AS INTEGER) AS IDpol,
    c.ClaimAmount

FROM claims_raw c

INNER JOIN policies_raw p
    ON c.IDpol = p.IDpol

WHERE c.ClaimAmount > 0;


-- ============================================================
-- 3. Policy-level claim aggregation
-- ============================================================

CREATE TABLE policy_claim_summary AS

WITH claim_summary AS (
    SELECT
        IDpol,
        COUNT(*) AS ActualClaimRecords,
        SUM(ClaimAmount) AS TotalClaimAmount,
        AVG(ClaimAmount) AS AverageClaimAmount,
        MAX(ClaimAmount) AS MaximumClaimAmount
    FROM claims_clean
    GROUP BY IDpol
)

SELECT
    p.IDpol,
    p.ClaimNb,
    p.ActualClaimCount,
    p.ClaimCountMismatchFlag,

    p.Exposure,
    p.ExposureOverOneFlag,

    p.Area,
    p.VehPower,
    p.VehAge,
    p.DrivAge,
    p.BonusMalus,
    p.VehBrand,
    p.VehGas,
    p.Density,
    p.Region,

    COALESCE(c.ActualClaimRecords, 0) AS ActualClaimRecords,
    COALESCE(c.TotalClaimAmount, 0) AS TotalClaimAmount,
    COALESCE(c.AverageClaimAmount, 0) AS AverageClaimAmount,
    COALESCE(c.MaximumClaimAmount, 0) AS MaximumClaimAmount,

    CASE
        WHEN p.Exposure > 0
        THEN CAST(COALESCE(c.ActualClaimRecords, 0) AS REAL) / p.Exposure
        ELSE NULL
    END AS ClaimFrequency,

    CASE
        WHEN COALESCE(c.ActualClaimRecords, 0) > 0
        THEN c.TotalClaimAmount / c.ActualClaimRecords
        ELSE 0
    END AS ClaimSeverity

FROM policies_clean p

LEFT JOIN claim_summary c
    ON p.IDpol = c.IDpol;