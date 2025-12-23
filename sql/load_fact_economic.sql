-- Load fact_economic_profitability from operational database
-- This script aggregates invoice_lines with invoices and payments

USE greencity_dm;

-- First, create a temp table to calculate invoice-level payment aggregations
DROP TEMPORARY TABLE IF EXISTS temp_invoice_payments;
CREATE TEMPORARY TABLE temp_invoice_payments AS
SELECT 
    invoice_id,
    SUM(amount_paid) AS total_amount_paid,
    MAX(payment_date) AS last_payment_date,
    CAST(MAX(COALESCE(NULLIF(method, ''), 'transfer')) AS CHAR(20)) AS last_payment_method  -- Most recent payment method, default to 'transfer' if NULL
FROM greencity_operational.payments
GROUP BY invoice_id;

-- Insert into fact table
INSERT INTO fact_economic_profitability (
    invoice_date_key,
    period_start_key,
    period_end_key,
    payment_date_key,
    client_key,
    building_key,
    region_key,
    energy_type_key,
    status_key,
    payment_method_key,
    revenue_ttc,
    revenue_ht,
    consumption_qty,
    unit_price,
    invoice_total_ttc,
    invoice_energy_cost,
    line_margin,
    margin_percentage,
    invoice_amount_paid,
    line_amount_paid,
    payment_rate
)
SELECT 
    -- Date keys
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
    -- Line margin = line_ttc - (proportional energy_cost)
    (il.line_ttc - (il.line_ttc / NULLIF(inv.total_ttc, 0) * inv.energy_cost)) AS line_margin,
    -- Margin percentage
    CASE 
        WHEN il.line_ttc > 0 THEN 
            ((il.line_ttc - (il.line_ttc / NULLIF(inv.total_ttc, 0) * inv.energy_cost)) / il.line_ttc) * 100
        ELSE 0 
    END AS margin_percentage,
    -- Payment aggregations
    COALESCE(tip.total_amount_paid, 0) AS invoice_amount_paid,
    -- Proportional line amount paid
    CASE 
        WHEN inv.total_ttc > 0 THEN 
            (il.line_ttc / inv.total_ttc) * COALESCE(tip.total_amount_paid, 0)
        ELSE 0 
    END AS line_amount_paid,
    -- Payment rate
    CASE 
        WHEN inv.total_ttc > 0 THEN 
            (COALESCE(tip.total_amount_paid, 0) / inv.total_ttc) * 100
        ELSE 0 
    END AS payment_rate
FROM greencity_operational.invoice_lines il
INNER JOIN greencity_operational.invoices inv ON il.invoice_id = inv.invoice_id
LEFT JOIN temp_invoice_payments tip ON inv.invoice_id = tip.invoice_id
-- Join with dimension tables
INNER JOIN greencity_dm.dim_date dd_invoice ON DATE(inv.invoice_date) = dd_invoice.full_date
LEFT JOIN greencity_dm.dim_date dd_start ON DATE(il.period_start) = dd_start.full_date
LEFT JOIN greencity_dm.dim_date dd_end ON DATE(il.period_end) = dd_end.full_date
LEFT JOIN greencity_dm.dim_date dd_payment ON DATE(tip.last_payment_date) = dd_payment.full_date
INNER JOIN greencity_dm.dim_client dc ON inv.client_id = dc.client_id
INNER JOIN greencity_dm.dim_building db ON inv.building_id = db.building_id
INNER JOIN greencity_dm.dim_energy_type det ON il.energy_type = det.energy_type_code
INNER JOIN greencity_dm.dim_invoice_status dis ON COALESCE(NULLIF(inv.status, ''), 'sent') = dis.status_code
LEFT JOIN greencity_dm.dim_payment_method dpm ON tip.last_payment_method = dpm.method_code;

-- Show results
SELECT 
    'fact_economic_profitability' AS table_name,
    COUNT(*) AS row_count,
    SUM(revenue_ttc) AS total_revenue,
    SUM(line_margin) AS total_margin,
    AVG(payment_rate) AS avg_payment_rate
FROM fact_economic_profitability;

