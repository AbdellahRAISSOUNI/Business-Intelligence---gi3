# GreenCity Business Intelligence Project

A complete Business Intelligence solution for managing and analyzing smart building data, including energy consumption, economic profitability, and environmental impact.

## 📋 Overview

This project implements a comprehensive BI system with:
- **Three Independent Data Marts** (Star Schema Design)
  - Energy Consumption Data Mart
  - Economic Profitability Data Mart
  - Environmental Impact Data Mart
- **ETL Pipeline** using Pentaho Data Integration (PDI) + Python
- **Automated Daily Execution** via Windows Task Scheduler
- **Interactive Dashboards** in Power BI

## 🚀 Quick Start

1. **Read the complete implementation guide:** See [Project Complete Guide](docs/PROJECT_COMPLETE_GUIDE.md)
2. **Review project requirements:** See [Project Requirements](docs/project_requirements_md.md)

## 📚 Documentation

### Essential Documentation

- **[Project Complete Guide](docs/PROJECT_COMPLETE_GUIDE.md)** - Comprehensive A-to-Z implementation guide
  - System architecture and design
  - Step-by-step setup instructions
  - ETL process walkthrough
  - Power BI dashboard setup
  - Troubleshooting guide

- **[Project Requirements](docs/project_requirements_md.md)** - Original project specifications
  - Business objectives
  - Data sources and formats
  - Technical requirements
  - KPI definitions

### Additional Documentation

- [Power BI Setup Guide](docs/POWER_BI_SETUP.md) - Detailed Power BI configuration
- [Task Scheduler Setup](docs/TASK_SCHEDULER_SETUP.md) - ETL automation setup
- [Power BI Quick Start](reports/POWER_BI_QUICK_START.md) - Quick reference for Power BI
- [Power BI Model Verification](docs/POWER_BI_MODEL_VERIFICATION.md) - Model checklist
- [Fact Table Load Instructions](docs/FACT_TABLE_LOAD_INSTRUCTIONS.md) - Fact table loading guide
- [Scheduler README](scheduler/README.md) - ETL batch script documentation

## 🛠️ Technologies

- **Database:** MySQL 8.0+
- **ETL Tool:** Pentaho Data Integration (PDI) 10.2+
- **BI Tool:** Power BI Desktop
- **Automation:** Windows Task Scheduler + Batch Scripts
- **Scripting:** Python 3.x
- **ODBC Driver:** MySQL Connector/ODBC 8.0

## 📁 Project Structure

```
Business Intelligence - Mini Projet/
├── data_sources/          # Source data files (JSON, CSV)
├── staging/               # Staging area (extracted CSVs)
├── sql/                   # SQL scripts (DDL, DML)
├── pdi_transforms/        # PDI transformations (.ktr)
├── pdi_jobs/              # PDI jobs (.kjb)
├── scripts/               # Python scripts
├── scheduler/             # Automation scripts
├── reports/               # Reporting documentation
└── docs/                  # Project documentation
```

## 🎯 Key Features

- **Star Schema Design:** Optimized dimensional modeling for analytics
- **Hybrid ETL Approach:** Combines PDI, Python, and SQL for optimal performance
- **Incremental Loading:** Supports incremental data loading (future enhancement)
- **Interactive Dashboards:** Multiple Power BI dashboards with slicers and filters
- **Automated Execution:** Daily ETL pipeline via Windows Task Scheduler

## 📖 Getting Started

For detailed setup instructions, see the **[Project Complete Guide](docs/PROJECT_COMPLETE_GUIDE.md)**.

### Quick Setup Steps

1. Install prerequisites (MySQL, PDI, Python, Power BI)
2. Create databases: `greencity_operational` and `greencity_dm`
3. Load operational schema and seed data
4. Create data warehouse schema (3 data marts)
5. Run ETL pipeline to load dimensions and facts
6. Connect Power BI and create dashboards
7. Schedule ETL automation (optional)

## 📝 License

This is an academic project for educational purposes.

## 👥 Contributors

Business Intelligence Project Team

---

**For complete documentation, see [Project Complete Guide](docs/PROJECT_COMPLETE_GUIDE.md)**

