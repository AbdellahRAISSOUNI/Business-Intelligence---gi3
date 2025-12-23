LOAD DATA LOCAL INFILE 'C:/Users/earth/Desktop/s9/bi/Business Intelligence - Mini Projet/data_sources/csv/operational_seed/regions.csv'
INTO TABLE regions
FIELDS TERMINATED BY ','
IGNORE 1 LINES
(region_id, region_name);

LOAD DATA LOCAL INFILE 'C:/Users/earth/Desktop/s9/bi/Business Intelligence - Mini Projet/data_sources/csv/operational_seed/clients.csv'
INTO TABLE clients
FIELDS TERMINATED BY ','
IGNORE 1 LINES
(client_id, client_name, contact_email, contact_phone, billing_address);

LOAD DATA LOCAL INFILE 'C:/Users/earth/Desktop/s9/bi/Business Intelligence - Mini Projet/data_sources/csv/operational_seed/buildings.csv'
INTO TABLE buildings
FIELDS TERMINATED BY ','
IGNORE 1 LINES
(building_id, client_id, region_id, building_name, building_type, surface_m2);

LOAD DATA LOCAL INFILE 'C:/Users/earth/Desktop/s9/bi/Business Intelligence - Mini Projet/data_sources/csv/operational_seed/meters.csv'
INTO TABLE meters
FIELDS TERMINATED BY ','
IGNORE 1 LINES
(meter_id, building_id, energy_type, unit, installed_at);

LOAD DATA LOCAL INFILE 'C:/Users/earth/Desktop/s9/bi/Business Intelligence - Mini Projet/data_sources/csv/operational_seed/invoices.csv'
INTO TABLE invoices
FIELDS TERMINATED BY ','
IGNORE 1 LINES
(invoice_id, client_id, building_id, invoice_date, due_date, total_ht, total_ttc, energy_cost, status);

LOAD DATA LOCAL INFILE 'C:/Users/earth/Desktop/s9/bi/Business Intelligence - Mini Projet/data_sources/csv/operational_seed/invoice_lines.csv'
INTO TABLE invoice_lines
FIELDS TERMINATED BY ','
IGNORE 1 LINES
(invoice_id, meter_id, energy_type, period_start, period_end, consumption_qty, unit_price, line_ht, line_ttc);

LOAD DATA LOCAL INFILE 'C:/Users/earth/Desktop/s9/bi/Business Intelligence - Mini Projet/data_sources/csv/operational_seed/payments.csv'
INTO TABLE payments
FIELDS TERMINATED BY ','
IGNORE 1 LINES
(payment_id, invoice_id, payment_date, amount_paid, method);

