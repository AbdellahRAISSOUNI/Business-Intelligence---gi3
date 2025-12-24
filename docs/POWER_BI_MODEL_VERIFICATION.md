# Power BI Model View - Expected Structure

## What Your Model View Should Look Like

In Power BI's Model view, you should see a star schema similar to the diagram, with:

### Fact Tables (Center - Connected to multiple dimensions)

1. **fact_energy_consumption**
   - Connected to: dim_date, dim_region, dim_client, dim_building, dim_meter, dim_energy_type
   - Key measures: consumption_kwh, consumption_value

2. **fact_economic_profitability**
   - Connected to: dim_date (via invoice_date_key), dim_client, dim_building, dim_region, dim_energy_type, dim_invoice_status, dim_payment_method
   - Key measures: revenue_ttc, margin, payment_amount, invoice_energy_cost

3. **fact_environmental_impact**
   - Connected to: dim_date, dim_region, dim_building
   - Key measures: emission_co2_kg, recycling_rate

### Dimension Tables (Surrounding facts - connected to one or more facts)

1. **dim_date** - Connected to fact_energy_consumption and fact_economic_profitability
2. **dim_region** - Connected to dim_building, fact_environmental_impact
3. **dim_client** - Connected to dim_building, fact_energy_consumption, fact_economic_profitability
4. **dim_building** - Connected to dim_meter, fact_energy_consumption, fact_economic_profitability, fact_environmental_impact
5. **dim_meter** - Connected to fact_energy_consumption
6. **dim_energy_type** - Connected to dim_meter, fact_energy_consumption, fact_economic_profitability
7. **dim_invoice_status** - Connected to fact_economic_profitability
8. **dim_payment_method** - Connected to fact_economic_profitability

## Relationship Verification Checklist

After loading tables, go to Model view and verify:

### fact_energy_consumption relationships:
- [ ] date_key → dim_date.date_key (Many-to-One)
- [ ] region_key → dim_region.region_key (Many-to-One)
- [ ] client_key → dim_client.client_key (Many-to-One)
- [ ] building_key → dim_building.building_key (Many-to-One)
- [ ] meter_key → dim_meter.meter_key (Many-to-One)
- [ ] energy_type_key → dim_energy_type.energy_type_key (Many-to-One)

### fact_economic_profitability relationships:
- [ ] invoice_date_key → dim_date.date_key (Many-to-One)
- [ ] client_key → dim_client.client_key (Many-to-One)
- [ ] building_key → dim_building.building_key (Many-to-One)
- [ ] region_key → dim_region.region_key (Many-to-One)
- [ ] energy_type_key → dim_energy_type.energy_type_key (Many-to-One)
- [ ] invoice_status_key → dim_invoice_status.status_key (Many-to-One)
- [ ] payment_method_key → dim_payment_method.method_key (Many-to-One)

### fact_environmental_impact relationships:
- [ ] date_key → dim_date.date_key (Many-to-One)
- [ ] region_key → dim_region.region_key (Many-to-One)
- [ ] building_key → dim_building.building_key (Many-to-One)

### Dimension-to-dimension relationships:
- [ ] dim_building.region_key → dim_region.region_key (Many-to-One)
- [ ] dim_building.client_key → dim_client.client_key (Many-to-One)
- [ ] dim_meter.building_key → dim_building.building_key (Many-to-One)
- [ ] dim_meter.energy_type_key → dim_energy_type.energy_type_key (Many-to-One)

## Visual Appearance in Model View

- **Fact tables** should appear as larger boxes (often shown in a different color)
- **Dimension tables** should surround fact tables
- **Lines with arrows** showing relationships (arrow points from "many" side to "one" side)
- **Cardinality indicators** showing "1" on dimension side and "*" on fact side

## If Relationships Are Missing

1. Click and drag from the foreign key column in the fact table
2. Drop it on the primary key column in the dimension table
3. Verify cardinality: Many-to-One (fact → dimension)
4. Set cross-filter direction: Single (fact table filters dimension)

## Tips

- Power BI often auto-detects relationships, but always verify them
- You can rearrange tables in Model view by dragging them
- Right-click a relationship line to edit or delete it
- Use "Manage Relationships" button to see all relationships in a list view


