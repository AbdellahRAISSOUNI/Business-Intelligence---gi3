"""
Generate synthetic data for the BI mini-project without external services.

Outputs:
- data_sources/json/* consumption JSON (electricity, eau, gaz)
- data_sources/csv/env_reports_*.csv environmental KPI
- data_sources/csv/operational_seed/*.csv core tables (regions, clients, buildings, meters, invoices, invoice_lines, payments)

Usage:
  python scripts/generate_mock_data.py

You can adjust COUNTS and DATES ranges below as needed.
"""

from __future__ import annotations

import csv
import json
import random
import string
from dataclasses import dataclass
from datetime import datetime, timedelta, date
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_JSON = BASE_DIR / "data_sources" / "json"
DATA_CSV = BASE_DIR / "data_sources" / "csv"
OP_SEED = DATA_CSV / "operational_seed"

random.seed(42)


# ------------ Helpers ------------
def rand_id(prefix: str, width: int = 3) -> str:
    return f"{prefix}{random.randint(0, 10**width - 1):0{width}d}"


def rand_phone() -> str:
    return f"+2126{random.randint(10000000, 99999999)}"


def rand_email(name: str) -> str:
    clean = "".join(ch for ch in name.lower() if ch in string.ascii_lowercase)
    return f"{clean}@example.com"


def daterange(start: date, periods: int, step_days: int = 1):
    current = start
    for _ in range(periods):
        yield current
        current += timedelta(days=step_days)


# ------------ Seed entities ------------
def seed_regions(n: int = 3):
    regions = []
    for i in range(n):
        regions.append({
            "region_id": f"REG{i+1:02d}",
            "region_name": f"Region-{i+1}"
        })
    return regions


def seed_clients(n: int = 5):
    clients = []
    for i in range(n):
        name = f"Client-{i+1}"
        clients.append({
            "client_id": f"CLI{i+1:02d}",
            "client_name": name,
            "contact_email": rand_email(name),
            "contact_phone": rand_phone(),
            "billing_address": f"{random.randint(10,199)} Avenue BI, City {i+1}"
        })
    return clients


def seed_buildings(clients, regions, per_client: int = 2):
    buildings = []
    b_id = 1
    for client in clients:
        for _ in range(per_client):
            region = random.choice(regions)
            buildings.append({
                "building_id": f"BAT{b_id:03d}",
                "client_id": client["client_id"],
                "region_id": region["region_id"],
                "building_name": f"{client['client_name']} Site {b_id}",
                "building_type": random.choice(["office", "residential", "warehouse"]),
                "surface_m2": round(random.uniform(800, 5000), 2)
            })
            b_id += 1
    return buildings


def seed_meters(buildings):
    meters = []
    meter_id = 1
    for b in buildings:
        for energy_type, unit in [("electricite", "KWh"), ("eau", "m3"), ("gaz", "m3")]:
            meters.append({
                "meter_id": f"MTR{meter_id:04d}",
                "building_id": b["building_id"],
                "energy_type": energy_type,
                "unit": unit,
                "installed_at": (date(2024,1,1) + timedelta(days=random.randint(0,200))).isoformat()
            })
            meter_id += 1
    return meters


# ------------ Operational data ------------
def generate_invoices(buildings, meters, start_date: date, months: int = 3):
    invoices = []
    invoice_lines = []
    payments = []
    invoice_num = 1
    pay_num = 1
    for b in buildings:
        for m in range(months):
            inv_date = (start_date + timedelta(days=30*m)).replace(day=5)
            total_ht = round(random.uniform(800, 4000), 2)
            energy_cost = round(total_ht * random.uniform(0.4, 0.7), 2)
            total_ttc = round(total_ht * 1.2, 2)
            inv_id = f"INV{invoice_num:05d}"
            invoices.append({
                "invoice_id": inv_id,
                "client_id": b["client_id"],
                "building_id": b["building_id"],
                "invoice_date": inv_date.isoformat(),
                "due_date": (inv_date + timedelta(days=20)).isoformat(),
                "total_ht": total_ht,
                "total_ttc": total_ttc,
                "energy_cost": energy_cost,
                "status": random.choice(["sent","paid","paid","overdue"])
            })
            # create 3 lines (one per energy)
            meter_lookup = {m["energy_type"]: m["meter_id"] for m in meters if m["building_id"] == b["building_id"]}
            for energy_type, unit in [("electricite","KWh"),("eau","m3"),("gaz","m3")]:
                qty = round(random.uniform(400, 2200 if energy_type=="electricite" else 500), 3)
                unit_price = round(random.uniform(0.05, 0.25), 4)
                line_ht = round(qty * unit_price, 2)
                line_ttc = round(line_ht * 1.2, 2)
                invoice_lines.append({
                    "invoice_id": inv_id,
                    "meter_id": meter_lookup.get(energy_type),
                    "energy_type": energy_type,
                    "period_start": inv_date.replace(day=1).isoformat(),
                    "period_end": (inv_date.replace(day=1) + timedelta(days=29)).isoformat(),
                    "consumption_qty": qty,
                    "unit_price": unit_price,
                    "line_ht": line_ht,
                    "line_ttc": line_ttc
                })
            # payment (maybe partial)
            paid = round(total_ttc * random.choice([0.6, 1.0]), 2)
            payments.append({
                "payment_id": f"PAY{pay_num:05d}",
                "invoice_id": inv_id,
                "payment_date": (inv_date + timedelta(days=random.randint(5,25))).isoformat(),
                "amount_paid": paid,
                "method": random.choice(["transfer","card","cash"])
            })
            invoice_num += 1
            pay_num += 1
    return invoices, invoice_lines, payments


