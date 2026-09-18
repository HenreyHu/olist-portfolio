"""Download the Olist CSVs from Kaggle and load them into data/olist.duckdb.

Usage:  python scripts/setup_data.py
The dataset is public, so no Kaggle account or token is needed.
"""
from pathlib import Path
import re
import shutil
import tempfile
import urllib.request
import zipfile

import duckdb

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "raw"
DB = ROOT / "data" / "olist.duckdb"
LOAD_SQL = (ROOT / "sql" / "01_load_staging.sql").read_text(encoding="utf-8")
PAGE = "https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce"
URL = "https://www.kaggle.com/api/v1/datasets/download/olistbr/brazilian-ecommerce"

# The load script is the single list of CSVs we need.
missing = [f for f in re.findall(r"data/raw/([\w.]+\.csv)", LOAD_SQL) if not (RAW / f).exists()]
if missing:
    print(f"Downloading {len(missing)} missing CSV(s) from Kaggle...")
    try:
        with tempfile.TemporaryFile() as tmp:
            with urllib.request.urlopen(URL, timeout=60) as resp:
                shutil.copyfileobj(resp, tmp)
            with zipfile.ZipFile(tmp) as z:
                z.extractall(RAW, members=missing)
    except Exception as e:
        raise SystemExit(f"Download failed: {e}\nDownload the dataset from {PAGE} and unzip the CSVs into data/raw/.")

con = duckdb.connect(str(DB))
con.execute(f"SET file_search_path='{ROOT.as_posix()}'")
con.execute(LOAD_SQL)
for (t,) in con.execute("SELECT table_name FROM information_schema.tables ORDER BY 1").fetchall():
    print(f"{t:28} {con.execute(f'SELECT COUNT(*) FROM {t}').fetchone()[0]:>9,}")
