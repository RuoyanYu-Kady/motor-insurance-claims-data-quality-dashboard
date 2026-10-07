-- ============================================================
-- Motor Insurance Claims Business Analysis
-- ============================================================


-- 1. Overall portfolio KPIs
SELECT
    COUNT(*) AS TotalPolicies,
    SUM(Exposure) AS TotalExposure,
    SUM(ActualClaimRecords) AS TotalClaims,
    SUM(TotalClaimAmount) AS TotalClaimAmount,

    ROUND(
        CAST(SUM(ActualClaimRecords) AS REAL)
        / NULLIF(SUM(Exposure), 0),
        4
    ) AS ClaimFrequency,

    ROUND(
        SUM(TotalClaimAmount)
        / NULLIF(SUM(ActualClaimRecords), 0),
        2
    ) AS AverageClaimSeverity

FROM policy_claim_summary;


-- ============================================================
-- 2. Claims by region
-- ============================================================

SELECT
    Region,
    COUNT(*) AS Policies,
    ROUND(SUM(Exposure), 2) AS Exposure,
    SUM(ActualClaimRecords) AS Claims,
    ROUND(SUM(TotalClaimAmount), 2) AS TotalClaimAmount,

    ROUND(
        CAST(SUM(ActualClaimRecords) AS REAL)
        / NULLIF(SUM(Exposure), 0),
        4
    ) AS ClaimFrequency,

    ROUND(
        SUM(TotalClaimAmount)
        / NULLIF(SUM(ActualClaimRecords), 0),
        2
    ) AS ClaimSeverity

FROM policy_claim_summary

GROUP BY Region
ORDER BY TotalClaimAmount DESC;


-- ============================================================
-- 3. Claims by area
-- ============================================================

SELECT
    Area,
    COUNT(*) AS Policies,
    SUM(ActualClaimRecords) AS Claims,
    ROUND(SUM(TotalClaimAmount), 2) AS TotalClaimAmount,

    ROUND(
        CAST(SUM(ActualClaimRecords) AS REAL)
        / NULLIF(SUM(Exposure), 0),
        4
    ) AS ClaimFrequency,

    ROUND(
        SUM(TotalClaimAmount)
        / NULLIF(SUM(ActualClaimRecords), 0),
        2
    ) AS ClaimSeverity

FROM policy_claim_summary

GROUP BY Area
ORDER BY Area;


-- ============================================================
-- 4. Claims by fuel type
-- ============================================================

SELECT
    VehGas,
    COUNT(*) AS Policies,
    SUM(ActualClaimRecords) AS Claims,
    ROUND(SUM(TotalClaimAmount), 2) AS TotalClaimAmount,

    ROUND(
        CAST(SUM(ActualClaimRecords) AS REAL)
        / NULLIF(SUM(Exposure), 0),
        4
    ) AS ClaimFrequency,

    ROUND(
        SUM(TotalClaimAmount)
        / NULLIF(SUM(ActualClaimRecords), 0),
        2
    ) AS ClaimSeverity

FROM policy_claim_summary

GROUP BY VehGas
ORDER BY TotalClaimAmount DESC;


-- ============================================================
-- 5. Claims by vehicle brand group
-- ============================================================

SELECT
    VehBrand,
    COUNT(*) AS Policies,
    SUM(ActualClaimRecords) AS Claims,
    ROUND(SUM(TotalClaimAmount), 2) AS TotalClaimAmount,

    ROUND(
        CAST(SUM(ActualClaimRecords) AS REAL)
        / NULLIF(SUM(Exposure), 0),
        4
    ) AS ClaimFrequency,

    ROUND(
        SUM(TotalClaimAmount)
        / NULLIF(SUM(ActualClaimRecords), 0),
        2
    ) AS ClaimSeverity

FROM policy_claim_summary

GROUP BY VehBrand
ORDER BY TotalClaimAmount DESC;


-- ============================================================
-- 6. Driver age bands
-- ============================================================

WITH driver_age_bands AS (

    SELECT
        *,
        CASE
            WHEN DrivAge < 25 THEN '18-24'
            WHEN DrivAge < 35 THEN '25-34'
            WHEN DrivAge < 45 THEN '35-44'
            WHEN DrivAge < 55 THEN '45-54'
            WHEN DrivAge < 65 THEN '55-64'
            WHEN DrivAge < 75 THEN '65-74'
            ELSE '75+'
        END AS DriverAgeBand

    FROM policy_claim_summary
)

