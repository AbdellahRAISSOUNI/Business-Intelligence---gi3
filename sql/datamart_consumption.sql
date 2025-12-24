-- Data Mart: Consommation énergétique
-- Target database: greencity_dm (logical data mart schema)

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS greencity_dm;
USE greencity_dm;

-- Dimension tables

CREATE TABLE IF NOT EXISTS dim_date (
  date_key        INT PRIMARY KEY,           -- e.g. 20250114
  full_date       DATE NOT NULL,
  year            INT NOT NULL,
  quarter         TINYINT NOT NULL,
  month           TINYINT NOT NULL,
  month_name      VARCHAR(20) NOT NULL,
  day             TINYINT NOT NULL,
  day_of_week     TINYINT NOT NULL,
  day_name        VARCHAR(20) NOT NULL,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS dim_region (
  region_key      INT AUTO_INCREMENT PRIMARY KEY,
  region_id       VARCHAR(10) NOT NULL,
  region_name     VARCHAR(100),
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_dim_region_business (region_id)
);

CREATE TABLE IF NOT EXISTS dim_client (
  client_key      INT AUTO_INCREMENT PRIMARY KEY,
  client_id       VARCHAR(10) NOT NULL,
  client_name     VARCHAR(150),
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_dim_client_business (client_id)
);

CREATE TABLE IF NOT EXISTS dim_building (
  building_key    INT AUTO_INCREMENT PRIMARY KEY,
  building_id     VARCHAR(10) NOT NULL,
  building_name   VARCHAR(150),
  building_type   VARCHAR(50),
  surface_m2      DECIMAL(10,2),
  region_key      INT,
  client_key      INT,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_dim_building_business (building_id),
  CONSTRAINT fk_dim_building_region FOREIGN KEY (region_key) REFERENCES dim_region(region_key),
  CONSTRAINT fk_dim_building_client FOREIGN KEY (client_key) REFERENCES dim_client(client_key)
);

CREATE TABLE IF NOT EXISTS dim_energy_type (
  energy_type_key INT AUTO_INCREMENT PRIMARY KEY,
  energy_type_code VARCHAR(20) NOT NULL,        -- electricite, eau, gaz
  unit            VARCHAR(10) NOT NULL,        -- KWh, m3
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_dim_energy_type_business (energy_type_code, unit)
);

CREATE TABLE IF NOT EXISTS dim_meter (
  meter_key       INT AUTO_INCREMENT PRIMARY KEY,
  meter_id        VARCHAR(15) NOT NULL,
  building_key    INT,
  energy_type_key INT,
  installed_at    DATE,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_dim_meter_business (meter_id),
  CONSTRAINT fk_dim_meter_building FOREIGN KEY (building_key) REFERENCES dim_building(building_key),
  CONSTRAINT fk_dim_meter_energy_type FOREIGN KEY (energy_type_key) REFERENCES dim_energy_type(energy_type_key)
);

-- Fact table: granular consumption measurements coming from IoT JSON

CREATE TABLE IF NOT EXISTS fact_energy_consumption (
  fact_id             BIGINT AUTO_INCREMENT PRIMARY KEY,
  date_key            INT NOT NULL,
  meter_key           INT NOT NULL,
  building_key        INT,
  client_key          INT,
  region_key          INT,
  energy_type_key     INT NOT NULL,
  -- Measures
  consumption_value   DECIMAL(14,3) NOT NULL,    -- kWh or m3 depending on energy_type
  -- Optional derived measures
  consumption_kwh     DECIMAL(14,3) NULL,        -- normalized kWh for comparisons
  created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_fact_date FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
  CONSTRAINT fk_fact_meter FOREIGN KEY (meter_key) REFERENCES dim_meter(meter_key),
  CONSTRAINT fk_fact_building FOREIGN KEY (building_key) REFERENCES dim_building(building_key),
  CONSTRAINT fk_fact_client FOREIGN KEY (client_key) REFERENCES dim_client(client_key),
  CONSTRAINT fk_fact_region FOREIGN KEY (region_key) REFERENCES dim_region(region_key),
  CONSTRAINT fk_fact_energy_type FOREIGN KEY (energy_type_key) REFERENCES dim_energy_type(energy_type_key),
  KEY idx_fact_date (date_key),
  KEY idx_fact_meter (meter_key),
  KEY idx_fact_building (building_key),
  KEY idx_fact_client (client_key),
  KEY idx_fact_region (region_key),
  KEY idx_fact_energy_type (energy_type_key)
);






