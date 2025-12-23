-- Operational schema for GreenCity (MySQL/MariaDB)
-- Tables include timestamps for incremental extraction.
-- Engine/charset defaults can be adjusted as needed.

CREATE TABLE IF NOT EXISTS regions (
    region_id       VARCHAR(10) PRIMARY KEY,
    region_name     VARCHAR(100) NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS clients (
    client_id       VARCHAR(10) PRIMARY KEY,
    client_name     VARCHAR(150) NOT NULL,
    contact_email   VARCHAR(150),
    contact_phone   VARCHAR(50),
    billing_address VARCHAR(255),
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS buildings (
    building_id     VARCHAR(10) PRIMARY KEY,
    client_id       VARCHAR(10) NOT NULL,
    region_id       VARCHAR(10) NOT NULL,
    building_name   VARCHAR(150),
    building_type   VARCHAR(50), -- e.g., office, residential, warehouse
    surface_m2      DECIMAL(10,2),
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_building_client FOREIGN KEY (client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_building_region FOREIGN KEY (region_id) REFERENCES regions(region_id)
);

CREATE TABLE IF NOT EXISTS meters (
    meter_id        VARCHAR(15) PRIMARY KEY,
    building_id     VARCHAR(10) NOT NULL,
    energy_type     ENUM('electricite','eau','gaz') NOT NULL,
    unit            VARCHAR(10) NOT NULL, -- KWh, m3
    installed_at    DATE,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_meter_building FOREIGN KEY (building_id) REFERENCES buildings(building_id)
);

CREATE TABLE IF NOT EXISTS invoices (
    invoice_id      VARCHAR(15) PRIMARY KEY,
    client_id       VARCHAR(10) NOT NULL,
    building_id     VARCHAR(10) NOT NULL,
    invoice_date    DATE NOT NULL,
    due_date        DATE,
    total_ht        DECIMAL(12,2) NOT NULL,
    total_ttc       DECIMAL(12,2) NOT NULL,
    energy_cost     DECIMAL(12,2) NOT NULL, -- for profitability calc
    status          ENUM('sent','paid','overdue','cancelled') DEFAULT 'sent',
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_invoice_client FOREIGN KEY (client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_invoice_building FOREIGN KEY (building_id) REFERENCES buildings(building_id)
);

CREATE TABLE IF NOT EXISTS invoice_lines (
    invoice_line_id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id      VARCHAR(15) NOT NULL,
    meter_id        VARCHAR(15) NOT NULL,
    energy_type     ENUM('electricite','eau','gaz') NOT NULL,
    period_start    DATETIME NOT NULL,
    period_end      DATETIME NOT NULL,
    consumption_qty DECIMAL(12,3) NOT NULL,
    unit_price      DECIMAL(10,4) NOT NULL,
    line_ht         DECIMAL(12,2) NOT NULL,
    line_ttc        DECIMAL(12,2) NOT NULL,
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_line_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id),
    CONSTRAINT fk_line_meter FOREIGN KEY (meter_id) REFERENCES meters(meter_id)
);

CREATE TABLE IF NOT EXISTS payments (
    payment_id      VARCHAR(15) PRIMARY KEY,
    invoice_id      VARCHAR(15) NOT NULL,
    payment_date    DATE NOT NULL,
    amount_paid     DECIMAL(12,2) NOT NULL,
    method          ENUM('transfer','card','cash','check') DEFAULT 'transfer',
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_payment_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(invoice_id)
);

-- Environmental reports CSVs will be ingested via staging; storing source-like table for completeness.
CREATE TABLE IF NOT EXISTS env_reports (
    env_id          INT AUTO_INCREMENT PRIMARY KEY,
    region_id       VARCHAR(10) NOT NULL,
    building_id     VARCHAR(10) NOT NULL,
    report_date     DATE NOT NULL,
    emission_co2_kg DECIMAL(12,2),
    taux_recyclage  DECIMAL(5,2),
    created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_env_region FOREIGN KEY (region_id) REFERENCES regions(region_id),
    CONSTRAINT fk_env_building FOREIGN KEY (building_id) REFERENCES buildings(building_id)
);

