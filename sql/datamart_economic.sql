-- Data Mart: Rentabilité économique
-- Target database: greencity_dm
-- This Data Mart reuses shared dimensions from Consumption Data Mart

USE greencity_dm;

-- Additional dimensions for Economic Data Mart

-- Dimension: Invoice Status
CREATE TABLE IF NOT EXISTS dim_invoice_status (
  status_key       INT AUTO_INCREMENT PRIMARY KEY,
  status_code      VARCHAR(20) NOT NULL,        -- sent, paid, overdue, cancelled
  status_name      VARCHAR(50),
  created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_dim_invoice_status_business (status_code)
);

-- Dimension: Payment Method
CREATE TABLE IF NOT EXISTS dim_payment_method (
  method_key       INT AUTO_INCREMENT PRIMARY KEY,
  method_code      VARCHAR(20) NOT NULL,        -- transfer, card, cash, check
  method_name      VARCHAR(50),
  created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_dim_payment_method_business (method_code)
);

-- Fact table: Economic Profitability
-- Granularity: One row per invoice line (allows analysis by energy type)
-- Measures: Revenue (CA), Payments, Margin, Profitability

CREATE TABLE IF NOT EXISTS fact_economic_profitability (
  fact_id              BIGINT AUTO_INCREMENT PRIMARY KEY,
  -- Dimension keys (reuse shared dimensions)
  invoice_date_key     INT NOT NULL,            -- Date of invoice
  period_start_key     INT,                     -- Start of consumption period
  period_end_key       INT,                     -- End of consumption period
  payment_date_key     INT,                     -- Date of payment (may be NULL if unpaid)
  client_key           INT NOT NULL,
  building_key         INT NOT NULL,
  region_key           INT,
  energy_type_key      INT NOT NULL,
  status_key           INT NOT NULL,            -- Invoice status
  payment_method_key   INT,                     -- Payment method (most recent payment, NULL if unpaid)
  -- Measures (from invoice_line)
  revenue_ttc          DECIMAL(14,2) NOT NULL,  -- Chiffre d'affaires (line_ttc from invoice_line)
  revenue_ht           DECIMAL(14,2) NOT NULL,  -- Revenue before tax (line_ht)
  consumption_qty      DECIMAL(14,3) NOT NULL,  -- Consumption quantity
  unit_price           DECIMAL(10,4) NOT NULL,  -- Unit price
  -- Measures (calculated/aggregated)
  invoice_total_ttc    DECIMAL(14,2) NOT NULL,  -- Total invoice TTC (for calculating proportions)
  invoice_energy_cost  DECIMAL(14,2) NOT NULL,  -- Energy cost from invoice (proportional to line)
  line_margin          DECIMAL(14,2) NOT NULL,  -- Line margin = line_ttc - (proportional energy_cost)
  margin_percentage    DECIMAL(5,2),            -- Margin % = (line_margin / revenue_ttc) * 100
  invoice_amount_paid  DECIMAL(14,2) DEFAULT 0, -- Total amount paid for invoice (sum of payments)
  line_amount_paid     DECIMAL(14,2) DEFAULT 0, -- Proportional amount paid for this line
  payment_rate         DECIMAL(5,2),            -- Taux de recouvrement = (invoice_amount_paid / invoice_total_ttc) * 100
  -- Timestamps
  created_at           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  -- Foreign keys
  CONSTRAINT fk_fact_economic_invoice_date FOREIGN KEY (invoice_date_key) REFERENCES dim_date(date_key),
  CONSTRAINT fk_fact_economic_period_start FOREIGN KEY (period_start_key) REFERENCES dim_date(date_key),
  CONSTRAINT fk_fact_economic_period_end FOREIGN KEY (period_end_key) REFERENCES dim_date(date_key),
  CONSTRAINT fk_fact_economic_payment_date FOREIGN KEY (payment_date_key) REFERENCES dim_date(date_key),
  CONSTRAINT fk_fact_economic_client FOREIGN KEY (client_key) REFERENCES dim_client(client_key),
  CONSTRAINT fk_fact_economic_building FOREIGN KEY (building_key) REFERENCES dim_building(building_key),
  CONSTRAINT fk_fact_economic_region FOREIGN KEY (region_key) REFERENCES dim_region(region_key),
  CONSTRAINT fk_fact_economic_energy_type FOREIGN KEY (energy_type_key) REFERENCES dim_energy_type(energy_type_key),
  CONSTRAINT fk_fact_economic_status FOREIGN KEY (status_key) REFERENCES dim_invoice_status(status_key),
  CONSTRAINT fk_fact_economic_payment_method FOREIGN KEY (payment_method_key) REFERENCES dim_payment_method(method_key),
  -- Indexes for performance
  KEY idx_fact_economic_invoice_date (invoice_date_key),
  KEY idx_fact_economic_client (client_key),
  KEY idx_fact_economic_building (building_key),
  KEY idx_fact_economic_region (region_key),
  KEY idx_fact_economic_energy_type (energy_type_key),
  KEY idx_fact_economic_status (status_key)
);

