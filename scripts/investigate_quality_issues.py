import pandas as pd
from pathlib import Path

policies = pd.read_csv("data/raw/policies_raw.csv")
claims = pd.read_csv("data/raw/claims_raw.csv")

OUTPUT_DIR = Path("data/quality_checks")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)


print("=" * 70)
print("1. CLAIM COUNT MISMATCH DETAILS")
print("=" * 70)

actual_counts = (
    claims.groupby("IDpol")
    .size()
    .rename("ActualClaimCount")
)

comparison = policies[
    ["IDpol", "ClaimNb"]
].merge(
    actual_counts,
    on="IDpol",
    how="left"
)

comparison["ActualClaimCount"] = (
    comparison["ActualClaimCount"]
    .fillna(0)
    .astype(int)
)

comparison["Difference"] = (
    comparison["ClaimNb"] -
    comparison["ActualClaimCount"]
)

mismatches = comparison[
    comparison["Difference"] != 0
].copy()

print("Total mismatched policies:", len(mismatches))

print("\nDifference distribution:")
print(
    mismatches["Difference"]
    .value_counts()
    .sort_index()
)

print("\nClaimNb > actual claims:")
print((mismatches["Difference"] > 0).sum())

print("ClaimNb < actual claims:")
print((mismatches["Difference"] < 0).sum())

mismatches.to_csv(
    OUTPUT_DIR / "claim_count_mismatches.csv",
    index=False
)


print("\n" + "=" * 70)
print("2. ORPHAN CLAIM RECORDS")
print("=" * 70)

orphan_claims = claims[
    ~claims["IDpol"].isin(policies["IDpol"])
].copy()

print("Orphan claim records:", len(orphan_claims))
print("Unique orphan policy IDs:", orphan_claims["IDpol"].nunique())

print("\nExamples:")
print(orphan_claims.head(20))

orphan_claims.to_csv(
    OUTPUT_DIR / "orphan_claims.csv",
    index=False
)


print("\n" + "=" * 70)
print("3. IDENTICAL CLAIM RECORDS")
print("=" * 70)

duplicate_claims = claims[
    claims.duplicated(keep=False)
].sort_values(
    ["IDpol", "ClaimAmount"]
)

print("Rows involved in identical records:", len(duplicate_claims))

print(
    "Unique duplicated combinations:",
    duplicate_claims[
        ["IDpol", "ClaimAmount"]
    ].drop_duplicates().shape[0]
)

print("\nExamples:")
print(duplicate_claims.head(30))

duplicate_claims.to_csv(
    OUTPUT_DIR / "identical_claim_records.csv",
    index=False
)


print("\n" + "=" * 70)
print("4. EXPOSURE > 1")
print("=" * 70)

high_exposure = policies[
    policies["Exposure"] > 1
].copy()

print("Exposure > 1:", len(high_exposure))

print("\nExposure distribution:")
print(high_exposure["Exposure"].describe())

print("\nHighest exposures:")
print(
    high_exposure[
        ["IDpol", "Exposure", "ClaimNb"]
    ]
    .sort_values("Exposure", ascending=False)
    .head(20)
)

high_exposure.to_csv(
    OUTPUT_DIR / "exposure_over_one.csv",
    index=False
)


print("\n" + "=" * 70)
print("5. AGE EXTREMES")
print("=" * 70)

print("Driver age >= 90:")
print(
    policies[
        policies["DrivAge"] >= 90
    ]["DrivAge"].value_counts().sort_index()
)

print("\nVehicle age >= 40:")
print(
    policies[
        policies["VehAge"] >= 40
    ]["VehAge"].value_counts().sort_index()
)


print("\n" + "=" * 70)
print("6. LARGE CLAIMS")
print("=" * 70)

large_claims = claims[
    claims["ClaimAmount"] >
    claims["ClaimAmount"].quantile(0.99)
].copy()

print("Claims above 99th percentile:", len(large_claims))

print("\nTop 20 claims:")
print(
    claims.sort_values(
        "ClaimAmount",
        ascending=False
    ).head(20)
)

large_claims.to_csv(
    OUTPUT_DIR / "large_claims_top_1_percent.csv",
    index=False
)