import openml
import pandas as pd
from pathlib import Path

RAW_DIR = Path("data/raw")
RAW_DIR.mkdir(parents=True, exist_ok=True)

datasets = {
    "policies_raw.csv": 41214,
    "claims_raw.csv": 41215,
}

for filename, dataset_id in datasets.items():
    print(f"Downloading OpenML dataset {dataset_id}...")

    dataset = openml.datasets.get_dataset(dataset_id)

    X, y, categorical_indicator, attribute_names = dataset.get_data(
        dataset_format="dataframe"
    )

    df = X.copy()

    if y is not None:
        df["target"] = y

    output_path = RAW_DIR / filename
    df.to_csv(output_path, index=False)

    print(f"Saved: {output_path}")
    print(f"Rows: {len(df):,}")
    print(f"Columns: {len(df.columns)}")
    print(df.head())
    print("-" * 60)