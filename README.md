# Motor Insurance Claims Data Quality & Risk Analytics Dashboard

An end-to-end insurance analytics project using **Python, SQL, Excel and Tableau** to validate data quality, transform policy and claims data, and analyse motor insurance risk patterns.

The project uses the publicly available **freMTPL2 French Motor Third-Party Liability insurance dataset** and focuses on both **data quality** and **insurance risk analytics**.

---

## Dashboard Preview

![Motor Insurance Claims Data Quality & Risk Analytics Dashboard](images/dashboard_preview.png)

---

## Project Overview

This project analyses a real-world motor insurance portfolio containing more than **678,000 policy records** and **26,000 claim records**.

The main objectives were to:

- profile and validate raw policy and claims data;
- identify data-quality issues before analysis;
- build reproducible cleaning and validation logic using SQL;
- create an analytical policy-level dataset;
- calculate insurance risk metrics such as claim frequency and claim severity;
- investigate driver, vehicle and regional risk patterns;
- build an interactive Tableau dashboard;
- produce an Excel data-quality audit report.

The project follows the workflow below:

```text
Raw Insurance Data
        ↓
Python Data Profiling
        ↓
SQL Data Quality Validation
        ↓
SQL Cleaning and Transformation
        ↓
Clean Analytical Tables
        ↓
Insurance Risk Analysis
        ↓
Excel Data Quality Report
        ↓
Tableau Dashboard
```

---

## Data Source

The project uses the publicly available **freMTPL2 French Motor Third-Party Liability insurance dataset**.

The dataset is commonly used for actuarial and insurance analytics research and contains policy-level risk characteristics together with motor insurance claim information.

### Source Documentation