# ------------ Sensor JSON + Env CSV ------------
def generate_consumption_json(regions, buildings, meters, start_date: date, days: int = 3):
    DATA_JSON.mkdir(parents=True, exist_ok=True)
    for energy_type in ["electricite","eau","gaz"]:
        payload = {"id_region": regions[0]["region_id"], "batiments": []}
        for b in buildings[:4]:  # keep files small
            measures = []
            for d in daterange(start_date, days):
                for hour in [8,9,10,11,12]:
                    qty = {
                        "electricite": round(random.uniform(80, 160), 1),
                        "eau": round(random.uniform(1.0, 3.5), 2),
                        "gaz": round(random.uniform(3.0, 6.0), 2),
                    }[energy_type]
                    measures.append({
                        "compteur_id": next(m["meter_id"] for m in meters if m["building_id"]==b["building_id"] and m["energy_type"]==energy_type),
                        "date_mesure": datetime(d.year, d.month, d.day, hour).isoformat(),
                        f"consommation_{'kWh' if energy_type=='electricite' else 'm3'}": qty
                    })
            payload["batiments"].append({
                "id_batiment": b["building_id"],
                "type_energie": energy_type,
                "unite": "KWh" if energy_type=="electricite" else "m3",
                "date_generation": start_date.isoformat(),
                "mesures": measures
            })
        fname = DATA_JSON / f"{energy_type.capitalize()}_consumption_{start_date.strftime('%m_%Y')}.json"
        with open(fname, "w", encoding="utf-8") as f:
            json.dump(payload, f, indent=2)


def generate_env_csv(buildings, start_date: date, months: int = 3):
    DATA_CSV.mkdir(parents=True, exist_ok=True)
    rows = []
    for m in range(months):
        dt = (start_date + timedelta(days=30*m)).replace(day=28)
        for b in buildings:
            rows.append({
                "id_region": b["region_id"],
                "id_batiment": b["building_id"],
                "date_rapport": dt.isoformat(),
                "emission_CO2_kg": round(random.uniform(300, 900), 2),
                "taux_recyclage": round(random.uniform(0.5, 0.9), 2)
            })
    fname = DATA_CSV / f"env_reports_{start_date.strftime('%m_%Y')}.csv"
    with open(fname, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)


# ------------ Write CSV helpers ------------
def write_csv(path: Path, rows, fieldnames):
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def main():
    regions = seed_regions()
    clients = seed_clients()
    buildings = seed_buildings(clients, regions)
    meters = seed_meters(buildings)
    invoices, invoice_lines, payments = generate_invoices(buildings, meters, date(2025,1,1))

    # Write operational seed CSVs
    write_csv(OP_SEED / "regions.csv", regions, regions[0].keys())
    write_csv(OP_SEED / "clients.csv", clients, clients[0].keys())
    write_csv(OP_SEED / "buildings.csv", buildings, buildings[0].keys())
    write_csv(OP_SEED / "meters.csv", meters, meters[0].keys())
    write_csv(OP_SEED / "invoices.csv", invoices, invoices[0].keys())
    write_csv(OP_SEED / "invoice_lines.csv", invoice_lines, invoice_lines[0].keys())
    write_csv(OP_SEED / "payments.csv", payments, payments[0].keys())

    # Sensor JSON + environmental CSV
    generate_consumption_json(regions, buildings, meters, date(2025,1,14))
    generate_env_csv(buildings, date(2025,1,1))

    print("Data generated in data_sources/json and data_sources/csv (operational_seed).")


if __name__ == "__main__":
    main()

