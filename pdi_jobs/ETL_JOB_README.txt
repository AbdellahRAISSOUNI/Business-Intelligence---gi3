ETL Full Pipeline Job - Usage Instructions
==========================================

This PDI job (etl_full_pipeline.kjb) orchestrates the loading of all 3 Data Marts.

IMPORTANT: Before running this job, you must:
1. Run: python scripts\load_consumption_to_temp.py
   (Loads consumption CSVs into temp_consumption table)

2. Run: python scripts\load_environmental_to_fact.py  
   (Loads environmental CSV into fact_environmental_impact)

Then the PDI job will:
- Load fact_energy_consumption from temp_consumption
- Load fact_economic_profitability from operational DB
- Show summary of all loaded data

To run in Spoon:
1. Open Spoon
2. File > Open > Select "pdi_jobs/etl_full_pipeline.kjb"
3. Click Run button

To schedule with Windows Task Scheduler:
1. Create a batch file that runs the Python scripts first, then calls the PDI job
2. Use pan.bat (command-line PDI) to run the job
3. Schedule the batch file to run daily at 02:00

Example command for pan.bat:
"C:\pentaho\data-integration\pan.bat" /file:"pdi_jobs\etl_full_pipeline.kjb" /level:Basic


