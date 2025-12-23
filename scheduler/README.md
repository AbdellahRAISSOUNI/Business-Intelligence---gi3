# ETL Scheduler

## Simple Usage

**To run the ETL manually:**
- Double-click `run_etl.bat`
- You'll see all output and it pauses at the end

**To schedule it in Windows Task Scheduler:**

1. Open Task Scheduler (`Windows + R`, type `taskschd.msc`)
2. Click "Create Basic Task"
3. Name: `GreenCity ETL Daily Pipeline`
4. Trigger: Daily at 02:00
5. Action: Start a program
   - Program: `C:\Users\earth\Desktop\s9\bi\Business Intelligence - Mini Projet\scheduler\run_etl.bat`
   - Start in: `C:\Users\earth\Desktop\s9\bi\Business Intelligence - Mini Projet`
6. Check "Run whether user is logged on or not" and "Run with highest privileges"

**To enable/disable the scheduled task:**
- Open Task Scheduler
- Find "GreenCity ETL Daily Pipeline"
- Right-click → Enable or Disable

That's it! One simple batch file.
