#!/usr/bin/env python3
"""
Load consumption CSV files into temp_consumption table.
This script reads the staging CSVs and loads them into MySQL temp_consumption table.
Run this before executing the fact table load SQL.
"""

import re
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
STAGING_DIR = BASE_DIR / 'staging'

CSV_FILES = [
    ('consumption_electricite.csv', 'electricite'),
    ('consumption_eau.csv', 'eau'),
    ('consumption_gaz.csv', 'gaz'),
]

def parse_line(line):
    """Parse a line in format: MTR00012025-01-14T08:00:00146.7
    Returns: (compteur_id, date_str, consommation_str) or None if invalid
    """
    line = line.strip()
    if not line:
        return None
    
    # Pattern: MTR followed by digits, then date (YYYY-MM-DDTHH:MM:SS), then number
    # Example: MTR00012025-01-14T08:00:00146.7
    pattern = r'^(MTR\d+)(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})([\d.]+)$'
    match = re.match(pattern, line)
    
    if match:
        compteur_id = match.group(1)
        date_str = match.group(2)
        consommation_str = match.group(3)
        return (compteur_id, date_str, consommation_str)
    
    return None

def parse_date(date_str):
    """Parse date string in format yyyy-MM-ddTHH:mm:ss to datetime."""
    try:
        return datetime.strptime(date_str.strip(), '%Y-%m-%dT%H:%M:%S')
    except ValueError:
        print(f"Warning: Could not parse date: {date_str}")
        return None

def load_csv_to_temp(csv_file, energy_type, connection):
    """Load a CSV file into temp_consumption table."""
    csv_path = STAGING_DIR / csv_file
    
    if not csv_path.exists():
        print(f"Warning: File not found: {csv_path}")
        return 0
    
    print(f"Loading {csv_file} (energy_type: {energy_type})...")
    
    cursor = connection.cursor()
    count = 0
    
    try:
        with open(csv_path, 'r', encoding='utf-8') as f:
            # Prepare insert statement
            insert_sql = """
                INSERT INTO temp_consumption (compteur_id, date_mesure, consommation, energy_type)
                VALUES (%s, %s, %s, %s)
            """
            
            rows_to_insert = []
            batch_size = 1000
            
            for line_num, line in enumerate(f, 1):
                # Parse the line (fixed-width format, no commas)
                parsed = parse_line(line)
                if parsed is None:
                    # Skip header or invalid lines
                    continue
                
                compteur_id, date_str, consommation_str = parsed
                
                # Parse date
                date_obj = parse_date(date_str)
                if date_obj is None:
                    continue
                
                # Parse consumption
                try:
                    consommation = float(consommation_str)
                except ValueError:
                    print(f"Warning: Could not parse consommation: {consommation_str} on line {line_num}")
                    continue
                
                rows_to_insert.append((compteur_id, date_obj, consommation, energy_type))
                
                # Batch insert
                if len(rows_to_insert) >= batch_size:
                    cursor.executemany(insert_sql, rows_to_insert)
                    count += len(rows_to_insert)
                    rows_to_insert = []
            
            # Insert remaining rows
            if rows_to_insert:
                cursor.executemany(insert_sql, rows_to_insert)
                count += len(rows_to_insert)
            
            connection.commit()
            print(f"  Loaded {count} rows from {csv_file}")
            
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
    """Main function to load all CSV files."""
    print("Connecting to MySQL database...")
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        print("Connected successfully!")
    except Exception as e:
        print(f"Error connecting to database: {e}")
        return
    
    try:
        # Truncate temp table
        print("\nTruncating temp_consumption table...")
        cursor = connection.cursor()
        cursor.execute("TRUNCATE TABLE temp_consumption")
        connection.commit()
        cursor.close()
        print("Temp table cleared.")
        
        # Load each CSV file
        total_rows = 0
        for csv_file, energy_type in CSV_FILES:
            rows = load_csv_to_temp(csv_file, energy_type, connection)
            total_rows += rows
        
        print(f"\nSuccessfully loaded {total_rows} total rows into temp_consumption table")
        print("\nNext step: Run the SQL script or PDI transformation to load from temp_consumption into fact_energy_consumption")
        
    except Exception as e:
        print(f"\nError: {e}")
        import traceback
        traceback.print_exc()
    finally:
        connection.close()
        print("\nDatabase connection closed.")

if __name__ == '__main__':
    main()
