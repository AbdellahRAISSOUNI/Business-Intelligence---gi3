# Power BI Quick Start Guide

## Quick Connection Steps

1. **Open Power BI Desktop**

2. **Get Data → MySQL database**
   - Server: `localhost`
   - Database: `greencity_dm`
   - Username: `root`
   - Password: (empty or your password)

3. **Select these tables:**
   - All fact tables: `fact_energy_consumption`, `fact_economic_profitability`, `fact_environmental_impact`
   - All dimension tables: `dim_date`, `dim_region`, `dim_client`, `dim_building`, `dim_meter`, `dim_energy_type`, `dim_invoice_status`, `dim_payment_method`

4. **Click "Load"**

5. **Go to Model view** - Check relationships are created automatically

6. **Start creating visuals!**

## Essential DAX Measures to Create

Paste these in "New Measure" under each fact table:

### fact_energy_consumption table:
```dax
Total Consumption = SUM(fact_energy_consumption[consumption_kwh])
```

### fact_economic_profitability table:
```dax
Total Revenue = SUM(fact_economic_profitability[revenue_ttc])
Total Margin = SUM(fact_economic_profitability[margin])
Payment Rate % = DIVIDE(SUM(fact_economic_profitability[payment_amount]), SUM(fact_economic_profitability[revenue_ttc]), 0) * 100
```

### fact_environmental_impact table:
```dax
Total CO2 = SUM(fact_environmental_impact[emission_co2_kg])
Avg Recycling = AVERAGE(fact_environmental_impact[recycling_rate])
```

## Dashboard Pages to Create

1. **Overview Page** - Key metrics cards + time series
2. **Energy Consumption** - Consumption by region, building, type
3. **Economic Performance** - Revenue, margin, top clients
4. **Environmental Impact** - CO2 emissions, recycling rates

Save your work frequently as `.pbix` file in `reports/` folder!


