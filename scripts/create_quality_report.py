import pandas as pd
from pathlib import Path

OUTPUT_DIR = Path("excel")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

summary = pd.DataFrame([
    ["Raw Policy Records", 678013, "Pass"],
    ["Raw Claim Records", 26639, "Pass"],
    ["Missing Values", 0, "Pass"],
    ["Duplicate Policy IDs", 0, "Pass"],
    ["Claim Count Mismatches", 9117, "Review"],
    ["Orphan Claim Records", 195, "Issue"],
    ["Orphan Policy IDs", 6, "Issue"],
    ["Identical Claim Combinations", 241, "Review"],
    ["Exposure > 1", 1224, "Review"],
    ["Invalid Claim Amounts", 0, "Pass"],
    ["Clean Claim Records", 26444, "Pass"],
], columns=["Metric", "Result", "Status"])


rules = pd.DataFrame([
    ["Missing values", "Required fields should not be NULL", "Flag"],
    ["Duplicate policy ID", "Policy ID should be unique", "Investigate"],
    ["Orphan claims", "Claim must match an existing policy", "Exclude from analytical claims"],
    ["Claim count mismatch", "ClaimNb should match available claim records", "Flag only"],
    ["Identical claims", "Same Policy ID and Claim Amount", "Retain and flag"],
    ["Exposure > 1", "Potentially unusual exposure", "Retain and flag"],
    ["Claim Amount <= 0", "Claim amount must be positive", "Exclude"],
    ["Extreme claim amount", "Potential large-loss claim", "Retain"],
    ["Driver age < 18", "Driver must be at least 18", "Exclude if present"],
    ["Extreme ages", "Potential valid or top-coded values", "Retain"],
], columns=["Check", "Rule", "Treatment"])


mismatches = pd.read_csv(
    "data/quality_checks/claim_count_mismatches.csv"
)

orphans = pd.read_csv(
    "data/quality_checks/orphan_claims.csv"
)


output_file = OUTPUT_DIR / "insurance_data_quality_check.xlsx"

with pd.ExcelWriter(
    output_file,
    engine="openpyxl"
) as writer:

    summary.to_excel(
        writer,
        sheet_name="Summary",
        index=False
    )

    rules.to_excel(
        writer,
        sheet_name="Quality_Rules",
        index=False
    )

    mismatches.to_excel(
        writer,
        sheet_name="Claim_Mismatches",
        index=False
    )

    orphans.to_excel(
        writer,
        sheet_name="Orphan_Claims",
        index=False
    )


print(f"Created: {output_file}")