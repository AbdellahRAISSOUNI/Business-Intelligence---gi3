-- Load fact_energy_consumption from temp_consumption table
-- This SQL assumes temp_consumption has been populated (via Python script or other method)

USE greencity_dm;

-- Insert into fact table with dimension lookups
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

-- Show results
SELECT 
    'fact_energy_consumption' AS table_name,
    COUNT(*) AS row_count,
    MIN(date_key) AS min_date_key,
    MAX(date_key) AS max_date_key
FROM fact_energy_consumption;

