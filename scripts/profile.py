"""Profile staging tables -> docs/profiling.md

Usage:  python scripts/profile.py
"""
from pathlib import Path
import duckdb

ROOT = Path(__file__).resolve().parents[1]
con = duckdb.connect(str(ROOT / "data" / "olist.duckdb"), read_only=True)

# (child table, child col, parent table, parent col)
FKS = [
    ("stg_orders", "customer_id", "stg_customers", "customer_id"),
    ("stg_order_items", "order_id", "stg_orders", "order_id"),
    ("stg_order_items", "product_id", "stg_products", "product_id"),
    ("stg_order_items", "seller_id", "stg_sellers", "seller_id"),
    ("stg_order_payments", "order_id", "stg_orders", "order_id"),
    ("stg_order_reviews", "order_id", "stg_orders", "order_id"),
    ("stg_products", "product_category_name", "stg_category_translation", "product_category_name"),
]
KEYS = {
    "stg_customers": "customer_id", "stg_orders": "order_id", "stg_products": "product_id",
    "stg_sellers": "seller_id", "stg_order_reviews": "review_id",
    "stg_order_items": "order_id, order_item_id", "stg_order_payments": "order_id, payment_sequential",
}

out = ["# Data profiling\n"]
tables = [r[0] for r in con.execute(
    "SELECT table_name FROM information_schema.tables WHERE table_name LIKE 'stg_%' ORDER BY 1").fetchall()]

for t in tables:
    n = con.execute(f"SELECT COUNT(*) FROM {t}").fetchone()[0]
    out.append(f"## {t}\n\n- Rows: **{n:,}**")
    if t in KEYS:
        k = KEYS[t]
        dup = con.execute(f"SELECT COUNT(*) FROM (SELECT {k} FROM {t} GROUP BY {k} HAVING COUNT(*) > 1)").fetchone()[0]
        out.append(f"- Duplicate keys on ({k}): **{dup:,}**")
    out.append("\n| column | type | nulls | null % | distinct | min | max |\n|---|---|---:|---:|---:|---|---|")
    for col, typ in con.execute(
        "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = ? ORDER BY ordinal_position", [t]
    ).fetchall():
        nulls, distinct, mn, mx = con.execute(
            f'SELECT COUNT(*) - COUNT("{col}"), COUNT(DISTINCT "{col}"), MIN("{col}"), MAX("{col}") FROM {t}'
        ).fetchone()
        pct = 100 * nulls / n if n else 0
        show = any(s in typ for s in ("DATE", "TIME", "INT", "DOUBLE", "DECIMAL", "FLOAT"))
        out.append(f"| {col} | {typ} | {nulls:,} | {pct:.1f} | {distinct:,} | "
                   f"{mn if show else ''} | {mx if show else ''} |")
    out.append("")

out.append("## Orphan foreign keys\n\n| child | parent | orphan rows |\n|---|---|---:|")
for ct, cc, pt, pc in FKS:
    if ct in tables and pt in tables:
        o = con.execute(
            f"SELECT COUNT(*) FROM {ct} c LEFT JOIN {pt} p ON c.{cc} = p.{pc} "
            f"WHERE c.{cc} IS NOT NULL AND p.{pc} IS NULL").fetchone()[0]
        out.append(f"| {ct}.{cc} | {pt}.{pc} | {o:,} |")

(ROOT / "docs" / "profiling.md").write_text("\n".join(out) + "\n", encoding="utf-8")
print("wrote docs/profiling.md")
