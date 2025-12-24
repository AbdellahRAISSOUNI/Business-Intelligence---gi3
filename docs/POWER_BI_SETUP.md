# Power BI Dashboard Setup Guide

## Overview
This guide will help you connect Power BI Desktop to the MySQL Data Warehouse (`greencity_dm`) and create interactive dashboards for the three Data Marts.

## Prerequisites

1. **Power BI Desktop** installed (from Microsoft Store or direct download)
2. **MySQL ODBC Driver** - Required for Power BI to connect to MySQL
   - Download: [MySQL Connector/ODBC](https://dev.mysql.com/downloads/connector/odbc/)
   - Install the Windows version (choose 64-bit if you have 64-bit Windows)
3. **MySQL Server** running with `greencity_dm` database loaded

## Step 1: Install MySQL ODBC Driver

1. Download MySQL Connector/ODBC from: https://dev.mysql.com/downloads/connector/odbc/
2. Install the driver (usually installs to: `MySQL ODBC 8.0 Unicode Driver`)
3. Verify installation:
   - Open Windows Settings → Apps → Look for "MySQL ODBC 8.0 Driver"

## Step 2: Connect Power BI to MySQL

1. **Open Power BI Desktop**

2. **Get Data:**
   - Click "Get Data" button (top left)
   - Search for "MySQL database"
   - Select **"MySQL database"** → Click "Connect"

3. **Connection Settings:**
   - **Server:** `localhost` (or `127.0.0.1`)
   - **Database:** `greencity_dm`
   - **Data connectivity mode:** Choose "Import" (recommended for better performance)
   - Click "OK"

4. **Authentication:**
   - **Username:** `root`
   - **Password:** (leave empty if no password, or enter your MySQL password)
   - Click "Connect"

5. **Navigator Window:**
   - You should see all tables from `greencity_dm`
   - Select the tables you need (see tables list below)
   - Click "Load" or "Transform Data"

## Step 3: Tables to Load

### Consumption Data Mart
- `fact_energy_consumption`
- `dim_date`
- `dim_region`
- `dim_client`
- `dim_building`
- `dim_meter`
- `dim_energy_type`

### Economic Profitability Data Mart
- `fact_economic_profitability`
- `dim_date` (already loaded)
- `dim_invoice_status`
- `dim_payment_method`
- `dim_client` (already loaded)
- `dim_building` (already loaded)
- `dim_region` (already loaded)

### Environmental Impact Data Mart
- `fact_environmental_impact`
- `dim_date` (already loaded)
- `dim_building` (already loaded)
- `dim_region` (already loaded)

**Note:** Power BI will automatically detect relationships based on foreign keys if properly set up.

## Step 4: Create Relationships

1. Click "Model" view (left sidebar, third icon)
2. Power BI should auto-detect relationships. Verify they look correct:
   - `fact_energy_consumption.date_key` → `dim_date.date_key`
   - `fact_energy_consumption.region_key` → `dim_region.region_key`
   - `fact_energy_consumption.building_key` → `dim_building.building_key`
   - `fact_energy_consumption.client_key` → `dim_client.client_key`
   - `fact_energy_consumption.meter_key` → `dim_meter.meter_key`
   - `fact_energy_consumption.energy_type_key` → `dim_energy_type.energy_type_key`
   - Similar relationships for economic and environmental fact tables

3. **If relationships are missing:**
   - Drag and drop foreign key to primary key to create relationship
   - Ensure cardinality is correct (Many-to-One for fact → dimension)

## Step 5: Create Calculated Measures (DAX)

### How to Create a Measure - Step by Step

1. **Select the correct table:**
   - In the right sidebar "Fields" pane, find the table where you want to create the measure
   - For consumption measures: Right-click on `greencity_dm_fact_energy_consumption` table
   - For economic measures: Right-click on `greencity_dm_fact_economic_profitability` table
   - For environmental measures: Right-click on `greencity_dm_fact_environmental_impact` table

2. **Create new measure:**
   - Right-click on the table name → Select **"New measure"**
   - OR: Select the table, then go to **"Measure tools"** tab → Click **"New measure"** button

3. **Type the DAX formula:**
   - You'll see a formula bar appear at the top (above the ribbon)
   - The formula bar will show: `Measure = ` (where "Measure" is highlighted)
   - Replace "Measure" with your measure name
   - After the `=`, type your DAX formula

4. **Example - Creating "Total Consumption (kWh)":**
   - Right-click `greencity_dm_fact_energy_consumption` → "New measure"
   - In formula bar, type:
     ```
     Total Consumption (kWh) = SUM([consumption_kwh])
     ```
   - Press **Enter** or click the checkmark (✓) next to the formula bar
   - The measure will appear under the table in the Fields pane with a calculator icon (fx)

5. **Important Notes:**
   - **Column names only:** When creating a measure within a table, you only need the column name in brackets: `[column_name]` - NOT the full table.column syntax
   - **Column names:** Use exact column names in square brackets: `[column_name]`
   - **No spaces in measure names:** If you need spaces, use brackets: `[Total Consumption (kWh)]`
   - **Formatting:** After creating, you can format the measure (currency, percentage, decimal places) in the "Measure tools" tab

### Consumption Measures

Create these measures in the `greencity_dm_fact_energy_consumption` table:

```dax
Total Consumption (kWh) = SUM([consumption_kwh])

Average Consumption (kWh) = AVERAGE([consumption_kwh])
```

**Step-by-step for "Total Consumption (kWh)":**
1. Right-click `greencity_dm_fact_energy_consumption` → "New measure"
2. In formula bar, replace everything with:
   ```
   Total Consumption (kWh) = SUM([consumption_kwh])
   ```
3. Press Enter
4. You should see "Total Consumption (kWh)" appear under the table in Fields pane

### Economic Measures

Create these measures in the `greencity_dm_fact_economic_profitability` table:

```dax
Total Revenue = SUM([revenue_ttc])

Total Margin = SUM([line_margin])

Payment Rate = DIVIDE(SUM([line_amount_paid]), SUM([revenue_ttc]), 0) * 100
```

**Step-by-step for "Payment Rate":**
1. Right-click `greencity_dm_fact_economic_profitability` → "New measure"
2. In formula bar, type:
   ```
   Payment Rate = DIVIDE(SUM([line_amount_paid]), SUM([revenue_ttc]), 0) * 100
   ```
3. Press Enter to create
4. **Format as percentage:** Click on the measure, go to "Measure tools" → Format → Select "Percentage" → Decimal places: 2

### Environmental Measures

Create these measures in the `greencity_dm_fact_environmental_impact` table:

```dax
Total CO2 Emissions = SUM([emission_co2_kg])

Average Recycling Rate = AVERAGE([taux_recyclage_pct])
```

### Troubleshooting Measure Creation

- **Error: "The syntax for '[table]' is incorrect":**
  - Check table name spelling exactly as it appears in Fields pane
  - Make sure to include the `greencity_dm_` prefix

- **Error: "Column '[column]' doesn't exist":**
  - Check column name spelling exactly as it appears in the table
  - Column names are case-sensitive and must match exactly

- **Measure shows as blank/error:**
  - Check that your data has been loaded (go to Data view to verify)
  - Ensure column names match (may be `consumption_kwh` not `consumption_KWh`)

- **Warning triangle on measure:**
  - Usually means the formula has an issue
  - Click on the measure and check the formula bar for syntax errors

## Step 6: Create Visualizations

### How to Create a Visualization - General Steps

1. **Go to Report view:** Click the "Report" icon (first icon) in the left sidebar
2. **Insert a visual:** Click on a visual type in the "Visualizations" pane (right side) OR go to "Insert" tab → Select visual type
3. **Add fields to the visual:**
   - **Axis/X-axis:** Drag fields here for categories (e.g., dates, regions, buildings)
   - **Values/Y-axis:** Drag measures or numeric fields here (e.g., Total Consumption, Total Revenue)
   - **Legend:** Drag fields here to create series/groups (optional)
4. **Format the visual:** Click the visual → Use "Format visual" pane (paint roller icon) to customize colors, titles, etc.

---

### Dashboard 1: Energy Consumption

Create a new page: Click the "+" button at the bottom to add a new page, rename it to "Energy Consumption"

#### 1. KPI Card - Total Consumption (kWh)

**Steps:**
1. In "Visualizations" pane, click the **"Card"** icon (looks like a number card)
2. A blank card appears on the canvas
3. In "Fields" pane (right side), find `greencity_dm_fact_energy_consumption` table
4. Drag your measure **"Total Consumption (kWh)"** to the card
5. **Format:** Click the card → "Format visual" → Add a title: "Total Consumption (kWh)"

#### 2. Line Chart - Consumption over Time

**Steps:**
1. Click **"Line chart"** icon in Visualizations pane
2. **X-axis:** Expand `greencity_dm_dim_date` table → Drag **"full_date"** to "Axis" field well
3. **Y-axis:** Drag **"Total Consumption (kWh)"** measure to "Values" field well
4. **Format:** Add title "Consumption Over Time"

#### 3. Bar Chart - Consumption by Region

**Steps:**
1. Click **"Stacked bar chart"** icon (or "Clustered bar chart")
2. **X-axis (categories):** Expand `greencity_dm_dim_region` → Drag **"region_name"** to "Axis"
3. **Y-axis (values):** Drag **"Total Consumption (kWh)"** to "Values"
4. **Format:** Add title "Consumption by Region"

#### 4. Bar Chart - Consumption by Building

**Steps:**
1. Click **"Stacked bar chart"** icon
2. **X-axis:** Expand `greencity_dm_dim_building` → Drag **"building_name"** to "Axis"
3. **Y-axis:** Drag **"Total Consumption (kWh)"** to "Values"
4. **Format:** Add title "Consumption by Building"

#### 5. Pie Chart - Consumption by Energy Type

**Steps:**
1. Click **"Pie chart"** icon
2. **Legend:** Expand `greencity_dm_dim_energy_type` → Drag **"energy_type_code"** to "Legend"
3. **Values:** Drag **"Total Consumption (kWh)"** to "Values"
4. **Format:** Add title "Consumption by Energy Type"

#### 6. Table - Top 10 Buildings by Consumption

**Steps:**
1. Click **"Table"** icon
2. **Values (columns):** Drag these fields in order:
   - `dim_building[building_name]`
   - `dim_region[region_name]`
   - `Total Consumption (kWh)` measure
3. **Sort:** Click on the table → Click the arrow next to "Total Consumption (kWh)" column → "Sort descending"
4. **Limit to 10:** Click table → "Visualizations" pane → "Filters on this visual" → Expand "Total Consumption (kWh)" → "Top N" → Set to "Top 10"
5. **Format:** Add title "Top 10 Buildings by Consumption"

---

### Dashboard 2: Economic Profitability

Create new page: Click "+" button, rename to "Economic Profitability"

#### 1. KPI Cards - Total Revenue, Total Margin, Payment Rate

**Steps (repeat for each):**
1. Click **"Card"** icon
2. Drag measure to card:
   - First card: **"Total Revenue"**
   - Second card: **"Total Margin"**
   - Third card: **"Payment Rate"** (format as percentage)
3. Arrange 3 cards side-by-side
4. **Format Payment Rate as percentage:** Click the card → "Measure tools" → Format → Percentage → 2 decimal places

#### 2. Line Chart - Revenue over Time

**Steps:**
1. Click **"Line chart"** icon
2. **X-axis:** `dim_date[full_date]` → "Axis"
3. **Y-axis:** **"Total Revenue"** measure → "Values"
4. **Format:** Add title "Revenue Over Time"

#### 3. Bar Chart - Revenue by Region

**Steps:**
1. Click **"Bar chart"** icon
2. **X-axis:** `dim_region[region_name]` → "Axis"
3. **Y-axis:** **"Total Revenue"** → "Values"
4. **Format:** Add title "Revenue by Region"

#### 4. Bar Chart - Revenue by Building

**Steps:**
1. Click **"Bar chart"** icon
2. **X-axis:** `dim_building[building_name]` → "Axis"
3. **Y-axis:** **"Total Revenue"** → "Values"
4. **Format:** Add title "Revenue by Building"

#### 5. Table - Top 10 Most Profitable Clients

**Steps:**
1. Click **"Table"** icon
2. **Values:** Drag:
   - `dim_client[client_name]`
   - **"Total Revenue"** measure
   - **"Total Margin"** measure
3. **Sort by Margin:** Click arrow on "Total Margin" column → "Sort descending"
4. **Top 10:** "Filters on this visual" → "Top N" → Set to 10
5. **Format:** Add title "Top 10 Most Profitable Clients"

#### 6. Bar Chart - Margin by Payment Method

**Steps:**
1. Click **"Bar chart"** icon
2. **X-axis:** `dim_payment_method[method_name]` → "Axis"
3. **Y-axis:** **"Total Margin"** → "Values"
4. **Format:** Add title "Margin by Payment Method"

---

### Dashboard 3: Environmental Impact

Create new page: Click "+" button, rename to "Environmental Impact"

#### 1. KPI Cards - Total CO2, Average Recycling Rate

**Steps:**
1. Create two **"Card"** visuals
2. First card: Drag **"Total CO2 Emissions"** measure
3. Second card: Drag **"Average Recycling Rate"** measure (format as percentage)
4. Arrange side-by-side

#### 2. Line Chart - CO2 Emissions over Time

**Steps:**
1. Click **"Line chart"** icon
2. **X-axis:** `dim_date[full_date]` → "Axis"
3. **Y-axis:** **"Total CO2 Emissions"** → "Values"
4. **Format:** Add title "CO2 Emissions Over Time"

#### 3. Bar Chart - CO2 Emissions by Region

**Steps:**
1. Click **"Bar chart"** icon
2. **X-axis:** `dim_region[region_name]` → "Axis"
3. **Y-axis:** **"Total CO2 Emissions"** → "Values"
4. **Format:** Add title "CO2 Emissions by Region"

#### 4. Bar Chart - Top 10 Most Polluting Buildings

**Steps:**
1. Click **"Bar chart"** icon
2. **X-axis:** `dim_building[building_name]` → "Axis"
3. **Y-axis:** **"Total CO2 Emissions"** → "Values"
4. **Sort descending:** Click arrow on chart → Sort by "Total CO2 Emissions" descending
5. **Top 10:** "Filters on this visual" → "Top N" → Set to 10
6. **Format:** Add title "Top 10 Most Polluting Buildings"

#### 5. Donut Chart - Recycling Rate Distribution

**Steps:**
1. Click **"Donut chart"** icon (or use "Pie chart")
2. **Legend:** `dim_building[building_name]` → "Legend"
3. **Values:** **"Average Recycling Rate"** → "Values"
4. **Format:** Add title "Recycling Rate by Building"

#### 6. Scatter Chart - CO2 vs Consumption (Optional - Advanced)

**Steps:**
1. Click **"Scatter chart"** icon
2. **X-axis:** **"Total Consumption (kWh)"** → "X-axis Values"
3. **Y-axis:** **"Total CO2 Emissions"** → "Y-axis Values"
4. **Details:** `dim_building[building_name]` → "Details" (to show building names on hover)
5. **Format:** Add title "CO2 vs Consumption Ratio"

---

### Combined Dashboard (Main Overview)

Create new page: Click "+" button, rename to "Overview"

#### 1. KPI Cards Row - Total Consumption, Total Revenue, Total CO2

**Steps:**
1. Create three **"Card"** visuals
2. Drag measures:
   - Card 1: **"Total Consumption (kWh)"**
   - Card 2: **"Total Revenue"**
   - Card 3: **"Total CO2 Emissions"**
3. Arrange in a horizontal row at the top

#### 2. Line Chart - All Metrics over Time

**Steps:**
1. Click **"Line chart"** icon
2. **X-axis:** `dim_date[full_date]` → "Axis"
3. **Y-axis:** Drag ALL three measures to "Values":
   - **"Total Consumption (kWh)"**
   - **"Total Revenue"**
   - **"Total CO2 Emissions"**
4. Each measure will create a separate line
5. **Format:** Add title "Key Metrics Over Time"

#### 3. Table/Matrix - Region Comparison

**Steps:**
1. Click **"Matrix"** icon (or "Table")
2. **Rows:** `dim_region[region_name]` → "Rows"
3. **Values:** Drag all key measures:
   - **"Total Consumption (kWh)"**
   - **"Total Revenue"**
   - **"Total Margin"**
   - **"Total CO2 Emissions"**
4. **Format:** Add title "Regional Comparison"

#### 4. Slicers (Filters) - Date Range, Region, Building, Client

**Steps for each slicer:**
1. Click **"Slicer"** icon (looks like a filter)
2. Drag field to slicer:
   - **Date slicer:** `dim_date[full_date]` → Format as "Between" for date range
   - **Region slicer:** `dim_region[region_name]`
   - **Building slicer:** `dim_building[building_name]`
   - **Client slicer:** `dim_client[client_name]`
3. Arrange slicers on the left side or top of the page
4. **Note:** Slicers automatically filter ALL visuals on the page when you make a selection

---

### Tips for Arranging Visuals

1. **Resize visuals:** Click and drag the corners to resize
2. **Move visuals:** Click and drag the visual to reposition
3. **Align visuals:** Select multiple visuals (Ctrl+Click) → Use "Format" tab → Align options
4. **Make visuals same size:** Select multiple → Format → "Match" → Match width/height
5. **Grid lines:** View tab → Check "Gridlines" to help align visuals

## Step 7: Add Interactivity

1. **Add Slicers:**
   - Insert → Slicer → Select field (e.g., Region, Date, Building)
   - Slicers filter all visuals on the page

2. **Cross-filtering:**
   - Select a visual element → Other visuals highlight related data
   - Configure in Format pane → Edit interactions

3. **Drill-through:**
   - Right-click a data point → "Drill through" to detailed page

## Step 8: Formatting and Polish

1. **Theme:** View → Themes → Choose a theme or customize
2. **Colors:** Format each visual with consistent color scheme
3. **Titles:** Add descriptive titles to all visuals
4. **Tooltips:** Add tooltips with additional context
5. **Layout:** Arrange visuals in logical flow (KPIs at top, charts below)

## Step 9: Save Your Report

1. **File → Save As**
2. Save as: `reports/GreenCity_BI_Dashboard.pbix`
3. **File → Publish** (optional, if you have Power BI Service account)

## Troubleshooting

### Connection Issues

- **"ODBC Driver not found":** Install MySQL ODBC Driver (Step 1)
- **"Access denied":** Check MySQL username/password
- **"Can't connect to server":** Ensure MySQL server is running

### Performance Issues

- Use "Import" mode instead of "DirectQuery" for better performance
- Limit data loaded (use filters in Power Query before loading)
- Use aggregations for large datasets

### Relationship Issues

- Check that foreign keys match primary keys exactly
- Verify data types match (both should be numeric for key relationships)
- Use "Manage Relationships" to edit relationship properties

## Next Steps

After creating dashboards:
1. Test all filters and interactions
2. Take screenshots for documentation
3. Create a summary document explaining each dashboard
4. Consider scheduling data refresh if connecting to production data

## Quick Reference: Key KPIs Required

### Consumption
- ✅ Consommation totale (kWh) : par client, bâtiment, région, période
- ✅ Évolution dans le temps (graphique en courbe)
- ⚠️ Consommation vs Température (need temperature data)

### Economic
- ✅ Chiffre d'affaires (CA)
- ✅ Taux de recouvrement (payment rate)
- ✅ Marge (profitability)
- ✅ Rentabilité par bâtiment, région, client
- ✅ Classement clients les plus rentables

### Environmental
- ✅ Émissions totales CO₂
- ✅ Évolution des émissions dans le temps
- ✅ Classement bâtiments les plus polluants
- ✅ Taux de recyclage
- ✅ Ratio CO₂ / consommation

