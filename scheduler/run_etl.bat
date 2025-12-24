@echo off
REM ========================================
REM GreenCity ETL Pipeline
REM Simple batch file to run the complete ETL process
REM ========================================

REM Set working directory to project root
cd /d "%~dp0.."
set PROJECT_ROOT=%CD%

echo ========================================
echo GreenCity ETL Pipeline - Starting
echo ========================================
echo.

REM Step 1: Load consumption data to temp table
echo [1/3] Loading consumption CSVs to temp_consumption...
python "%PROJECT_ROOT%\scripts\load_consumption_to_temp.py"
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Failed to load consumption data
    pause
    exit /b 1
)
echo.

REM Step 2: Load environmental data
echo [2/3] Loading environmental data...
python "%PROJECT_ROOT%\scripts\load_environmental_to_fact.py"
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Failed to load environmental data
    pause
    exit /b 1
)
echo.

REM Step 3: Run PDI job for fact table loads
echo [3/3] Running PDI job for fact table loads...
set PDI_PATH=C:\Users\earth\Desktop\s9\Pentaho\data-integration
if not exist "%PDI_PATH%\pan.bat" (
    echo.
    echo ERROR: PDI not found at %PDI_PATH%
    echo Please check the PDI_PATH in this batch file
    pause
    exit /b 1
)

call "%PDI_PATH%\pan.bat" /file:"%PROJECT_ROOT%\pdi_jobs\etl_full_pipeline.kjb" /level:Basic
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: PDI job failed
    pause
    exit /b 1
)
echo.

echo ========================================
echo ETL Pipeline - Completed Successfully!
echo ========================================
echo.
pause


