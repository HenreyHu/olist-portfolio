"""Download Olist CSVs (Kaggle) and load them into data/olist.duckdb.

Usage:  python scripts/setup_data.py
Needs:  Kaggle token at ~/.kaggle/kaggle.json  (or put the 9 CSVs in data/raw/ yourself)
"""
from pathlib import Path
import duckdb

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "raw"
DB = ROOT / "data" / "olist.duckdb"

if not list(RAW.glob("*.csv")):
    import kaggle  # imported here so manual-download users don't need a token
    kaggle.api.authenticate()
    kaggle.api.dataset_download_files("olistbr/brazilian-ecommerce", path=RAW, unzip=True)

con = duckdb.connect(str(DB))
con.execute(f"SET file_search_path='{ROOT.as_posix()}'")
con.execute((ROOT / "sql" / "01_load_staging.sql").read_text())
for (t,) in con.execute("SELECT table_name FROM information_schema.tables ORDER BY 1").fetchall():
    print(f"{t:28} {con.execute(f'SELECT COUNT(*) FROM {t}').fetchone()[0]:>9,}")
