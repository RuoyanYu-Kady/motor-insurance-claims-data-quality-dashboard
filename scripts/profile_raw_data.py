import pandas as pd

POLICIES_PATH = "data/raw/policies_raw.csv"
CLAIMS_PATH = "data/raw/claims_raw.csv"

policies = pd.read_csv(POLICIES_PATH)
claims = pd.read_csv(CLAIMS_PATH)

print("=" * 70)
print("1. BASIC INFORMATION")
print("=" * 70)

print("\nPOLICIES")
print("Rows:", len(policies))
print("Columns:", len(policies.columns))
print("\nData types:")
print(policies.dtypes)

print("\nCLAIMS")
print("Rows:", len(claims))
print("Columns:", len(claims.columns))
print("\nData types:")
print(claims.dtypes)


print("\n" + "=" * 70)
print("2. MISSING VALUES")
print("=" * 70)

print("\nPolicies missing values:")
print(policies.isnull().sum())

print("\nClaims missing values:")
print(claims.isnull().sum())


print("\n" + "=" * 70)
print("3. DUPLICATE ROWS")
print("=" * 70)

print("Duplicate policy rows:", policies.duplicated().sum())
print("Duplicate claim rows:", claims.duplicated().sum())


print("\n" + "=" * 70)
print("4. POLICY ID CHECKS")
print("=" * 70)

print("Unique policy IDs:", policies["IDpol"].nunique())
print("Duplicate policy IDs:", policies["IDpol"].duplicated().sum())

print("Unique policy IDs in claims:", claims["IDpol"].nunique())

claim_policy_ids_not_found = ~claims["IDpol"].isin(policies["IDpol"])

print(
    "Claim records with Policy ID not found in policies:",
    claim_policy_ids_not_found.sum()
)


print("\n" + "=" * 70)
print("5. NUMERIC RANGE CHECKS")
print("=" * 70)

numeric_policy_columns = [
    "ClaimNb",
    "Exposure",
    "VehPower",
    "VehAge",
    "DrivAge",
    "BonusMalus",
    "Density"
]

for column in numeric_policy_columns:
    print(f"\n{column}")
    print("Min:", policies[column].min())
    print("Max:", policies[column].max())
    print("Mean:", policies[column].mean())

print("\nClaimAmount")
print("Min:", claims["ClaimAmount"].min())
print("Max:", claims["ClaimAmount"].max())
print("Mean:", claims["ClaimAmount"].mean())
print("Median:", claims["ClaimAmount"].median())


print("\n" + "=" * 70)
print("6. INVALID OR SUSPICIOUS VALUES")
print("=" * 70)

print("Exposure <= 0:", (policies["Exposure"] <= 0).sum())
print("Exposure > 1:", (policies["Exposure"] > 1).sum())

print("ClaimNb < 0:", (policies["ClaimNb"] < 0).sum())
print("ClaimAmount <= 0:", (claims["ClaimAmount"] <= 0).sum())

print("Driver age < 18:", (policies["DrivAge"] < 18).sum())
print("Vehicle age < 0:", (policies["VehAge"] < 0).sum())
print("Density <= 0:", (policies["Density"] <= 0).sum())


print("\n" + "=" * 70)
print("7. CATEGORICAL VALUES")
print("=" * 70)

categorical_columns = [
    "Area",
    "VehBrand",
    "VehGas",
    "Region"
]

for column in categorical_columns:
    print(f"\n{column}")
    print(policies[column].value_counts(dropna=False).sort_index())


print("\n" + "=" * 70)
print("8. POLICY VS ACTUAL CLAIM COUNT")
print("=" * 70)

actual_claim_counts = (
    claims.groupby("IDpol")
    .size()
    .rename("ActualClaimCount")
)

comparison = policies[
    ["IDpol", "ClaimNb"]
].merge(
    actual_claim_counts,
    on="IDpol",
    how="left"
)

comparison["ActualClaimCount"] = (
    comparison["ActualClaimCount"]
    .fillna(0)
    .astype(int)
)

comparison["ClaimCountMismatch"] = (
    comparison["ClaimNb"] != comparison["ActualClaimCount"]
)

print(
    "Policies where ClaimNb does not match actual claim records:",
    comparison["ClaimCountMismatch"].sum()
)

print("\nExamples:")
print(
    comparison[
        comparison["ClaimCountMismatch"]
    ].head(20)
)


print("\n" + "=" * 70)
print("9. CLAIM AMOUNT OUTLIERS")
print("=" * 70)

print(claims["ClaimAmount"].describe(
    percentiles=[0.90, 0.95, 0.99, 0.999]
))