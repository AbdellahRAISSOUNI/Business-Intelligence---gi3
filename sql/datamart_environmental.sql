-- Data Mart: Impact environnemental
-- Target database: greencity_dm
-- This Data Mart reuses shared dimensions from Consumption Data Mart

USE greencity_dm;

-- Fact table: Environmental Impact
-- Granularity: One row per building per report date (monthly reports)
-- Measures: CO2 emissions, recycling rate, and calculated ratios

CREATE TABLE IF NOT EXISTS fact_environmental_impact (
  fact_id              BIGINT AUTO_INCREMENT PRIMARY KEY,
  -- Dimension keys (reuse shared dimensions)
  report_date_key      INT NOT NULL,            -- Date of the environmental report
  building_key         INT NOT NULL,
  region_key           INT,
  -- Measures
  emission_co2_kg      DECIMAL(14,2) NOT NULL,  -- CO2 emissions in kg
  taux_recyclage       DECIMAL(5,2) NOT NULL,   -- Recycling rate (0.00 to 1.00)
  taux_recyclage_pct   DECIMAL(5,2),            -- Recycling rate as percentage (0 to 100)
  -- Timestamps
  created_at           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  -- Foreign keys
  CONSTRAINT fk_fact_env_report_date FOREIGN KEY (report_date_key) REFERENCES dim_date(date_key),
  CONSTRAINT fk_fact_env_building FOREIGN KEY (building_key) REFERENCES dim_building(building_key),
  CONSTRAINT fk_fact_env_region FOREIGN KEY (region_key) REFERENCES dim_region(region_key),
  -- Indexes for performance
  KEY idx_fact_env_report_date (report_date_key),
  KEY idx_fact_env_building (building_key),
  KEY idx_fact_env_region (region_key)
);

-- Note: The CO2/consumption ratio can be calculated in queries by joining with fact_energy_consumption
-- Example: SELECT fei.*, fec.consumption_value, (fei.emission_co2_kg / NULLIF(fec.consumption_value, 0)) AS co2_per_consumption_ratio
--          FROM fact_environmental_impact fei
--          JOIN fact_energy_consumption fec ON fei.building_key = fec.building_key AND fei.report_date_key = fec.date_key


