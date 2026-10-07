-- ============================================================
-- Motor Insurance Claims Data Quality Checks
-- ============================================================

-- 1. Basic row counts
SELECT 'policies' AS table_name, COUNT(*) AS row_count
FROM policies_raw

UNION ALL

SELECT 'claims', COUNT(*)
FROM claims_raw;


-- ============================================================
-- 2. Missing value checks
-- ============================================================

SELECT
    SUM(CASE WHEN IDpol IS NULL THEN 1 ELSE 0 END) AS missing_IDpol,
    SUM(CASE WHEN ClaimNb IS NULL THEN 1 ELSE 0 END) AS missing_ClaimNb,
    SUM(CASE WHEN Exposure IS NULL THEN 1 ELSE 0 END) AS missing_Exposure,
    SUM(CASE WHEN Area IS NULL THEN 1 ELSE 0 END) AS missing_Area,
    SUM(CASE WHEN VehPower IS NULL THEN 1 ELSE 0 END) AS missing_VehPower,
    SUM(CASE WHEN VehAge IS NULL THEN 1 ELSE 0 END) AS missing_VehAge,
    SUM(CASE WHEN DrivAge IS NULL THEN 1 ELSE 0 END) AS missing_DrivAge,
    SUM(CASE WHEN BonusMalus IS NULL THEN 1 ELSE 0 END) AS missing_BonusMalus,
    SUM(CASE WHEN VehBrand IS NULL THEN 1 ELSE 0 END) AS missing_VehBrand,
    SUM(CASE WHEN VehGas IS NULL THEN 1 ELSE 0 END) AS missing_VehGas,
    SUM(CASE WHEN Density IS NULL THEN 1 ELSE 0 END) AS missing_Density,
    SUM(CASE WHEN Region IS NULL THEN 1 ELSE 0 END) AS missing_Region
FROM policies_raw;


SELECT
    SUM(CASE WHEN IDpol IS NULL THEN 1 ELSE 0 END) AS missing_IDpol,
    SUM(CASE WHEN ClaimAmount IS NULL THEN 1 ELSE 0 END) AS missing_ClaimAmount
FROM claims_raw;


-- ============================================================
-- 3. Duplicate policy IDs
-- ============================================================

SELECT
    IDpol,
    COUNT(*) AS record_count
FROM policies_raw
GROUP BY IDpol
HAVING COUNT(*) > 1;


-- ============================================================
-- 4. Exact duplicate claim records
-- ============================================================

SELECT
    IDpol,
    ClaimAmount,
    COUNT(*) AS duplicate_count
FROM claims_raw
GROUP BY IDpol, ClaimAmount
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


-- Count duplicated claim combinations
SELECT COUNT(*) AS duplicated_claim_combinations
FROM (
    SELECT
        IDpol,
        ClaimAmount
    FROM claims_raw
    GROUP BY IDpol, ClaimAmount
    HAVING COUNT(*) > 1
);


-- ============================================================
-- 5. Orphan claim records
-- Claim records whose Policy ID does not exist in policy table
-- ============================================================

SELECT COUNT(*) AS orphan_claim_records
FROM claims_raw c
LEFT JOIN policies_raw p
    ON c.IDpol = p.IDpol
WHERE p.IDpol IS NULL;


SELECT
    COUNT(DISTINCT c.IDpol) AS orphan_policy_ids
FROM claims_raw c
LEFT JOIN policies_raw p
    ON c.IDpol = p.IDpol
WHERE p.IDpol IS NULL;


-- Show orphan Policy IDs
SELECT
    c.IDpol,
    COUNT(*) AS claim_records,
    SUM(c.ClaimAmount) AS total_claim_amount
FROM claims_raw c
LEFT JOIN policies_raw p
    ON c.IDpol = p.IDpol
WHERE p.IDpol IS NULL
GROUP BY c.IDpol
ORDER BY claim_records DESC;


-- ============================================================
-- 6. Claim count consistency check
-- ============================================================

WITH actual_claim_counts AS (
    SELECT
        IDpol,
        COUNT(*) AS actual_claim_count
    FROM claims_raw
    GROUP BY IDpol
),

claim_comparison AS (
    SELECT
        p.IDpol,
        p.ClaimNb,
        COALESCE(a.actual_claim_count, 0) AS actual_claim_count,
        p.ClaimNb - COALESCE(a.actual_claim_count, 0) AS difference
    FROM policies_raw p
    LEFT JOIN actual_claim_counts a
        ON p.IDpol = a.IDpol
)

SELECT COUNT(*) AS mismatched_policies
FROM claim_comparison
WHERE ClaimNb != actual_claim_count;


-- Difference distribution
WITH actual_claim_counts AS (
    SELECT
        IDpol,
        COUNT(*) AS actual_claim_count
    FROM claims_raw
    GROUP BY IDpol
),

claim_comparison AS (
    SELECT
        p.IDpol,
        p.ClaimNb,
        COALESCE(a.actual_claim_count, 0) AS actual_claim_count,
        p.ClaimNb - COALESCE(a.actual_claim_count, 0) AS difference
    FROM policies_raw p
    LEFT JOIN actual_claim_counts a
        ON p.IDpol = a.IDpol
)

SELECT
    difference,
    COUNT(*) AS policy_count
FROM claim_comparison
WHERE difference != 0
GROUP BY difference
ORDER BY difference;


-- ============================================================
-- 7. Numeric validation checks
-- ============================================================

SELECT
    SUM(CASE WHEN Exposure <= 0 THEN 1 ELSE 0 END) AS invalid_exposure_zero_or_negative,
    SUM(CASE WHEN Exposure > 1 THEN 1 ELSE 0 END) AS exposure_over_one,
    SUM(CASE WHEN ClaimNb < 0 THEN 1 ELSE 0 END) AS negative_claim_count,
    SUM(CASE WHEN DrivAge < 18 THEN 1 ELSE 0 END) AS underage_drivers,
    SUM(CASE WHEN VehAge < 0 THEN 1 ELSE 0 END) AS negative_vehicle_age,
    SUM(CASE WHEN Density <= 0 THEN 1 ELSE 0 END) AS invalid_density
FROM policies_raw;


SELECT
    SUM(CASE WHEN ClaimAmount <= 0 THEN 1 ELSE 0 END) AS invalid_claim_amount,
    MIN(ClaimAmount) AS minimum_claim_amount,
    MAX(ClaimAmount) AS maximum_claim_amount,
    AVG(ClaimAmount) AS average_claim_amount
FROM claims_raw;


-- ============================================================
-- 8. Extreme ages
-- ============================================================

SELECT
    DrivAge,
    COUNT(*) AS policy_count
FROM policies_raw
WHERE DrivAge >= 90
GROUP BY DrivAge
ORDER BY DrivAge;


SELECT
    VehAge,
    COUNT(*) AS policy_count
FROM policies_raw
WHERE VehAge >= 40
GROUP BY VehAge
ORDER BY VehAge;


-- ============================================================
-- 9. Categorical validation
-- ============================================================

SELECT
    Area,
    COUNT(*) AS policy_count
FROM policies_raw
GROUP BY Area
ORDER BY Area;


SELECT
    VehGas,
    COUNT(*) AS policy_count
FROM policies_raw
GROUP BY VehGas
ORDER BY VehGas;


SELECT
    Region,
    COUNT(*) AS policy_count
FROM policies_raw
GROUP BY Region
ORDER BY Region;


-- ============================================================
-- 10. Largest claim amounts
-- ============================================================

SELECT
    IDpol,
    ClaimAmount
FROM claims_raw
ORDER BY ClaimAmount DESC
LIMIT 20;