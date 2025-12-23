# Project Progress Log

Format: date – milestone – notes – checkpoint reference.

- 2025-12-23 – Milestone 0 – Created project skeleton (data_sources/, staging/, transformed/, pdi_jobs/, pdi_transforms/, sql/, reports/, docs/, logs/) and initialized progress log – Checkpoint: init.
- 2025-12-23 – Milestone 1 (partial) – Added operational schema DDL (`sql/operational_schema.sql`) and Python data generator (`scripts/generate_mock_data.py`) to produce JSON/CSV seeds; generated initial datasets into `data_sources/` – Checkpoint: schema+seed v1.
- 2025-12-23 – Milestone 1 – Imported schema into MySQL (`greencity_operational`) and loaded seed CSVs via `sql/load_seed.sql` after enabling `local_infile` – Checkpoint: operational DB loaded.
