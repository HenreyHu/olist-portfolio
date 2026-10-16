"""Week 4: derived numbers for the Act section. Reads results/q5, q7, q8 and writes two small CSVs.
No new SQL: both tables are arithmetic on columns already produced by sql/03_analysis.sql (Q5, Q7, Q8)."""
from pathlib import Path
import pandas as pd

ROOT = Path(__file__).resolve().parent.parent
R = ROOT / "results"

# 1. Freight scenario: bring each high-freight category down to the top-15 median freight %, same orders.
q7 = pd.read_csv(R / "q7.csv")
med = q7["freight_pct"].median()
q7["gap_pts"] = (q7["freight_pct"] - med).clip(lower=0)
q7["freight_now"] = q7["revenue"] * q7["freight_pct"] / 100
q7["saving_full"] = q7["revenue"] * q7["gap_pts"] / 100      # freight % falls to the median
q7["saving_half"] = q7["saving_full"] / 2                    # half the gap closed
cols = ["category", "action", "revenue", "freight_pct", "gap_pts", "freight_now", "saving_half", "saving_full"]
out = q7[q7["gap_pts"] > 0][cols].sort_values("saving_full", ascending=False).round(1)
out.to_csv(R / "q10_freight_scenario.csv", index=False)
print("median freight % of top 15:", med)
print(out.to_string(index=False))
reneg = q7[q7["action"] == "Renegotiate freight"]
print("Renegotiate group: saving full %.0f  half %.0f" % (reneg["saving_full"].sum(), reneg["saving_half"].sum()))
print("All above-median: saving full %.0f  half %.0f" % (q7["saving_full"].sum(), q7["saving_half"].sum()))
hi = q7[q7["gap_pts"] > 0]
print("Above-median categories: n=%d revenue=%.0f" % (len(hi), hi["revenue"].sum()))
print("Top-15 revenue %.0f" % q7["revenue"].sum())

# 2. Peak months: how many late orders sit in the spike months, and the excess over a normal month.
q5 = pd.read_csv(R / "q5.csv", parse_dates=["month"])
q5["late_orders"] = q5["orders"] * q5["late_pct"] / 100
spike = q5["month"].isin(pd.to_datetime(["2017-11-01", "2018-02-01", "2018-03-01"]))
base = q5.loc[~spike, "late_pct"].median()
q5["excess_late_orders"] = (q5["orders"] * (q5["late_pct"] - base) / 100).clip(lower=0).where(spike, 0)
q5["spike_month"] = spike
q5.round({"late_orders": 1, "excess_late_orders": 1}).to_csv(R / "q11_peak_months.csv", index=False)
print("baseline late %% (median of other 17 months): %.1f" % base)
print("total orders %d, late orders %.0f, overall late %% %.2f" % (q5["orders"].sum(), q5["late_orders"].sum(),
      100 * q5["late_orders"].sum() / q5["orders"].sum()))
print("spike months: orders %d late %.0f (%.0f%% of all late) excess %.0f" % (
    q5.loc[spike, "orders"].sum(), q5.loc[spike, "late_orders"].sum(),
    100 * q5.loc[spike, "late_orders"].sum() / q5["late_orders"].sum(), q5["excess_late_orders"].sum()))
