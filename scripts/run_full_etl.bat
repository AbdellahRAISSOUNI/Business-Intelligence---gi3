@echo off
REM Full ETL Pipeline Runner
REM This batch file runs the complete ETL process including Python scripts and PDI job

echo ========================================
echo GreenCity ETL Pipeline - Starting
echo ========================================
echo.

REM Step 1: Load consumption data to temp table
echo [1/3] Loading consumption CSVs to temp_consumption...
python scripts\load_consumption_to_temp.py
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to load consumption data
    pause
    exit /b 1
)
echo.

REM Step 2: Load environmental data
echo [2/3] Loading environmental data...
python scripts\load_environmental_to_fact.py
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to load environmental data
    pause
    exit /b 1
)
echo.

REM Step 3: Run PDI job (consumption fact, economic fact)
REM Note: Replace path to pan.bat with your actual PDI installation path
REM Example: C:\pentaho\data-integration\pan.bat
echo [3/3] Running PDI job for fact table loads...
echo NOTE: You need to configure the path to pan.bat below
REM "C:\pentaho\data-integration\pan.bat" /file:"pdi_jobs\etl_full_pipeline.kjb" /level:Basic
echo.
echo To run PDI job manually:
echo   1. Open Spoon
echo   2. Open pdi_jobs\etl_full_pipeline.kjb
echo   3. Click Run
echo.

echo ========================================
echo ETL Pipeline - Complete
echo ========================================
pause

