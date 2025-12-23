# Project Progress Log

Format: date – milestone – notes – checkpoint reference.

- 2025-12-23 – Milestone 0 – Created project skeleton (data_sources/, staging/, transformed/, pdi_jobs/, pdi_transforms/, sql/, reports/, docs/, logs/) and initialized progress log – Checkpoint: init.
- 2025-12-23 – Milestone 1 (partial) – Added operational schema DDL (`sql/operational_schema.sql`) and Python data generator (`scripts/generate_mock_data.py`) to produce JSON/CSV seeds; generated initial datasets into `data_sources/` – Checkpoint: schema+seed v1.
- 2025-12-23 – Milestone 1 – Imported schema into MySQL (`greencity_operational`) and loaded seed CSVs via `sql/load_seed.sql` after enabling `local_infile` – Checkpoint: operational DB loaded.
- 2025-12-23 – Milestone 2 – Implemented PDI JSON ingestion for electricity (`ingest_consumption_electricite.ktr`) producing `staging/consumption_electricite.csv`; added similar transforms for water and gas (`ingest_consumption_eau.ktr`, `ingest_consumption_gaz.ktr`) producing `staging/consumption_eau.csv` and `staging/consumption_gaz.csv` – Checkpoint: JSON→staging via PDI.
- 2025-12-23 – Milestone 3 (partial) – Created consumption Data Mart schema in `greencity_dm` (`sql/datamart_consumption.sql`) and loaded `dim_region` using PDI transformation `load_dim_region.ktr` – Checkpoint: first dimension loaded.
- 2025-12-23 – Milestone 3 (continued) – Added PDI transforms `load_dim_client.ktr` and `load_dim_energy_type.ktr` to populate `dim_client` and `dim_energy_type` from the operational schema – Checkpoint: core conso dimensions from operational DB.
- 2025-12-23 – Milestone 3 (continued) – Added PDI transforms `load_dim_building.ktr` (using SQL JOINs to dim_region and dim_client) and `load_dim_meter.ktr` (using SQL JOINs to dim_building and dim_energy_type); fixed plugin dependency issues by replacing DatabaseLookup steps with SQL JOINs – Checkpoint: all dimension load transforms ready (except dim_date).
