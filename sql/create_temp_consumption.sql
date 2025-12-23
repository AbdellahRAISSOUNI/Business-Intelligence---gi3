-- Create temp table for staging consumption data before loading into fact table

USE greencity_dm;

CREATE TABLE IF NOT EXISTS temp_consumption (
  compteur_id VARCHAR(15),
  date_mesure DATETIME,
  consommation DECIMAL(14,3),
  energy_type VARCHAR(20),
  INDEX idx_compteur (compteur_id),
  INDEX idx_date (date_mesure),
  INDEX idx_energy_type (energy_type)
) ENGINE=MEMORY;

