#!/usr/bin/env python3
"""
Load environmental CSV files into fact_environmental_impact table.
This script reads the staging CSV and loads it directly into the fact table.
"""

import csv
import mysql.connector
from datetime import datetime
from pathlib import Path

# Database configuration
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '',
    'database': 'greencity_dm',
    'charset': 'utf8mb4'
}

# File paths
BASE_DIR = Path(__file__).parent.parent
CSV_FILE = BASE_DIR / 'data_sources' / 'csv' / 'env_reports_01_2025.csv'

def load_env_csv_to_fact(csv_file, connection):
    """Load environmental CSV file into fact_environmental_impact table."""
    if not csv_file.exists():
        print(f"Error: File not found: {csv_file}")
        return 0
    
    print(f"Loading {csv_file.name}...")
    
    cursor = connection.cursor()
    count = 0
    
    try:
        with open(csv_file, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            
            # Prepare insert statement
            insert_sql = """
                INSERT INTO fact_environmental_impact (
                    report_date_key, building_key, region_key,
                    emission_co2_kg, taux_recyclage, taux_recyclage_pct
                )
                SELECT 
                    dd.date_key,
                    db.building_key,
                    db.region_key,
                    %s AS emission_co2_kg,
                    %s AS taux_recyclage,
                    %s * 100 AS taux_recyclage_pct
                FROM greencity_dm.dim_date dd
                INNER JOIN greencity_dm.dim_building db ON %s = db.building_id
                LEFT JOIN greencity_dm.dim_region dr ON %s = dr.region_id
                WHERE DATE(%s) = dd.full_date
                LIMIT 1
            """
            
            # Actually, let's use a simpler approach with a lookup query first
            lookup_sql = """
                SELECT 
                    dd.date_key AS report_date_key,
                    db.building_key,
                    db.region_key,
                    %s AS emission_co2_kg,
                    %s AS taux_recyclage,
                    %s * 100 AS taux_recyclage_pct
                FROM greencity_dm.dim_date dd
                INNER JOIN greencity_dm.dim_building db ON %s = db.building_id
                LEFT JOIN greencity_dm.dim_region dr ON %s = dr.region_id
                WHERE DATE(%s) = dd.full_date
                LIMIT 1
            """
            
            # Better approach: use a single INSERT with subquery
            insert_sql = """
                INSERT INTO fact_environmental_impact (
                    report_date_key, building_key, region_key,
                    emission_co2_kg, taux_recyclage, taux_recyclage_pct
                )
                SELECT 
                    dd.date_key,
                    db.building_key,
                    db.region_key,
                    %s,
                    %s,
                    %s * 100
                FROM greencity_dm.dim_date dd
                INNER JOIN greencity_dm.dim_building db ON %s = db.building_id
                WHERE DATE(%s) = dd.full_date
            """
            
            rows_to_insert = []
            batch_size = 100
            
            for row in reader:
                region_id = row.get('id_region', '').strip()
                building_id = row.get('id_batiment', '').strip()
                date_str = row.get('date_rapport', '').strip()
                emission_str = row.get('emission_CO2_kg', '').strip()
                taux_str = row.get('taux_recyclage', '').strip()
                
                if not building_id or not date_str or not emission_str or not taux_str:
                    continue
                
                # Parse date
                try:
                    report_date = datetime.strptime(date_str.strip(), '%Y-%m-%d').date()
                except ValueError:
                    print(f"Warning: Could not parse date: {date_str}")
                    continue
                
                # Parse emissions
                try:
                    emission_co2 = float(emission_str)
                except ValueError:
                    print(f"Warning: Could not parse emission: {emission_str}")
                    continue
                
                # Parse recycling rate
                try:
                    taux_recyclage = float(taux_str)
                except ValueError:
                    print(f"Warning: Could not parse taux_recyclage: {taux_str}")
                    continue
                
                # Execute insert with dimension lookups
                try:
                    cursor.execute(insert_sql, (
                        emission_co2,
                        taux_recyclage,
                        taux_recyclage,
                        building_id,
                        report_date
                    ))
                    count += 1
                    if count % batch_size == 0:
                        connection.commit()
                except Exception as e:
                    print(f"Error inserting row {building_id}, {date_str}: {e}")
                    continue
            
            connection.commit()
            print(f"  Loaded {count} rows from {csv_file.name}")
            
    except Exception as e:
        connection.rollback()
        print(f"Error loading {csv_file}: {e}")
        import traceback
        traceback.print_exc()
        raise
    finally:
        cursor.close()
    
    return count

def main():
    """Main function to load environmental CSV file."""
    print("Connecting to MySQL database...")
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        print("Connected successfully!")
    except Exception as e:
        print(f"Error connecting to database: {e}")
        return
    
    try:
        # Load CSV file
        rows = load_env_csv_to_fact(CSV_FILE, connection)
        
        print(f"\nSuccessfully loaded {rows} rows into fact_environmental_impact table")
        
    except Exception as e:
        print(f"\nError: {e}")
        import traceback
        traceback.print_exc()
    finally:
        connection.close()
        print("\nDatabase connection closed.")

if __name__ == '__main__':
    main()


