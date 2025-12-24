# GreenCity Business Intelligence Project - Complete Implementation Guide

**Version:** 1.0  
**Date:** January 2025  
**Author:** Business Intelligence Project Team

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [System Architecture](#2-system-architecture)
3. [Prerequisites and Installation](#3-prerequisites-and-installation)
4. [Database Schema Design](#4-database-schema-design)
5. [Data Sources and Formats](#5-data-sources-and-formats)
6. [ETL Process - Complete Walkthrough](#6-etl-process---complete-walkthrough)
7. [Automation and Scheduling](#7-automation-and-scheduling)
8. [Power BI Reporting Setup](#8-power-bi-reporting-setup)
9. [Project Structure](#9-project-structure)
10. [Step-by-Step Implementation](#10-step-by-step-implementation)
11. [Troubleshooting](#11-troubleshooting)
12. [Appendix](#12-appendix)

---

## 1. Project Overview

### 1.1 Business Context

**GreenCity** is a fictional company managing smart buildings across different regions. The company needs a Business Intelligence (BI) system to:

- Monitor energy consumption (electricity, water, gas) by client, building, and region
- Analyze economic profitability (revenue, margins, payment rates)
- Measure environmental impact (CO₂ emissions, recycling rates)
- Enable data-driven decision-making through interactive dashboards

### 1.2 Project Objectives

This project implements a complete BI solution including:

1. **Three Independent Data Marts** (star schema design):
   - Energy Consumption Data Mart
   - Economic Profitability Data Mart
   - Environmental Impact Data Mart

2. **ETL Pipeline** using Pentaho Data Integration (PDI):
   - Extract data from heterogeneous sources (CSV, JSON, MySQL)
   - Transform and clean data
   - Load into data warehouse incrementally

3. **Automated Daily Execution** via Windows Task Scheduler

4. **Interactive Dashboards** in Power BI for visualization and analysis

### 1.3 Key Technologies

| Component | Technology |
|-----------|-----------|
| **Database** | MySQL 8.0+ |
| **ETL Tool** | Pentaho Data Integration (PDI) 10.2+ |
| **BI Tool** | Power BI Desktop |
| **Automation** | Windows Task Scheduler + Batch Scripts |
| **Scripting** | Python 3.x (for CSV parsing) |
| **ODBC Driver** | MySQL Connector/ODBC 8.0 |

---

## 2. System Architecture

### 2.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    DATA SOURCES                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────────────────┐      │
│  │   JSON   │  │   CSV    │  │   MySQL Operational  │      │
│  │  Files   │  │  Files   │  │      Database        │      │
│  └──────────┘  └──────────┘  └──────────────────────┘      │
│       │             │                    │                  │
│       └─────────────┼────────────────────┘                  │
└─────────────────────┼───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                   STAGING AREA (CSV)                         │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  consumption_electricite.csv                         │   │
│  │  consumption_eau.csv                                 │   │
│  │  consumption_gaz.csv                                 │   │
│  │  env_reports_01_2025.csv                             │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                  ETL PROCESS (PDI + Python)                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Extract → Transform → Load                          │   │
│  │  - JSON parsing (PDI)                                │   │
│  │  - CSV parsing (Python)                              │   │
│  │  - Data cleaning & validation                        │   │
│  │  - Dimension loading (PDI)                           │   │
│  │  - Fact table loading (PDI + SQL)                    │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│              DATA WAREHOUSE (greencity_dm)                   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Data Mart 1: Energy Consumption                      │   │
│  │  Data Mart 2: Economic Profitability                  │   │
│  │  Data Mart 3: Environmental Impact                    │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                  REPORTING LAYER (Power BI)                  │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  Dashboard 1: Energy Consumption Analysis            │   │
│  │  Dashboard 2: Economic Profitability Analysis        │   │
│  │  Dashboard 3: Environmental Impact Analysis          │   │
│  │  Dashboard 4: Combined Overview                      │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Data Flow

1. **Source Systems** generate data files (JSON, CSV) and store operational data in MySQL
2. **Staging Area** receives extracted raw data in CSV format
3. **ETL Pipeline** processes, cleans, and loads data into data warehouse
4. **Data Marts** store dimensional data for analytics
5. **Power BI** connects to data warehouse and creates interactive visualizations

---

## 3. Prerequisites and Installation

### 3.1 Required Software

#### MySQL Server
- **Version:** MySQL 8.0 or higher
- **Download:** https://dev.mysql.com/downloads/mysql/
- **Installation:** Install with default settings, set root password (or leave empty for development)

#### Pentaho Data Integration (PDI)
- **Version:** 10.2 or higher
- **Download:** https://sourceforge.net/projects/pentaho/files/
- **Installation:** Extract ZIP to a directory (e.g., `C:\Pentaho\data-integration`)
- **Note:** Requires Java 8 or higher (usually bundled)

#### Python
- **Version:** Python 3.8 or higher
- **Download:** https://www.python.org/downloads/
- **Required packages:** `mysql-connector-python`
  ```bash
  pip install mysql-connector-python
  ```

#### Power BI Desktop
- **Download:** Microsoft Store or https://powerbi.microsoft.com/desktop/
- **MySQL ODBC Driver:** Download from https://dev.mysql.com/downloads/connector/odbc/
  - Install the Windows 64-bit version

### 3.2 Directory Structure Setup

Create the following directory structure:

```
Business Intelligence - Mini Projet/
├── data_sources/
│   ├── csv/
│   │   ├── operational_seed/
│   │   └── env_reports_01_2025.csv
│   └── json/
│       ├── Electricite_consumption_01_2025.json
│       ├── Eau_consumption_01_2025.json
│       └── Gaz_consumption_01_2025.json
├── staging/
│   ├── consumption_electricite.csv
│   ├── consumption_eau.csv
│   └── consumption_gaz.csv
├── transformed/
├── sql/
├── pdi_transforms/
├── pdi_jobs/
├── scripts/
├── reports/
├── docs/
└── logs/
```

---

## 4. Database Schema Design

### 4.1 Operational Database (`greencity_operational`)

The operational database stores transactional data from business systems.

#### Tables

**`regions`** - Geographic regions
- `region_id` (PK, VARCHAR(10))
- `region_name` (VARCHAR(100))

**`clients`** - Clients/customers
- `client_id` (PK, VARCHAR(10))
- `client_name` (VARCHAR(150))

**`buildings`** - Buildings managed by GreenCity
- `building_id` (PK, VARCHAR(10))
- `building_name` (VARCHAR(150))
- `building_type` (VARCHAR(50))
- `surface_m2` (DECIMAL(10,2))
- `region_id` (FK → regions)
- `client_id` (FK → clients)

**`meters`** - Energy meters installed in buildings
- `meter_id` (PK, VARCHAR(15))
- `building_id` (FK → buildings)
- `energy_type` (VARCHAR(20)) - 'electricite', 'eau', 'gaz'
- `unit` (VARCHAR(10)) - 'KWh', 'm3'
- `installed_at` (DATE)

**`invoices`** - Invoice headers
- `invoice_id` (PK, VARCHAR(20))
- `invoice_number` (VARCHAR(50))
- `invoice_date` (DATE)
- `client_id` (FK → clients)
- `building_id` (FK → buildings)
- `period_start` (DATE)
- `period_end` (DATE)
- `total_ht` (DECIMAL(14,2))
- `total_ttc` (DECIMAL(14,2))
- `energy_cost` (DECIMAL(14,2))
- `status` (VARCHAR(20))

**`invoice_lines`** - Invoice line items
- `line_id` (PK, INT)
- `invoice_id` (FK → invoices)
- `energy_type` (VARCHAR(20))
- `consumption_qty` (DECIMAL(14,3))
- `unit_price` (DECIMAL(10,4))
- `line_ht` (DECIMAL(14,2))
- `line_ttc` (DECIMAL(14,2))

**`payments`** - Payment records
- `payment_id` (PK, INT)
- `invoice_id` (FK → invoices)
- `payment_date` (DATE)
- `amount_paid` (DECIMAL(14,2))
- `method` (VARCHAR(20))

**DDL Location:** `sql/operational_schema.sql`

### 4.2 Data Warehouse (`greencity_dm`)

The data warehouse uses a **star schema** design with three independent data marts.

#### 4.2.1 Shared Dimension Tables

**`dim_date`** - Time dimension
- `date_key` (PK, INT) - Format: YYYYMMDD (e.g., 20250114)
- `full_date` (DATE)
- `year` (INT)
- `quarter` (TINYINT)
- `month` (TINYINT)
- `month_name` (VARCHAR(20))
- `day` (TINYINT)
- `day_of_week` (TINYINT)
- `day_name` (VARCHAR(20))
- `created_at`, `updated_at` (TIMESTAMP)

**`dim_region`** - Geographic dimension
- `region_key` (PK, INT, AUTO_INCREMENT)
- `region_id` (VARCHAR(10), UNIQUE) - Business key
- `region_name` (VARCHAR(100))
- `created_at`, `updated_at` (TIMESTAMP)

**`dim_client`** - Client dimension
- `client_key` (PK, INT, AUTO_INCREMENT)
- `client_id` (VARCHAR(10), UNIQUE) - Business key
- `client_name` (VARCHAR(150))
- `created_at`, `updated_at` (TIMESTAMP)

**`dim_building`** - Building dimension
- `building_key` (PK, INT, AUTO_INCREMENT)
- `building_id` (VARCHAR(10), UNIQUE) - Business key
- `building_name` (VARCHAR(150))
- `building_type` (VARCHAR(50))
- `surface_m2` (DECIMAL(10,2))
- `region_key` (FK → dim_region)
- `client_key` (FK → dim_client)
- `created_at`, `updated_at` (TIMESTAMP)

**`dim_energy_type`** - Energy type dimension
- `energy_type_key` (PK, INT, AUTO_INCREMENT)
- `energy_type_code` (VARCHAR(20)) - Business key (part of composite)
- `unit` (VARCHAR(10)) - Business key (part of composite)
- `created_at`, `updated_at` (TIMESTAMP)
- UNIQUE(`energy_type_code`, `unit`)

**`dim_meter`** - Meter dimension
- `meter_key` (PK, INT, AUTO_INCREMENT)
- `meter_id` (VARCHAR(15), UNIQUE) - Business key
- `building_key` (FK → dim_building)
- `energy_type_key` (FK → dim_energy_type)
- `installed_at` (DATE)
- `created_at`, `updated_at` (TIMESTAMP)

#### 4.2.2 Data Mart 1: Energy Consumption

**`fact_energy_consumption`** - Fact table for consumption measurements
- `fact_id` (PK, BIGINT, AUTO_INCREMENT)
- `date_key` (FK → dim_date)
- `meter_key` (FK → dim_meter)
- `building_key` (FK → dim_building)
- `client_key` (FK → dim_client)
- `region_key` (FK → dim_region)
- `energy_type_key` (FK → dim_energy_type)
- **Measures:**
  - `consumption_value` (DECIMAL(14,3)) - Original unit (kWh or m³)
  - `consumption_kwh` (DECIMAL(14,3)) - Normalized to kWh (NULL for non-electricity)
- `created_at`, `updated_at` (TIMESTAMP)

**Granularity:** One row per meter reading (hourly measurements from IoT sensors)

**DDL Location:** `sql/datamart_consumption.sql`

#### 4.2.3 Data Mart 2: Economic Profitability

**Additional Dimensions:**

**`dim_invoice_status`** - Invoice status dimension
- `status_key` (PK, INT, AUTO_INCREMENT)
- `status_code` (VARCHAR(20), UNIQUE) - 'sent', 'paid', 'overdue', 'cancelled'
- `status_name` (VARCHAR(50))

**`dim_payment_method`** - Payment method dimension
- `method_key` (PK, INT, AUTO_INCREMENT)
- `method_code` (VARCHAR(20), UNIQUE) - 'transfer', 'card', 'cash', 'check'
- `method_name` (VARCHAR(50))

**`fact_economic_profitability`** - Fact table for economic analysis
- `fact_id` (PK, BIGINT, AUTO_INCREMENT)
- **Date Keys:**
  - `invoice_date_key` (FK → dim_date)
  - `period_start_key` (FK → dim_date)
  - `period_end_key` (FK → dim_date)
  - `payment_date_key` (FK → dim_date, nullable)
- **Dimension Keys:**
  - `client_key` (FK → dim_client)
  - `building_key` (FK → dim_building)
  - `region_key` (FK → dim_region)
  - `energy_type_key` (FK → dim_energy_type)
  - `status_key` (FK → dim_invoice_status)
  - `payment_method_key` (FK → dim_payment_method, nullable)
- **Measures:**
  - `revenue_ttc` (DECIMAL(14,2)) - Revenue including tax (from invoice_line)
  - `revenue_ht` (DECIMAL(14,2)) - Revenue before tax
  - `consumption_qty` (DECIMAL(14,3)) - Consumption quantity
  - `unit_price` (DECIMAL(10,4)) - Unit price
  - `invoice_total_ttc` (DECIMAL(14,2)) - Total invoice amount
  - `invoice_energy_cost` (DECIMAL(14,2)) - Energy cost
  - `line_margin` (DECIMAL(14,2)) - Calculated: revenue_ttc - proportional energy_cost
  - `margin_percentage` (DECIMAL(5,2)) - Margin as percentage
  - `invoice_amount_paid` (DECIMAL(14,2)) - Total paid for invoice
  - `line_amount_paid` (DECIMAL(14,2)) - Proportional amount paid for this line
  - `payment_rate` (DECIMAL(5,2)) - Payment rate percentage
- `created_at`, `updated_at` (TIMESTAMP)

**Granularity:** One row per invoice line item (allows analysis by energy type per invoice)

**DDL Location:** `sql/datamart_economic.sql`

#### 4.2.4 Data Mart 3: Environmental Impact

**`fact_environmental_impact`** - Fact table for environmental metrics
- `fact_id` (PK, BIGINT, AUTO_INCREMENT)
- `report_date_key` (FK → dim_date)
- `building_key` (FK → dim_building)
- `region_key` (FK → dim_region)
- **Measures:**
  - `emission_co2_kg` (DECIMAL(14,2)) - CO₂ emissions in kilograms
  - `taux_recyclage` (DECIMAL(5,2)) - Recycling rate (0.00 to 1.00)
  - `taux_recyclage_pct` (DECIMAL(5,2)) - Recycling rate as percentage (0 to 100)
- `created_at`, `updated_at` (TIMESTAMP)

**Granularity:** One row per building per report date (monthly reports)

**DDL Location:** `sql/datamart_environmental.sql`

---

## 5. Data Sources and Formats

### 5.1 JSON Files - IoT Consumption Data

**Location:** `data_sources/json/`

**Files:**
- `Electricite_consumption_01_2025.json`
- `Eau_consumption_01_2025.json`
- `Gaz_consumption_01_2025.json`

**Structure:**
```json
{
  "id_region": "REG01",
  "batiments": [
    {
      "id_batiment": "BAT001",
      "type_energie": "electricite",
      "unite": "KWh",
      "date_generation": "2025-01-14",
      "mesures": [
        {
          "compteur_id": "ELEC_001",
          "date_mesure": "2025-01-14T08:00:00",
          "consommation_kWh": 120.5
        }
      ]
    }
  ]
}
```

**Key Fields:**
- `id_region`: Region identifier
- `id_batiment`: Building identifier
- `type_energie`: Energy type ('electricite', 'eau', 'gaz')
- `unite`: Unit ('KWh' or 'm3')
- `compteur_id`: Meter identifier
- `date_mesure`: Measurement timestamp (ISO 8601)
- `consommation_kWh` / `consommation_m3`: Consumption value

### 5.2 CSV File - Environmental Reports

**Location:** `data_sources/csv/env_reports_01_2025.csv`

**Format:**
```csv
id_region,id_batiment,date_rapport,emission_CO2_kg,taux_recyclage
REG01,BAT001,2025-01-31,512,0.67
REG01,BAT002,2025-01-31,430,0.71
```

**Fields:**
- `id_region`: Region identifier
- `id_batiment`: Building identifier
- `date_rapport`: Report date (YYYY-MM-DD)
- `emission_CO2_kg`: CO₂ emissions in kilograms
- `taux_recyclage`: Recycling rate (0.00 to 1.00)

### 5.3 MySQL Operational Database

**Database:** `greencity_operational`

Contains master data and transactional records (see Section 4.1 for schema).

**Data Loading:** Seed data loaded from CSV files in `data_sources/csv/operational_seed/`

---

## 6. ETL Process - Complete Walkthrough

### 6.1 ETL Architecture Overview

The ETL process follows these stages:

1. **Extract:** JSON files → Staging CSVs (via PDI)
2. **Transform:** Clean and standardize data
3. **Load:** Staging → Data Warehouse (via Python + PDI + SQL)

**Hybrid Approach:** Due to PDI file input limitations, we use:
- **PDI** for JSON extraction and dimensional modeling
- **Python** for CSV parsing and temp table loading
- **SQL** for fact table loading with dimension lookups

### 6.2 Phase 1: Extract JSON to Staging

**PDI Transformations:**
- `pdi_transforms/ingest_consumption_electricite.ktr`
- `pdi_transforms/ingest_consumption_eau.ktr`
- `pdi_transforms/ingest_consumption_gaz.ktr`

**Steps in Each Transformation:**

1. **JSON Input Step:**
   - Read JSON file
   - Flatten nested structure (`batiments` → `mesures`)

2. **Select Values Step:**
   - Rename fields to standard names
   - Set data types

3. **Text File Output Step:**
   - Write to staging CSV (e.g., `staging/consumption_electricite.csv`)
   - Format: Fixed-width (no commas): `MTR00012025-01-14T08:00:00146.7`

**Output Format (Staging CSV):**
```
MTR00012025-01-14T08:00:00146.7
MTR00012025-01-14T09:00:00148.2
```

**Format Breakdown:**
- Positions 0-6: `compteur_id` (e.g., "MTR0001")
- Positions 7-26: `date_mesure` (e.g., "2025-01-14T08:00:00")
- Position 27+: `consommation` (e.g., "146.7")

**To Run:**
1. Open PDI Spoon
2. Open transformation file (e.g., `ingest_consumption_electricite.ktr`)
3. Click "Run" button
4. Verify output in `staging/` directory

### 6.3 Phase 2: Load Dimensions

Dimensions are loaded from the operational database using PDI transformations.

#### 6.3.1 Load dim_region

**Transformation:** `pdi_transforms/load_dim_region.ktr`

**Steps:**
1. **Table Input:** Read from `greencity_operational.regions`
2. **Insert/Update:** Upsert into `greencity_dm.dim_region`

**SQL Query:**
```sql
SELECT region_id, region_name
FROM greencity_operational.regions
```

#### 6.3.2 Load dim_client

**Transformation:** `pdi_transforms/load_dim_client.ktr`

**Steps:**
1. **Table Input:** Read from `greencity_operational.clients`
2. **Insert/Update:** Upsert into `greencity_dm.dim_client`

#### 6.3.3 Load dim_energy_type

**Transformation:** `pdi_transforms/load_dim_energy_type.ktr`

**Steps:**
1. **Data Grid:** Define energy types manually
   - ('electricite', 'KWh')
   - ('eau', 'm3')
   - ('gaz', 'm3')
2. **Insert/Update:** Upsert into `greencity_dm.dim_energy_type`

#### 6.3.4 Load dim_building

**Transformation:** `pdi_transforms/load_dim_building.ktr`

**Approach:** Uses SQL JOIN to resolve foreign keys directly.

**Steps:**
1. **Table Input:** Execute SQL with JOINs
```sql
SELECT 
    b.building_id,
    b.building_name,
    b.building_type,
    b.surface_m2,
    dr.region_key,
    dc.client_key
FROM greencity_operational.buildings b
LEFT JOIN greencity_dm.dim_region dr ON b.region_id = dr.region_id
LEFT JOIN greencity_dm.dim_client dc ON b.client_id = dc.client_id
```
2. **Select Values:** Set correct data types
3. **Insert/Update:** Upsert into `greencity_dm.dim_building`

**Why SQL JOIN instead of Database Lookup?**
- Avoids PDI plugin dependency issues
- More efficient for large datasets
- Simpler transformation flow

#### 6.3.5 Load dim_meter

**Transformation:** `pdi_transforms/load_dim_meter.ktr`

**Steps:**
1. **Table Input:** Execute SQL with JOINs
```sql
SELECT 
    m.meter_id,
    db.building_key,
    det.energy_type_key,
    m.installed_at
FROM greencity_operational.meters m
LEFT JOIN greencity_dm.dim_building db ON m.building_id = db.building_id
LEFT JOIN greencity_dm.dim_energy_type det 
    ON m.energy_type = det.energy_type_code 
    AND m.unit = det.unit
```
2. **Select Values:** Set data types
3. **Insert/Update:** Upsert into `greencity_dm.dim_meter`

#### 6.3.6 Load dim_date

**Transformation:** `pdi_transforms/load_dim_date.ktr`

**Approach:** Generates date dimension using SQL (no source table).

**Steps:**
1. **Table Input:** Execute SQL to generate dates (2024-01-01 to 2026-12-31)
```sql
SELECT 
    CAST(DATE_FORMAT(dt.full_date, '%Y%m%d') AS UNSIGNED) AS date_key,
    dt.full_date AS full_date,
    CAST(YEAR(dt.full_date) AS SIGNED) AS year,
    CAST(QUARTER(dt.full_date) AS SIGNED) AS quarter,
    CAST(MONTH(dt.full_date) AS SIGNED) AS month,
    DATE_FORMAT(dt.full_date, '%M') AS month_name,
    CAST(DAY(dt.full_date) AS SIGNED) AS day,
    CAST(DAYOFWEEK(dt.full_date) AS SIGNED) AS day_of_week,
    DATE_FORMAT(dt.full_date, '%W') AS day_name
FROM (
    SELECT DATE('2024-01-01') + INTERVAL (a.a + (10 * b.a) + (100 * c.a) + (1000 * d.a)) DAY AS full_date
    FROM (SELECT 0 AS a UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) AS a
    CROSS JOIN (SELECT 0 AS a UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) AS b
    CROSS JOIN (SELECT 0 AS a UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) AS c
    CROSS JOIN (SELECT 0 AS a UNION SELECT 1 UNION SELECT 2) AS d
) AS dt
WHERE dt.full_date BETWEEN '2024-01-01' AND '2026-12-31'
```
2. **Select Values:** Explicitly set data types (Integer for year, quarter, month, day)
3. **Insert/Update:** Insert into `greencity_dm.dim_date` (use date_key as lookup key)

**Important:** Explicitly cast SQL fields to avoid "Data truncated" errors.

#### 6.3.7 Load Additional Dimensions (Economic Data Mart)

**dim_invoice_status:**
- Load via SQL INSERT or PDI Data Grid:
  - ('sent', 'Sent')
  - ('paid', 'Paid')
  - ('overdue', 'Overdue')
  - ('cancelled', 'Cancelled')

**dim_payment_method:**
- Load via SQL INSERT or PDI Data Grid:
  - ('transfer', 'Bank Transfer')
  - ('card', 'Credit Card')
  - ('cash', 'Cash')
  - ('check', 'Check')

### 6.4 Phase 3: Load Fact Tables

#### 6.4.1 Load fact_energy_consumption

**Challenge:** PDI TextFileInput had issues parsing fixed-width CSV files.

**Solution:** Hybrid approach using Python + PDI.

**Step 1: Load CSVs to Temp Table (Python)**

**Script:** `scripts/load_consumption_to_temp.py`

**What it does:**
1. Reads staging CSV files (fixed-width format)
2. Parses each line to extract:
   - `compteur_id` (positions 0-6)
   - `date_mesure` (positions 7-26)
   - `consommation` (position 27+)
3. Inserts into `temp_consumption` table

**Temp Table Schema:**
```sql
CREATE TABLE temp_consumption (
    compteur_id VARCHAR(15),
    date_mesure DATETIME,
    consommation DECIMAL(14,3),
    energy_type VARCHAR(20)
);
```

**To Run:**
```bash
python scripts/load_consumption_to_temp.py
```

**Step 2: Load from Temp to Fact Table**

**Option A: Using SQL (Recommended)**
```bash
mysql -u root greencity_dm < sql/load_fact_from_temp.sql
```

**SQL Script:** `sql/load_fact_from_temp.sql`

**What it does:**
1. Joins `temp_consumption` with dimension tables
2. Resolves all foreign keys (date_key, meter_key, building_key, etc.)
3. Calculates `consumption_kwh` (only for electricity)
4. Inserts into `fact_energy_consumption`

**SQL Query:**
```sql
INSERT INTO fact_energy_consumption 
    (date_key, meter_key, building_key, client_key, region_key, energy_type_key, consumption_value, consumption_kwh)
SELECT 
    dd.date_key,
    dm.meter_key,
    db.building_key,
    db.client_key,
    db.region_key,
    dm.energy_type_key,
    tc.consommation AS consumption_value,
    CASE 
        WHEN det.energy_type_code = 'electricite' THEN tc.consommation 
        ELSE NULL 
    END AS consumption_kwh
FROM temp_consumption tc
INNER JOIN dim_meter dm ON tc.compteur_id = dm.meter_id
INNER JOIN dim_energy_type det ON dm.energy_type_key = det.energy_type_key 
    AND det.energy_type_code = tc.energy_type
INNER JOIN dim_building db ON dm.building_key = db.building_key
INNER JOIN dim_date dd ON DATE(tc.date_mesure) = dd.full_date;
```

**Option B: Using PDI (For Demonstration)**
- **Transformation:** `pdi_transforms/load_fact_energy_consumption_simple.ktr`
- Executes the same SQL script via "Execute SQL Script" step

#### 6.4.2 Load fact_economic_profitability

**Transformation:** `pdi_transforms/load_fact_economic.ktr`

**SQL Script:** `sql/load_fact_economic.sql`

**Approach:** Complex SQL with aggregations and calculations.

**Step 1: Create Temp Table for Payment Aggregations**
```sql
CREATE TEMPORARY TABLE temp_invoice_payments AS
SELECT 
    invoice_id,
    SUM(amount_paid) AS total_amount_paid,
    MAX(payment_date) AS last_payment_date,
    CAST(MAX(COALESCE(NULLIF(method, ''), 'transfer')) AS CHAR(20)) AS last_payment_method
FROM greencity_operational.payments
GROUP BY invoice_id;
```

**Why?** Aggregates payments at invoice level before joining to invoice lines.

**Step 2: Insert into Fact Table**
```sql
INSERT INTO fact_economic_profitability (
    invoice_date_key, period_start_key, period_end_key, payment_date_key,
    client_key, building_key, region_key, energy_type_key, status_key, payment_method_key,
    revenue_ttc, revenue_ht, consumption_qty, unit_price,
    invoice_total_ttc, invoice_energy_cost, line_margin, margin_percentage,
    invoice_amount_paid, line_amount_paid, payment_rate
)
SELECT 
    -- Date keys (lookup from dim_date)
    dd_invoice.date_key AS invoice_date_key,
    dd_start.date_key AS period_start_key,
    dd_end.date_key AS period_end_key,
    dd_payment.date_key AS payment_date_key,
    -- Dimension keys
    dc.client_key,
    db.building_key,
    db.region_key,
    det.energy_type_key,
    dis.status_key,
    dpm.method_key AS payment_method_key,
    -- Measures from invoice_line
    il.line_ttc AS revenue_ttc,
    il.line_ht AS revenue_ht,
    il.consumption_qty,
    il.unit_price,
    -- Invoice-level measures
    inv.total_ttc AS invoice_total_ttc,
    inv.energy_cost AS invoice_energy_cost,
    -- Calculated measures
    (il.line_ttc - (il.line_ttc / NULLIF(inv.total_ttc, 0) * inv.energy_cost)) AS line_margin,
    CASE 
        WHEN il.line_ttc > 0 THEN 
            ((il.line_ttc - (il.line_ttc / NULLIF(inv.total_ttc, 0) * inv.energy_cost)) / il.line_ttc) * 100
        ELSE 0 
    END AS margin_percentage,
    -- Payment measures
    COALESCE(tip.total_amount_paid, 0) AS invoice_amount_paid,
    (il.line_ttc / inv.total_ttc) * COALESCE(tip.total_amount_paid, 0) AS line_amount_paid,
    CASE 
        WHEN inv.total_ttc > 0 THEN 
            (COALESCE(tip.total_amount_paid, 0) / inv.total_ttc) * 100
        ELSE 0 
    END AS payment_rate
FROM greencity_operational.invoice_lines il
INNER JOIN greencity_operational.invoices inv ON il.invoice_id = inv.invoice_id
LEFT JOIN temp_invoice_payments tip ON inv.invoice_id = tip.invoice_id
-- Dimension lookups
INNER JOIN greencity_dm.dim_date dd_invoice ON DATE(inv.invoice_date) = dd_invoice.full_date
LEFT JOIN greencity_dm.dim_date dd_start ON DATE(il.period_start) = dd_start.full_date
LEFT JOIN greencity_dm.dim_date dd_end ON DATE(il.period_end) = dd_end.full_date
LEFT JOIN greencity_dm.dim_date dd_payment ON DATE(tip.last_payment_date) = dd_payment.full_date
INNER JOIN greencity_dm.dim_client dc ON inv.client_id = dc.client_id
INNER JOIN greencity_dm.dim_building db ON inv.building_id = db.building_id
INNER JOIN greencity_dm.dim_energy_type det ON il.energy_type = det.energy_type_code
INNER JOIN greencity_dm.dim_invoice_status dis ON COALESCE(NULLIF(inv.status, ''), 'sent') = dis.status_code
LEFT JOIN greencity_dm.dim_payment_method dpm ON tip.last_payment_method = dpm.method_code;
```

**Key Calculations:**
- **Line Margin:** Revenue minus proportional energy cost
- **Margin Percentage:** (Line Margin / Revenue) × 100
- **Line Amount Paid:** Proportional payment for this line item
- **Payment Rate:** (Total Paid / Invoice Total) × 100

**To Run:**
1. Open `pdi_transforms/load_fact_economic.ktr` in Spoon
2. Run the transformation
3. Or execute SQL directly: `mysql -u root greencity_dm < sql/load_fact_economic.sql`

#### 6.4.3 Load fact_environmental_impact

**Script:** `scripts/load_environmental_to_fact.py`

**What it does:**
1. Reads `data_sources/csv/env_reports_01_2025.csv`
2. Parses CSV using Python's `csv` module
3. For each row:
   - Looks up `date_key` from `dim_date`
   - Looks up `building_key` from `dim_building`
   - Extracts `region_key` from building
   - Inserts into `fact_environmental_impact`

**SQL Insert (within Python script):**
```sql
INSERT INTO fact_environmental_impact (
    report_date_key, building_key, region_key,
    emission_co2_kg, taux_recyclage, taux_recyclage_pct
)
SELECT 
    dd.date_key,
    db.building_key,
    db.region_key,
    %s,  -- emission_co2_kg
    %s,  -- taux_recyclage
    %s * 100  -- taux_recyclage_pct
FROM greencity_dm.dim_date dd
INNER JOIN greencity_dm.dim_building db ON %s = db.building_id
WHERE DATE(%s) = dd.full_date
```

**To Run:**
```bash
python scripts/load_environmental_to_fact.py
```

### 6.5 ETL Job Orchestration

**PDI Job:** `pdi_jobs/etl_full_pipeline.kjb`

**Structure:**
```
START
  ├─ load_fact_energy_consumption_simple.ktr
  ├─ load_fact_economic.ktr
  └─ load_fact_environmental.ktr
```

**Note:** This job assumes:
- Consumption data already loaded to `temp_consumption` (via Python)
- Environmental data already loaded to `fact_environmental_impact` (via Python)

**To Run in Spoon:**
1. Open `pdi_jobs/etl_full_pipeline.kjb`
2. Click "Run" button
3. Monitor execution log

**To Run via Command Line:**
```bash
cd C:\Pentaho\data-integration
pan.bat /file:"path\to\etl_full_pipeline.kjb" /level:Basic
```

---

## 7. Automation and Scheduling

### 7.1 Batch Script for ETL Pipeline

**Script:** `scheduler/run_etl.bat`

**What it does:**
1. Sets project root directory
2. Runs Python script to load consumption data
3. Runs Python script to load environmental data
4. Runs PDI job for fact table loads
5. Handles errors and provides feedback

**Contents:**
```batch
@echo off
REM Set working directory to project root
cd /d "%~dp0.."
set PROJECT_ROOT=%CD%

echo ========================================
echo GreenCity ETL Pipeline - Starting
echo ========================================
echo.

REM Step 1: Load consumption data to temp table
echo [1/3] Loading consumption CSVs to temp_consumption...
python "%PROJECT_ROOT%\scripts\load_consumption_to_temp.py"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to load consumption data
    pause
    exit /b 1
)

REM Step 2: Load environmental data
echo [2/3] Loading environmental data...
python "%PROJECT_ROOT%\scripts\load_environmental_to_fact.py"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to load environmental data
    pause
    exit /b 1
)

REM Step 3: Run PDI job for fact table loads
echo [3/3] Running PDI job for fact table loads...
set PDI_PATH=C:\Users\earth\Desktop\s9\Pentaho\data-integration
call "%PDI_PATH%\pan.bat" /file:"%PROJECT_ROOT%\pdi_jobs\etl_full_pipeline.kjb" /level:Basic
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: PDI job failed
    pause
    exit /b 1
)

echo ========================================
echo ETL Pipeline - Completed Successfully!
echo ========================================
pause
```

**Configuration:**
- Update `PDI_PATH` to match your PDI installation directory
- Update database credentials in Python scripts if needed

### 7.2 Windows Task Scheduler Setup

**Goal:** Run ETL pipeline daily at 02:00 AM.

**Steps:**

1. **Open Task Scheduler:**
   - Press `Win + R`
   - Type `taskschd.msc`
   - Press Enter

2. **Create Basic Task:**
   - Click "Create Basic Task..." (right panel)
   - **Name:** "GreenCity ETL Pipeline"
   - **Description:** "Daily ETL for GreenCity Data Warehouse"
   - Click "Next"

3. **Trigger:**
   - Select "Daily"
   - **Start date:** Today's date
   - **Start time:** 02:00 AM
   - Click "Next"

4. **Action:**
   - Select "Start a program"
   - **Program/script:** Browse to `scheduler\run_etl.bat`
   - **Start in:** `C:\path\to\project\scheduler`
   - Click "Next"

5. **Finish:**
   - Check "Open the Properties dialog..."
   - Click "Finish"

6. **Configure Properties:**
   - **General tab:**
     - Check "Run whether user is logged on or not"
     - Check "Run with highest privileges"
   - **Conditions tab:**
     - Uncheck "Start the task only if the computer is on AC power" (if you want it to run on battery)
   - **Settings tab:**
     - Check "Allow task to be run on demand"
     - Set "If the task fails, restart every:" 1 hour (optional)
   - Click "OK"

7. **Test the Task:**
   - Right-click the task → "Run"
   - Check execution in "Task Scheduler Library" → "History" tab

**Important Notes:**
- Task Scheduler requires user account with password (no blank password)
- MySQL and Python must be in system PATH, or use full paths in batch script
- PDI path must be correct in `run_etl.bat`

### 7.3 Manual Execution

**For Testing:**
```bash
cd scheduler
run_etl.bat
```

This will:
- Show progress in console
- Pause on completion (press any key to close)
- Show errors if any step fails

---

## 8. Power BI Reporting Setup

### 8.1 Prerequisites

1. **Install Power BI Desktop** (from Microsoft Store or direct download)
2. **Install MySQL ODBC Driver:**
   - Download: https://dev.mysql.com/downloads/connector/odbc/
   - Install Windows 64-bit version
   - Verify: Windows Settings → Apps → "MySQL ODBC 8.0 Driver"

### 8.2 Connect to Data Warehouse

1. **Open Power BI Desktop**

2. **Get Data:**
   - Click "Get Data" button (top left)
   - Search for "MySQL database"
   - Select "MySQL database" → Click "Connect"

3. **Connection Settings:**
   - **Server:** `localhost` (or `127.0.0.1`)
   - **Database:** `greencity_dm`
   - **Data connectivity mode:** "Import" (recommended for better performance)
   - Click "OK"

4. **Authentication:**
   - Select "Database"
   - Select "Use alternate credentials"
   - **Username:** `root`
   - **Password:** (leave empty or enter MySQL password)
   - Click "Connect"

5. **Navigator Window:**
   - Select all fact and dimension tables:
     - `fact_energy_consumption`
     - `fact_economic_profitability`
     - `fact_environmental_impact`
     - `dim_date`
     - `dim_region`
     - `dim_client`
     - `dim_building`
     - `dim_energy_type`
     - `dim_meter`
     - `dim_invoice_status`
     - `dim_payment_method`
   - Click "Load" (or "Transform Data" if you want to clean before loading)

### 8.3 Model Relationships

1. **Go to Model View:**
   - Click "Model" icon (left sidebar, second icon)

2. **Verify Relationships:**
   - Power BI should auto-detect relationships based on foreign keys
   - If not, create manually:
     - Drag `date_key` from `fact_energy_consumption` to `date_key` in `dim_date`
     - Drag `region_key` from `fact_energy_consumption` to `region_key` in `dim_region`
     - Repeat for all dimension keys

3. **Relationship Properties:**
   - **Cardinality:** Many-to-One (fact → dimension)
   - **Cross filter direction:** Single (dimension filters fact)
   - **Make this relationship active:** Checked

**Expected Model View:**
```
dim_date (center)
  ├─ fact_energy_consumption (date_key → date_key)
  ├─ fact_economic_profitability (invoice_date_key → date_key, etc.)
  └─ fact_environmental_impact (report_date_key → date_key)

dim_region (center)
  ├─ fact_energy_consumption (region_key → region_key)
  ├─ fact_economic_profitability (region_key → region_key)
  └─ fact_environmental_impact (region_key → region_key)

dim_building (center)
  ├─ fact_energy_consumption (building_key → building_key)
  ├─ fact_economic_profitability (building_key → building_key)
  └─ fact_environmental_impact (building_key → building_key)

... (similar for other dimensions)
```

### 8.4 Create Calculated Measures (DAX)

**Where:** In each fact table, create measures using DAX formulas.

**Measures for Energy Consumption:**

1. **Total Consumption (kWh):**
   ```dax
   Total Consumption (kWh) = SUM([consumption_kwh])
   ```

2. **Total Consumption (All Units):**
   ```dax
   Total Consumption = SUM([consumption_value])
   ```

**Measures for Economic Profitability:**

1. **Total Revenue:**
   ```dax
   Total Revenue = SUM([revenue_ttc])
   ```

2. **Total Margin:**
   ```dax
   Total Margin = SUM([line_margin])
   ```

3. **Average Margin %:**
   ```dax
   Average Margin % = AVERAGE([margin_percentage])
   ```

4. **Payment Rate:**
   ```dax
   Payment Rate = AVERAGE([payment_rate])
   ```

**Measures for Environmental Impact:**

1. **Total CO2 Emissions:**
   ```dax
   Total CO2 Emissions = SUM([emission_co2_kg])
   ```

2. **Average Recycling Rate:**
   ```dax
   Average Recycling Rate = AVERAGE([taux_recyclage_pct])
   ```

**How to Create:**
1. Go to "Data" view (left sidebar, first icon)
2. Select a fact table (e.g., `fact_energy_consumption`)
3. Click "New Measure" (Home tab)
4. Enter formula in formula bar
5. Press Enter

**Note:** If the measure is created within the correct table, you can use `[column_name]` instead of `table_name[column_name]`.

### 8.5 Create Visualizations

**Detailed instructions are in:** `docs/POWER_BI_SETUP.md` (Step 6)

**Quick Overview:**

**Dashboard 1: Energy Consumption**
- KPI Card: Total Consumption (kWh)
- Line Chart: Consumption over Time
- Bar Chart: Consumption by Region
- Bar Chart: Consumption by Building
- Pie Chart: Consumption by Energy Type
- Table: Top 10 Buildings by Consumption

**Dashboard 2: Economic Profitability**
- KPI Cards: Total Revenue, Total Margin, Payment Rate
- Line Chart: Revenue over Time
- Bar Chart: Revenue by Region
- Bar Chart: Revenue by Building
- Table: Top 10 Most Profitable Clients
- Bar Chart: Margin by Payment Method

**Dashboard 3: Environmental Impact**
- KPI Cards: Total CO2, Average Recycling Rate
- Line Chart: CO2 Emissions over Time
- Bar Chart: CO2 Emissions by Region
- Bar Chart: Top 10 Most Polluting Buildings
- Donut Chart: Recycling Rate Distribution
- Scatter Chart: CO2 vs Consumption (optional)

**Dashboard 4: Combined Overview**
- KPI Cards Row: Total Consumption, Total Revenue, Total CO2
- Line Chart: All Metrics over Time (multi-series)
- Matrix: Region Comparison
- Slicers: Date Range, Region, Building, Client

### 8.6 Save and Share

1. **Save .pbix File:**
   - File → Save As
   - Save as `GreenCity_BI_Dashboard.pbix`

2. **Publish to Power BI Service (Optional):**
   - File → Publish → Publish to Power BI
   - Sign in to Power BI account
   - Select workspace → Click "Select"

---

## 9. Project Structure

```
Business Intelligence - Mini Projet/
│
├── data_sources/              # Source data files
│   ├── csv/
│   │   ├── operational_seed/  # Seed data for operational DB
│   │   │   ├── buildings.csv
│   │   │   ├── clients.csv
│   │   │   ├── invoice_lines.csv
│   │   │   ├── invoices.csv
│   │   │   ├── meters.csv
│   │   │   ├── payments.csv
│   │   │   └── regions.csv
│   │   └── env_reports_01_2025.csv
│   └── json/                  # IoT consumption data
│       ├── Electricite_consumption_01_2025.json
│       ├── Eau_consumption_01_2025.json
│       └── Gaz_consumption_01_2025.json
│
├── staging/                   # Staging area (extracted CSVs)
│   ├── consumption_electricite.csv
│   ├── consumption_eau.csv
│   └── consumption_gaz.csv
│
├── transformed/               # Transformed data (currently unused)
│
├── sql/                       # SQL scripts
│   ├── operational_schema.sql         # Operational DB DDL
│   ├── load_seed.sql                  # Load seed data
│   ├── datamart_consumption.sql       # Consumption Data Mart DDL
│   ├── datamart_economic.sql          # Economic Data Mart DDL
│   ├── datamart_environmental.sql     # Environmental Data Mart DDL
│   ├── create_temp_consumption.sql    # Temp table for consumption
│   ├── load_fact_from_temp.sql        # Load consumption fact
│   ├── load_fact_economic.sql         # Load economic fact
│   └── load_fact_environmental.sql    # Load environmental fact
│
├── pdi_transforms/            # PDI transformations (.ktr)
│   ├── ingest_consumption_electricite.ktr
│   ├── ingest_consumption_eau.ktr
│   ├── ingest_consumption_gaz.ktr
│   ├── load_dim_region.ktr
│   ├── load_dim_client.ktr
│   ├── load_dim_energy_type.ktr
│   ├── load_dim_building.ktr
│   ├── load_dim_meter.ktr
│   ├── load_dim_date.ktr
│   ├── load_fact_energy_consumption_simple.ktr
│   ├── load_fact_economic.ktr
│   └── load_fact_environmental.ktr
│
├── pdi_jobs/                  # PDI jobs (.kjb)
│   ├── etl_full_pipeline.kjb
│   └── ETL_JOB_README.txt
│
├── scripts/                   # Python scripts
│   ├── generate_mock_data.py          # Generate test data (optional)
│   ├── flatten_consumption_json.py    # JSON flattening utility
│   ├── load_consumption_to_temp.py    # Load consumption CSVs to temp
│   └── load_environmental_to_fact.py  # Load environmental CSV to fact
│
├── scheduler/                 # Automation scripts
│   ├── run_etl.bat                    # Main ETL batch script
│   └── README.md
│
├── reports/                   # Reporting files
│   └── POWER_BI_QUICK_START.md
│
├── docs/                      # Documentation
│   ├── PROJECT_COMPLETE_GUIDE.md      # This file
│   ├── POWER_BI_SETUP.md              # Detailed Power BI guide
│   ├── POWER_BI_MODEL_VERIFICATION.md # Model checklist
│   ├── TASK_SCHEDULER_SETUP.md        # Scheduler setup guide
│   ├── FACT_TABLE_LOAD_INSTRUCTIONS.md
│   └── progress_log.md
│
├── logs/                      # ETL execution logs (generated)
│
└── project_requirements_md.md # Original project requirements
```

---

## 10. Step-by-Step Implementation

### 10.1 Initial Setup

**Step 1: Install Software**
- Install MySQL Server
- Install Pentaho Data Integration
- Install Python 3.x
- Install Power BI Desktop
- Install MySQL ODBC Driver

**Step 2: Create Project Directory**
- Create project folder structure (see Section 9)
- Download/clone project files

**Step 3: Configure MySQL**
- Start MySQL service
- Create databases:
  ```sql
  CREATE DATABASE greencity_operational;
  CREATE DATABASE greencity_dm;
  ```

### 10.2 Load Operational Database

**Step 1: Create Operational Schema**
```bash
mysql -u root greencity_operational < sql/operational_schema.sql
```

**Step 2: Load Seed Data**
```bash
mysql -u root greencity_operational < sql/load_seed.sql
```

**Verify:**
```sql
USE greencity_operational;
SELECT COUNT(*) FROM regions;
SELECT COUNT(*) FROM clients;
SELECT COUNT(*) FROM buildings;
```

### 10.3 Create Data Warehouse Schema

**Step 1: Create Consumption Data Mart**
```bash
mysql -u root greencity_dm < sql/datamart_consumption.sql
```

**Step 2: Create Economic Data Mart**
```bash
mysql -u root greencity_dm < sql/datamart_economic.sql
```

**Step 3: Create Environmental Data Mart**
```bash
mysql -u root greencity_dm < sql/datamart_environmental.sql
```

**Step 4: Create Temp Table**
```bash
mysql -u root greencity_dm < sql/create_temp_consumption.sql
```

### 10.4 Load Dimensions

**Using PDI Spoon:**

1. Open each dimension transformation (e.g., `load_dim_region.ktr`)
2. Configure database connections:
   - **Operational DB:** `greencity_operational`
   - **Data Mart DB:** `greencity_dm`
3. Run transformations in order:
   - `load_dim_region.ktr`
   - `load_dim_client.ktr`
   - `load_dim_energy_type.ktr`
   - `load_dim_building.ktr`
   - `load_dim_meter.ktr`
   - `load_dim_date.ktr`
   - Load `dim_invoice_status` and `dim_payment_method` (via SQL or PDI)

**Verify:**
```sql
USE greencity_dm;
SELECT COUNT(*) FROM dim_region;
SELECT COUNT(*) FROM dim_client;
SELECT COUNT(*) FROM dim_date;  -- Should be 1095 (3 years)
```

### 10.5 Extract JSON to Staging

**Using PDI Spoon:**

1. Open `ingest_consumption_electricite.ktr`
2. Update file path to your JSON file location
3. Run transformation
4. Verify output: `staging/consumption_electricite.csv`
5. Repeat for `ingest_consumption_eau.ktr` and `ingest_consumption_gaz.ktr`

### 10.6 Load Fact Tables

**Step 1: Load Consumption Fact**
```bash
python scripts/load_consumption_to_temp.py
mysql -u root greencity_dm < sql/load_fact_from_temp.sql
```

**Step 2: Load Economic Fact**
- Open `pdi_transforms/load_fact_economic.ktr` in Spoon
- Run transformation
- Or: `mysql -u root greencity_dm < sql/load_fact_economic.sql`

**Step 3: Load Environmental Fact**
```bash
python scripts/load_environmental_to_fact.py
```

**Verify:**
```sql
USE greencity_dm;
SELECT COUNT(*) FROM fact_energy_consumption;
SELECT COUNT(*) FROM fact_economic_profitability;
SELECT COUNT(*) FROM fact_environmental_impact;
```

### 10.7 Test ETL Pipeline

**Using Batch Script:**
```bash
cd scheduler
run_etl.bat
```

**Or Using PDI Job:**
- Open `pdi_jobs/etl_full_pipeline.kjb` in Spoon
- Run job
- Check execution log

### 10.8 Setup Automation

**Follow Section 7.2** to configure Windows Task Scheduler.

### 10.9 Create Power BI Dashboards

**Follow Section 8** for detailed Power BI setup instructions.

---

## 11. Troubleshooting

### 11.1 Common ETL Issues

#### Issue: "Data truncated for column 'year' at row 1" (dim_date)

**Cause:** SQL field type mismatch.

**Solution:**
- Explicitly cast SQL fields: `CAST(YEAR(...) AS SIGNED)`
- Use "Select Values" step in PDI to set Integer type

#### Issue: "Cannot parse null string" (CSV Input)

**Cause:** CSV file is fixed-width, not comma-separated.

**Solution:** Use Python script (`load_consumption_to_temp.py`) instead of PDI CSVInput.

#### Issue: "NullPointerException" (TextFileInput)

**Cause:** Missing XML elements in PDI transformation.

**Solution:** Add `<fileFormat>` and `<encoding>` elements, or use Python script instead.

#### Issue: "Unknown column 'tip.last_payment_date'"

**Cause:** Temporary table not created before use.

**Solution:** Ensure `temp_invoice_payments` is created before the main INSERT statement.

#### Issue: "Data truncated for column 'last_payment_method'"

**Cause:** NULL values in `method` column causing type inference issues.

**Solution:** Use `CAST(MAX(COALESCE(NULLIF(method, ''), 'transfer')) AS CHAR(20))` in temp table creation.

### 11.2 Database Connection Issues

#### Issue: Cannot connect to MySQL from PDI

**Solution:**
1. Verify MySQL service is running
2. Check connection settings:
   - Host: `localhost`
   - Port: `3306`
   - Database: `greencity_operational` or `greencity_dm`
   - Username: `root`
   - Password: (empty or your password)
3. Test connection in PDI "Database Connection" dialog

#### Issue: Cannot connect from Python script

**Solution:**
1. Verify MySQL connector installed: `pip install mysql-connector-python`
2. Check `DB_CONFIG` in Python script matches your MySQL settings
3. Test connection: `mysql -u root -h localhost`

### 11.3 Power BI Issues

#### Issue: Cannot connect to MySQL

**Solution:**
1. Verify MySQL ODBC Driver installed
2. In Power BI connection dialog:
   - Select "Database" authentication
   - Select "Use alternate credentials"
   - Enter username/password

#### Issue: "Cannot find table 'greencity_dm_fact_energy_consumption'" (DAX)

**Cause:** Using full table name in DAX when measure is in the table.

**Solution:** Use simple column reference: `SUM([consumption_kwh])` instead of `SUM(greencity_dm_fact_energy_consumption[consumption_kwh])`

#### Issue: Relationships not detected automatically

**Solution:**
1. Go to Model view
2. Manually create relationships by dragging keys
3. Verify cardinality: Many-to-One (fact → dimension)

### 11.4 Automation Issues

#### Issue: Task Scheduler task fails silently

**Solution:**
1. Check "History" tab in Task Scheduler
2. Verify batch script path is correct
3. Run batch script manually to see errors
4. Ensure user account has password (required for scheduled tasks)

#### Issue: Python not found in scheduled task

**Solution:**
1. Use full path to Python in batch script: `C:\Python\python.exe`
2. Or add Python to system PATH

#### Issue: PDI not found

**Solution:**
- Update `PDI_PATH` in `run_etl.bat` to correct installation directory

---

## 12. Appendix

### 12.1 SQL Quick Reference

**Create Database:**
```sql
CREATE DATABASE database_name;
USE database_name;
```

**Truncate Table:**
```sql
TRUNCATE TABLE table_name;
```

**Count Rows:**
```sql
SELECT COUNT(*) FROM table_name;
```

**Check Data:**
```sql
SELECT * FROM table_name LIMIT 10;
```

**Check Foreign Keys:**
```sql
SELECT 
    COUNT(*) AS fact_count,
    COUNT(DISTINCT date_key) AS date_count,
    COUNT(DISTINCT building_key) AS building_count
FROM fact_energy_consumption;
```

### 12.2 PDI Transformation Best Practices

1. **Always use "Insert/Update" step** for dimension loading (handles SCD Type 1)
2. **Use SQL JOINs** instead of Database Lookup when possible (better performance)
3. **Set data types explicitly** in "Select Values" step
4. **Use batch inserts** for large datasets (configure in Table Output step)
5. **Enable error handling** (Redirect invalid rows to error table)

### 12.3 Python Script Configuration

**Database Configuration (in scripts):**
```python
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '',  # Set your password here if needed
    'database': 'greencity_dm',
    'charset': 'utf8mb4'
}
```

**Update if your MySQL setup differs.**

### 12.4 Data Quality Considerations

**Handled in ETL:**
- NULL values: Using `COALESCE` and `NULLIF`
- Missing dimensions: Using `LEFT JOIN` for optional relationships
- Data type mismatches: Explicit casting in SQL
- Duplicate prevention: Using `INSERT/UPDATE` with unique keys

**For Production:**
- Add data validation steps
- Log data quality issues
- Implement error handling and notifications

### 12.5 Incremental Loading (Future Enhancement)

**Current Implementation:** Full load (truncate and reload)

**For Incremental Loading:**
1. Add `last_updated` timestamp to source tables
2. Store `last_load_date` in ETL metadata table
3. Filter source data: `WHERE last_updated > last_load_date`
4. Use `INSERT/UPDATE` for dimensions (handles updates)
5. Use `INSERT IGNORE` or `ON DUPLICATE KEY UPDATE` for fact tables

### 12.6 Performance Optimization

**Database:**
- Add indexes on foreign keys (already included in DDL)
- Partition large fact tables by date (if needed)
- Use `ANALYZE TABLE` to update statistics

**ETL:**
- Use batch inserts (1000-5000 rows per batch)
- Parallel processing for independent transformations
- Optimize SQL queries (avoid N+1 lookups)

**Power BI:**
- Use "Import" mode for better performance
- Limit data refresh to required date ranges
- Use aggregations for large datasets

---

## Conclusion

This guide provides a complete walkthrough of the GreenCity Business Intelligence project. Follow the steps sequentially, and refer to troubleshooting sections if issues arise.

**Key Takeaways:**
- The project uses a hybrid ETL approach (PDI + Python + SQL)
- Three independent data marts enable focused analysis
- Automation ensures daily data updates
- Power BI provides interactive visualization and exploration

**For Questions or Issues:**
- Review troubleshooting section (Section 11)
- Check individual component documentation in `docs/` folder
- Verify database and file paths match your setup

---

**End of Guide**

