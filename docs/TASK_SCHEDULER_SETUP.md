# Windows Task Scheduler Setup - ETL Automation

## Simple Setup

1. **Open Task Scheduler** (`Windows + R`, type `taskschd.msc`)

2. **Create Basic Task**
   - Name: `GreenCity ETL Daily Pipeline`
   - Description: `Runs ETL pipeline daily at 02:00`

3. **Set Trigger**
   - Daily at 02:00

4. **Set Action**
   - Start a program
   - Program: `C:\Users\earth\Desktop\s9\bi\Business Intelligence - Mini Projet\scheduler\run_etl.bat`
   - Start in: `C:\Users\earth\Desktop\s9\bi\Business Intelligence - Mini Projet`

5. **Configure**
   - Check "Run whether user is logged on or not"
   - Check "Run with highest privileges"

Done! The task will run daily at 02:00.

## Control the Task

- **Enable/Disable**: Right-click task → Enable or Disable
- **Run Now**: Right-click task → Run
- **Delete**: Right-click task → Delete

## Testing

Double-click `scheduler\run_etl.bat` to test manually - it shows all output and pauses at the end.