SELECT
    DriverAgeBand,
    COUNT(*) AS Policies,
    SUM(ActualClaimRecords) AS Claims,
    ROUND(SUM(TotalClaimAmount), 2) AS TotalClaimAmount,

    ROUND(
        CAST(SUM(ActualClaimRecords) AS REAL)
        / NULLIF(SUM(Exposure), 0),
        4
    ) AS ClaimFrequency,

    ROUND(
        SUM(TotalClaimAmount)
        / NULLIF(SUM(ActualClaimRecords), 0),
        2
    ) AS ClaimSeverity

FROM driver_age_bands

GROUP BY DriverAgeBand

ORDER BY
    CASE DriverAgeBand
        WHEN '18-24' THEN 1
        WHEN '25-34' THEN 2
        WHEN '35-44' THEN 3
        WHEN '45-54' THEN 4
        WHEN '55-64' THEN 5
        WHEN '65-74' THEN 6
        WHEN '75+' THEN 7
    END;


-- ============================================================
-- 7. Vehicle age bands
-- ============================================================

WITH vehicle_age_bands AS (

    SELECT
        *,
        CASE
            WHEN VehAge <= 2 THEN '0-2'
            WHEN VehAge <= 5 THEN '3-5'
            WHEN VehAge <= 10 THEN '6-10'
            WHEN VehAge <= 15 THEN '11-15'
            WHEN VehAge <= 20 THEN '16-20'
            ELSE '20+'
        END AS VehicleAgeBand

    FROM policy_claim_summary
)

SELECT
    VehicleAgeBand,
    COUNT(*) AS Policies,
    SUM(ActualClaimRecords) AS Claims,
    ROUND(SUM(TotalClaimAmount), 2) AS TotalClaimAmount,

    ROUND(
        CAST(SUM(ActualClaimRecords) AS REAL)
        / NULLIF(SUM(Exposure), 0),
        4
    ) AS ClaimFrequency,

    ROUND(
        SUM(TotalClaimAmount)
        / NULLIF(SUM(ActualClaimRecords), 0),
        2
    ) AS ClaimSeverity

FROM vehicle_age_bands

GROUP BY VehicleAgeBand

ORDER BY
    CASE VehicleAgeBand
        WHEN '0-2' THEN 1
        WHEN '3-5' THEN 2
        WHEN '6-10' THEN 3
        WHEN '11-15' THEN 4
        WHEN '16-20' THEN 5
        WHEN '20+' THEN 6
    END;


-- ============================================================
-- 8. Bonus-Malus risk bands
-- ============================================================

WITH bonus_malus_bands AS (

    SELECT
        *,
        CASE
            WHEN BonusMalus <= 50 THEN '50'
            WHEN BonusMalus <= 75 THEN '51-75'
            WHEN BonusMalus <= 100 THEN '76-100'
            WHEN BonusMalus <= 125 THEN '101-125'
            ELSE '126+'
        END AS BonusMalusBand

    FROM policy_claim_summary
)

SELECT
    BonusMalusBand,
    COUNT(*) AS Policies,
    SUM(ActualClaimRecords) AS Claims,
    ROUND(SUM(TotalClaimAmount), 2) AS TotalClaimAmount,

    ROUND(
        CAST(SUM(ActualClaimRecords) AS REAL)
        / NULLIF(SUM(Exposure), 0),
        4
    ) AS ClaimFrequency,

    ROUND(
        SUM(TotalClaimAmount)
        / NULLIF(SUM(ActualClaimRecords), 0),
        2
    ) AS ClaimSeverity

FROM bonus_malus_bands

GROUP BY BonusMalusBand

ORDER BY
    CASE BonusMalusBand
        WHEN '50' THEN 1
        WHEN '51-75' THEN 2
        WHEN '76-100' THEN 3
        WHEN '101-125' THEN 4
        WHEN '126+' THEN 5
    END;


-- ============================================================
-- 9. Large-loss analysis
-- ============================================================

SELECT
    COUNT(*) AS ClaimsOver100k,
    ROUND(SUM(ClaimAmount), 2) AS TotalLargeLossAmount,

    ROUND(
        100.0 * SUM(ClaimAmount)
        / (SELECT SUM(ClaimAmount) FROM claims_clean),
        2
    ) AS PercentOfTotalClaimCost

FROM claims_clean
WHERE ClaimAmount >= 100000;


-- ============================================================
-- 10. Data quality KPI summary
-- ============================================================

SELECT
    COUNT(*) AS TotalPolicies,

    SUM(ClaimCountMismatchFlag) AS ClaimCountMismatches,

    ROUND(
        100.0 * SUM(ClaimCountMismatchFlag) / COUNT(*),
        2
    ) AS ClaimCountMismatchRate,

    SUM(ExposureOverOneFlag) AS ExposureOverOne,

    ROUND(
        100.0 * SUM(ExposureOverOneFlag) / COUNT(*),
        2
    ) AS ExposureOverOneRate

FROM policies_clean;