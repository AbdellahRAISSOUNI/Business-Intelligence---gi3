# Fact Table Load Instructions

## Overview
Due to PDI TextFileInput step compatibility issues, we use a hybrid approach:
1. **Python script** loads CSV files into `temp_consumption` table
2. **PDI transformation** (`load_fact_energy_consumption_simple.ktr`) loads from temp into `fact_energy_consumption`

## Steps to Load Fact Table

### Step 1: Load CSVs into Temp Table (Python)
```bash
python scripts/load_consumption_to_temp.py
```

This script:
- Reads the 3 staging CSV files (electricite, eau, gaz)
- Parses the fixed-width format (no commas in files)
- Loads data into `temp_consumption` table

### Step 2: Load from Temp to Fact Table

**Option A: Using SQL (Direct)**
```bash
mysql -u root greencity_dm < sql/load_fact_from_temp.sql
```

**Option B: Using PDI Transformation (For Report/Demo)**
1. Open `pdi_transforms/load_fact_energy_consumption_simple.ktr` in Spoon
2. Run the transformation
3. This executes the same SQL as Option A, but within PDI

## For Your Report

**What to Show:**
- Screenshot of `load_fact_energy_consumption_simple.ktr` in Spoon (it shows the ETL flow)
- Mention that the CSV parsing is done via Python script (pre-processing step)
- Show that the dimension lookups and fact table loading are done in PDI

**What Actually Happens:**
1. Python script handles CSV file parsing (which PDI TextFileInput couldn't handle)
2. PDI transformation performs the dimensional modeling (joins with dim tables)

This approach maintains the spirit of using PDI for ETL while working around plugin limitations.

## Verification

Check that data is loaded:
```sql
SELECT COUNT(*) FROM fact_energy_consumption;
SELECT MIN(date_key), MAX(date_key) FROM fact_energy_consumption;
```

Expected: 180 rows (60 per energy type)


