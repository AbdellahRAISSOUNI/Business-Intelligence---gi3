-- Load fact_environmental_impact from operational database env_reports table
-- Note: If env_reports table is empty, this will load from CSV staging area instead

USE greencity_dm;

-- Option 1: Load from operational database (if data exists there)
INSERT INTO fact_environmental_impact (
    report_date_key,
    building_key,
    region_key,
    emission_co2_kg,
    taux_recyclage,
    taux_recyclage_pct
)
SELECT 
    dd.date_key AS report_date_key,
    db.building_key,
    db.region_key,
    er.emission_co2_kg,
    er.taux_recyclage,
    er.taux_recyclage * 100 AS taux_recyclage_pct  -- Convert to percentage
FROM greencity_operational.env_reports er
INNER JOIN greencity_dm.dim_date dd ON DATE(er.report_date) = dd.full_date
INNER JOIN greencity_dm.dim_building db ON er.building_id = db.building_id
ON DUPLICATE KEY UPDATE
    emission_co2_kg = VALUES(emission_co2_kg),
    taux_recyclage = VALUES(taux_recyclage),
    taux_recyclage_pct = VALUES(taux_recyclage_pct),
    updated_at = CURRENT_TIMESTAMP;

-- Show results
SELECT 
    'fact_environmental_impact' AS table_name,
    COUNT(*) AS row_count,
    SUM(emission_co2_kg) AS total_co2_emissions_kg,
    AVG(taux_recyclage_pct) AS avg_recycling_rate_pct,
    MIN(report_date_key) AS min_date_key,
    MAX(report_date_key) AS max_date_key
FROM fact_environmental_impact;

