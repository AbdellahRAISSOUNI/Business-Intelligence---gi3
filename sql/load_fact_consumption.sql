-- SQL script to load fact_energy_consumption from staging CSV files
-- This is called from PDI transformation

-- Load electricity consumption
LOAD DATA LOCAL INFILE 'C:/Users/earth/Desktop/s9/bi/Business Intelligence - Mini Projet/staging/consumption_electricite.csv'
INTO TABLE greencity_dm.temp_consumption
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(compteur_id, @date_mesure, consommation)
SET energy_type = 'electricite',
    date_mesure = STR_TO_DATE(@date_mesure, '%Y-%m-%dT%H:%i:%s');

-- Load water consumption  
LOAD DATA LOCAL INFILE 'C:/Users/earth/Desktop/s9/bi/Business Intelligence - Mini Projet/staging/consumption_eau.csv'
INTO TABLE greencity_dm.temp_consumption
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(compteur_id, @date_mesure, consommation)
SET energy_type = 'eau',
    date_mesure = STR_TO_DATE(@date_mesure, '%Y-%m-%dT%H:%i:%s');

-- Load gas consumption
LOAD DATA LOCAL INFILE 'C:/Users/earth/Desktop/s9/bi/Business Intelligence - Mini Projet/staging/consumption_gaz.csv'
INTO TABLE greencity_dm.temp_consumption
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(compteur_id, @date_mesure, consommation)
SET energy_type = 'gaz',
    date_mesure = STR_TO_DATE(@date_mesure, '%Y-%m-%dT%H:%i:%s');

-- Insert into fact table with dimension lookups
INSERT INTO greencity_dm.fact_energy_consumption 
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
    WHEN det.energy_type_code = 'eau' THEN NULL  -- Could add conversion factor here
    WHEN det.energy_type_code = 'gaz' THEN NULL  -- Could add conversion factor here
    ELSE NULL
  END AS consumption_kwh
FROM greencity_dm.temp_consumption tc
INNER JOIN greencity_dm.dim_meter dm ON tc.compteur_id = dm.meter_id
INNER JOIN greencity_dm.dim_energy_type det ON dm.energy_type_key = det.energy_type_key 
  AND det.energy_type_code = tc.energy_type
INNER JOIN greencity_dm.dim_building db ON dm.building_key = db.building_key
INNER JOIN greencity_dm.dim_date dd ON DATE(tc.date_mesure) = dd.full_date
ON DUPLICATE KEY UPDATE 
  consumption_value = VALUES(consumption_value),
  consumption_kwh = VALUES(consumption_kwh),
  updated_at = CURRENT_TIMESTAMP;

-- Clean up temp table
TRUNCATE TABLE greencity_dm.temp_consumption;