- [CASdatasets - freMTPL2 Documentation](https://dutangc.github.io/CASdatasets/reference/freMTPL.html)
- [OpenML - freMTPL2freq](https://www.openml.org/d/41214)
- [OpenML - freMTPL2sev](https://www.openml.org/d/41215)

The OpenML datasets used in this project are:

- `freMTPL2freq` — policy characteristics, exposure and reported claim count;
- `freMTPL2sev` — individual claim amounts linked to policies.

### Policy Variables

The policy dataset contains fields including:

- Policy ID;
- Claim Count;
- Exposure;
- Area;
- Vehicle Power;
- Vehicle Age;
- Driver Age;
- Bonus-Malus;
- Vehicle Brand;
- Fuel Type;
- Population Density;
- Region.

The claims dataset contains:

- Policy ID;
- Claim Amount.

---

## Dataset Size

| Dataset | Records |
|---|---:|
| Raw Policy Records | 678,013 |
| Raw Claim Records | 26,639 |
| Clean Policy Records | 678,013 |
| Clean Claim Records | 26,444 |

A total of **195 orphan claim records** were excluded from the analytical claims table because their policy IDs could not be matched to the policy dataset.

---

## Tools Used

| Tool | Purpose |
|---|---|
| **Python** | Raw-data profiling, validation and investigation |
| **SQL / SQLite** | Data-quality checks, cleaning, transformation and analysis |
| **Excel** | Data-quality audit report |
| **Tableau** | Interactive dashboard and risk visualisation |
| **Git / GitHub** | Version control and project documentation |

---

# Data Quality Assessment

The raw data was profiled before any cleaning decisions were made.

The objective was not to automatically delete unusual records, but to distinguish between:

- clearly invalid records;
- referential-integrity problems;
- potential data-quality issues;
- legitimate insurance outliers.

## Key Data Quality Findings

| Data Quality Check | Result |
|---|---:|
| Missing Values | 0 |
| Duplicate Policy IDs | 0 |
| Identical Policy-Claim Amount Combinations | 241 |
| Orphan Claim Records | 195 |
| Orphan Policy IDs | 6 |
| Claim Count Mismatches | 9,117 |
| Policies With Exposure Greater Than 1 | 1,224 |
| Invalid Claim Amounts | 0 |

---

## Data Quality Treatment

### Orphan Claims

**195 claim records** referenced policy IDs that were not present in the policy dataset.

These records were excluded from the analytical claims table because policy attributes could not be reliably attached to them.

---

### Claim Count Mismatches

**9,117 policies** had a reported `ClaimNb` value that differed from the number of available claim records.

These policies were:

- retained in the analytical dataset;
- assigned a data-quality flag;
- not automatically corrected.

This preserves the original source information while making the inconsistency visible.

---

### Identical Claim Records

There were **241 identical Policy ID + Claim Amount combinations**.

These records were retained because the source dataset does not contain a unique Claim ID.

As a result, two identical claim amounts for the same policy cannot safely be classified as duplicates.

---

### Exposure Greater Than One

**1,224 policies** had exposure values greater than 1.

These records were retained and flagged rather than deleted because an exposure above one is unusual but not sufficient evidence that the record is invalid.

---

### Large Claims

Extreme claim amounts were retained.

Large losses are an important part of insurance risk analysis and should not automatically be treated as data errors.

---

# Data Model

The project uses a one-to-many relationship between policies and claims.

```text
Policies
   |
   | IDpol
   |
   └──────────────< Claims
```

The main cleaned analytical tables are:

- `policies_clean`
- `claims_clean`
- `policy_claim_summary`

The `policy_claim_summary` table combines:

- policy characteristics;
- actual claim counts;
- total claim amounts;
- claim severity measures;
- claim frequency measures;
- data-quality flags.

This table is used as the main analytical source for Tableau.

---

# Core Portfolio Metrics

## Total Policies

**678,013**

---

## Total Claims

**26,444**

---

## Total Claim Amount

**€59.91M**

---

## Claim Frequency

Claim Frequency is calculated as:

```text
Total Claims / Total Exposure
```

Portfolio Claim Frequency:

**7.38%**

This represents approximately **7.38 claims per 100 exposure-years**.

---

## Average Claim Severity

Average Claim Severity is calculated as:

```text
Total Claim Amount / Total Claims
```

Portfolio Average Claim Severity:

**€2,265.51**

---

# Key Findings

## 1. Younger Drivers Showed Much Higher Risk

Drivers aged **18–24** had a claim frequency of approximately:

**16.10%**

This was more than double the claim frequency observed in most other driver-age groups.

The same group also had an average claim severity of approximately:

**€5,838.56**

This was substantially higher than the overall portfolio average.

The result suggests that younger drivers represented a significantly higher-risk segment in both claim frequency and claim cost.

---

## 2. Bonus-Malus Was Strongly Associated With Claim Frequency

Claim frequency increased sharply across higher Bonus-Malus groups.

| Bonus-Malus Band | Claim Frequency |
|---|---:|
| 50 | 5.15% |
| 51–75 | 9.23% |
| 76–100 | 12.86% |
| 101–125 | 34.17% |
| 126+ | 43.69% |

The relationship between Bonus-Malus and claim frequency was one of the strongest risk patterns identified in the portfolio.

Policies in the highest Bonus-Malus group recorded claim frequency more than eight times higher than policies in the lowest group.

---

## 3. Regional Risk Varied Significantly

Claim frequency and average claim severity differed across regions.

For example, **R21** had relatively few claims but showed very high average claim severity.

This demonstrates why regional insurance performance should not be assessed using severity alone.

Claim volume, exposure and frequency should also be considered before drawing conclusions about regional risk.

---

## 4. A Small Number of Large Claims Had a Major Financial Impact

Only **41 claims** had a claim amount of at least:

**€100,000**

However, these claims generated approximately:

**€14.71M**

in total claim cost.

This represented approximately:

**24.55% of total claim amount**

despite the very small number of claims involved.

This highlights the long-tail nature of insurance losses and the importance of large-loss monitoring.

---

## 5. Vehicle Age Was Also Associated With Claim Frequency

Claim frequency varied across vehicle-age groups.

| Vehicle Age | Claim Frequency |
|---|---:|
| 0–2 | 7.26% |
| 3–5 | 7.42% |
| 6–10 | 8.09% |
| 11–15 | 7.28% |
| 16–20 | 5.80% |
| 20+ | 4.02% |

Vehicles aged **6–10 years** recorded the highest claim frequency among the defined vehicle-age groups.

Vehicles over 20 years showed lower observed claim frequency.

---

## 6. Fuel Type Showed Different Frequency and Severity Patterns

The portfolio also showed differences between diesel and regular-fuel vehicles.

| Fuel Type | Claim Frequency | Average Claim Severity |
|---|---:|---:|
| Diesel | 7.88% | €2,051.65 |
| Regular | 6.92% | €2,486.88 |

Diesel vehicles showed higher claim frequency, while regular-fuel vehicles showed higher average claim severity.

This illustrates why both frequency and severity should be considered when evaluating insurance risk.

---

# Tableau Dashboard

The final Tableau dashboard provides a single-page view of the portfolio.

The dashboard includes five portfolio KPIs:

- Total Policies;
- Total Claims;
- Total Claim Amount;
- Claim Frequency;
- Average Claim Severity.

It also includes analysis of:

- Claim Frequency by Driver Age;
- Claim Frequency by Bonus-Malus;
- Average Claim Severity by Region;
- Total Claim Amount by Region;
- Claim Frequency by Vehicle Age.

A separate Data Quality section displays:

- Claim Count Mismatches;
- Claim Count Mismatch Rate;
- Exposure Over One.

The dashboard was designed to present both **business risk** and **underlying data quality** in the same analytical view.

---

# Excel Data Quality Report

An Excel-based data-quality report was generated as part of the project.

The workbook contains:

- `Summary`
- `Quality_Rules`
- `Claim_Mismatches`
- `Orphan_Claims`

File:

```text
excel/insurance_data_quality_check.xlsx
```

The report provides a simple audit view of the major data-quality issues identified during the validation process.

---

# SQL Workflow

The SQL workflow is divided into separate stages.

```text
sql/
├── 01_create_raw_tables.sql
├── 02_import_raw_data.sql
├── 03_data_quality_checks.sql
├── 04_create_clean_tables.sql
└── 05_analysis_queries.sql
```

### `01_create_raw_tables.sql`

Creates the raw policy and claim tables.

### `02_import_raw_data.sql`

Loads the source CSV files into SQLite.

### `03_data_quality_checks.sql`

Performs checks including:

- missing values;
- duplicate policy IDs;
- orphan claims;
- claim-count mismatches;
- invalid exposure;
- invalid claim amounts;
- extreme claim values.

### `04_create_clean_tables.sql`

Creates the cleaned policy, claim and analytical summary tables.

### `05_analysis_queries.sql`

Calculates portfolio metrics and performs risk analysis across:

- region;
- driver age;
- vehicle age;
- Bonus-Malus;
- fuel type;
- large claims.

---

# Python Workflow

Python is used primarily for profiling, validation and report generation.

```text
scripts/
├── profile_raw_data.py
├── investigate_quality_issues.py
└── create_quality_report.py
```

### `profile_raw_data.py`

Profiles the raw policy and claim datasets.

### `investigate_quality_issues.py`

Investigates unusual records and potential data-quality problems before cleaning decisions are made.

### `create_quality_report.py`

Generates the Excel data-quality audit workbook.

---

# Repository Structure

```text
motor-insurance-claims-data-quality-dashboard/
│
├── README.md
├── .gitignore
├── download_data.py
│
├── data/
│   ├── raw/
│   │   ├── policies_raw.csv
│   │   └── claims_raw.csv
│   │
│   ├── cleaned/
│   │   ├── policies_clean.csv
│   │   ├── claims_clean.csv
│   │   └── policy_claim_summary.csv
│   │
│   └── quality_checks/
│       ├── claim_count_mismatches.csv
│       ├── exposure_over_one.csv
│       ├── identical_claim_records.csv
│       ├── large_claims_top_1_percent.csv
│       └── orphan_claims.csv
│
├── scripts/
│   ├── profile_raw_data.py
│   ├── investigate_quality_issues.py
│   └── create_quality_report.py
│
├── sql/
│   ├── 01_create_raw_tables.sql
│   ├── 02_import_raw_data.sql
│   ├── 03_data_quality_checks.sql
│   ├── 04_create_clean_tables.sql
│   └── 05_analysis_queries.sql
│
├── excel/
│   └── insurance_data_quality_check.xlsx
│
├── images/
│   └── dashboard_preview.png
│
└── outputs/
    ├── business_analysis_results.txt
    └── sql_data_quality_results.txt
```

The SQLite database file is intentionally excluded from version control because it can be reproduced from the source CSV files and SQL scripts.

---

# How to Reproduce the Project

## 1. Clone the Repository

```bash
git clone https://github.com/RuoyanYu-Kady/motor-insurance-claims-data-quality-dashboard.git
```

Move into the project directory:

```bash
cd motor-insurance-claims-data-quality-dashboard
```

---

## 2. Download the Source Data

The source data can be obtained using:

```bash
python download_data.py
```

Alternatively, the original datasets are available through OpenML.

---

## 3. Profile the Raw Data

Run:

```bash
python scripts/profile_raw_data.py
```

Then investigate data-quality issues using:

```bash
python scripts/investigate_quality_issues.py
```

---

## 4. Create the SQLite Database

Run the SQL scripts in sequence:

```text
01_create_raw_tables.sql
02_import_raw_data.sql
03_data_quality_checks.sql
04_create_clean_tables.sql
05_analysis_queries.sql
```

These scripts create the raw database layer, validate the data, generate cleaned tables and calculate analytical metrics.

---

## 5. Generate the Data Quality Report

Run:

```bash
python scripts/create_quality_report.py
```

This produces:

```text
excel/insurance_data_quality_check.xlsx
```

---

## 6. Build the Tableau Dashboard

Use:

```text
data/cleaned/policy_claim_summary.csv
```

as the main Tableau data source.

Calculated fields used in Tableau include:

```text
Claim Frequency =
SUM(Actual Claim Records) / SUM(Exposure)
```

and:

```text
Average Claim Severity =
SUM(Total Claim Amount) / SUM(Actual Claim Records)
```

---

# Data Interpretation Notes

This dataset does **not** contain premium information.

Therefore, this project does not calculate:

- Written Premium;
- Earned Premium;
- Loss Ratio;
- Combined Ratio.

No premium values were estimated or fabricated.

The analysis focuses only on metrics supported by the available data.

---

# Project Outcome

This project demonstrates an end-to-end insurance analytics workflow covering:

- raw-data profiling;
- data-quality assessment;
- SQL validation;
- data cleaning;
- relational data preparation;
- insurance KPI development;
- risk segmentation;
- large-loss analysis;
- Excel reporting;
- Tableau dashboard development;
- Git-based project documentation.

The final output combines data engineering, data-quality analysis and business-focused insurance analytics in a reproducible portfolio project.
