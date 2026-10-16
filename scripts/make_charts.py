"""Week 4: build the three README charts from results/*.csv. Run: python scripts/make_charts.py"""
from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
from matplotlib.lines import Line2D

ROOT = Path(__file__).resolve().parent.parent
R, OUT = ROOT / "results", ROOT / "charts"
OUT.mkdir(exist_ok=True)

BG, INK, INK2, GRID = "#fcfcfb", "#0b0b0b", "#52514e", "#e6e5e1"
BLUE, ORANGE, AQUA, GRAY = "#2a78d6", "#eb6834", "#1baf7a", "#a9a8a3"
plt.rcParams.update({
    "font.family": ["Inter", "DejaVu Sans"], "figure.facecolor": BG, "axes.facecolor": BG,
    "axes.edgecolor": GRID, "axes.labelcolor": INK2, "xtick.color": INK2, "ytick.color": INK2,
    "axes.spines.top": False, "axes.spines.right": False, "savefig.facecolor": BG,
})
LABELS = {"office_furniture": "Office furniture", "furniture_decor": "Furniture & decor", "housewares": "Housewares",
          "bed_bath_table": "Bed / bath / table", "watches_gifts": "Watches & gifts"}


# ---------- Main chart: revenue vs freight % ----------
q7 = pd.read_csv(R / "q7.csv")
colors = {"Promote": BLUE, "Renegotiate freight": ORANGE, "Fix delivery": AQUA, "Deprioritize": GRAY}
fig, ax = plt.subplots(figsize=(10, 6.6), dpi=200)
med_f, med_r = q7["freight_pct"].median(), q7["revenue"].median() / 1000
ax.axhline(med_f, color=GRID, lw=1.2, ls="--", zorder=0)
ax.axvline(med_r, color=GRID, lw=1.2, ls="--", zorder=0)
ax.text(1290, med_f + 0.35, f"median freight {med_f:.1f}%", ha="right", color=INK2, fontsize=8.5)
ax.text(med_r + 12, 27.0, f"median revenue R${med_r:,.0f}K", color=INK2, fontsize=8.5)
for a, g in q7.groupby("action"):
    ax.scatter(g["revenue"] / 1000, g["freight_pct"], s=g["avg_delivery_days"] * 22, c=colors[a], alpha=0.9,
               edgecolor=BG, linewidth=1.5, zorder=3)
offs = {"office_furniture": (16, 2), "furniture_decor": (14, 12), "housewares": (16, -24),
        "bed_bath_table": (18, 8), "watches_gifts": (-16, 0)}
ha = {"watches_gifts": "right"}
for _, r in q7[q7["category"].isin(LABELS)].iterrows():
    ax.annotate(f"{LABELS[r.category]}\nR${r.revenue/1e6:.2f}M · {r.freight_pct:.1f}% freight · {r.avg_delivery_days:.1f} days",
                (r.revenue / 1000, r.freight_pct), xytext=offs[r.category], textcoords="offset points",
                fontsize=8.8, color=INK, ha=ha.get(r.category, "left"), va="center", linespacing=1.35,
                arrowprops=dict(arrowstyle="-", color=INK2, lw=0.7, shrinkA=0, shrinkB=9))
ax.set_xlim(0, 1300)
ax.set_ylim(5, 28)
ax.set_xlabel("Revenue, Jan 2017 – Aug 2018 (R$ thousands)")
ax.set_ylabel("Freight as % of item price")
ax.grid(color=GRID, lw=0.6, zorder=0)
ax.set_axisbelow(True)
leg = [Line2D([], [], marker="o", ls="", color=colors[k], markersize=9, label=f"{k} ({(q7.action == k).sum()})")
       for k in ["Promote", "Renegotiate freight", "Fix delivery", "Deprioritize"]]
leg += [Line2D([], [], marker="o", ls="", mfc="none", mec=INK2, markersize=(d * 22) ** 0.5, label=lab)
        for d, lab in ((11, "11 days (bubble size)"), (20, "20 days"))]
ax.legend(handles=leg, loc="upper center", bbox_to_anchor=(0.5, -0.12), frameon=False, fontsize=9,
          labelcolor=INK2, ncol=6, columnspacing=1.5, handletextpad=0.8)
fig.suptitle("Seven of the top 15 ship at above-median freight, holding R$4.3M of revenue", x=0.07, y=0.99, ha="left",
             fontsize=14.5, fontweight="bold", color=INK)
fig.text(0.07, 0.935, "Top 15 categories by revenue (76% of total). Late % is 5–8% in every one, so bubble size shows delivery days instead.",
         fontsize=9.5, color=INK2, ha="left")
fig.tight_layout(rect=(0, 0, 1, 0.93))
fig.subplots_adjust(top=0.895, bottom=0.17)
fig.savefig(OUT / "main_revenue_vs_freight.png")
plt.close(fig)

# ---------- Supporting chart 1: monthly late % and review score (two panels, no dual axis) ----------
q5 = pd.read_csv(R / "q5.csv", parse_dates=["month"])
spike = q5["month"].isin(pd.to_datetime(["2017-11-01", "2018-02-01", "2018-03-01"]))
fig, (a1, a2) = plt.subplots(2, 1, figsize=(10, 6.4), dpi=200, sharex=True, gridspec_kw={"height_ratios": [1.15, 1]})
a1.bar(q5["month"], q5["late_pct"], width=21, color=[ORANGE if s else BLUE for s in spike])
for _, r in q5[spike].iterrows():
    a1.annotate(f"{r.late_pct:.1f}%", (r.month, r.late_pct), xytext=(0, 4), textcoords="offset points",
                ha="center", fontsize=9, color=INK)
a1.set_ylabel("Late orders (% of delivered)")
a1.set_ylim(0, 22)
a1.set_yticks([0, 5, 10, 15, 20])
a2.plot(q5["month"], q5["avg_review"], color=BLUE, lw=2)
a2.scatter(q5["month"], q5["avg_review"], s=[55 if s else 25 for s in spike], c=[ORANGE if s else BLUE for s in spike],
           edgecolor=BG, linewidth=1.5, zorder=3)
for _, r in q5[spike].iterrows():
    a2.annotate(f"{r.avg_review:.2f}", (r.month, r.avg_review), xytext=(0, -15), textcoords="offset points",
                ha="center", fontsize=9, color=INK)
a2.set_ylabel("Average review score (1–5)")
a2.set_ylim(3.6, 4.5)
a2.xaxis.set_major_locator(mdates.MonthLocator(bymonth=[1, 4, 7, 10]))
a2.xaxis.set_major_formatter(mdates.DateFormatter("%b %Y"))
for a in (a1, a2):
    a.grid(axis="y", color=GRID, lw=0.6)
    a.set_axisbelow(True)
fig.suptitle("Lateness comes in waves: Nov 2017, Feb and Mar 2018", x=0.07, y=0.99, ha="left", fontsize=14.5,
             fontweight="bold", color=INK)
fig.text(0.07, 0.935, "Those 3 of 20 months hold 48% of all late orders, and review scores dip in the same months. Orange = spike months.",
         fontsize=9.5, color=INK2, ha="left")
fig.tight_layout(rect=(0, 0, 1, 0.93))
fig.savefig(OUT / "late_pct_and_reviews_by_month.png")
plt.close(fig)

# ---------- Supporting chart 2: review score by days-late bucket ----------
q6 = pd.read_csv(R / "q6.csv")
q9 = pd.read_csv(R / "q9.csv")
x9 = q9[q9.slice == "excluding early reviews"].set_index("delivery")["avg_review"]
fig, ax = plt.subplots(figsize=(10, 5.8), dpi=200)
cols = [BLUE, ORANGE, ORANGE, ORANGE]
xs = range(len(q6))
ax.bar(xs, q6["avg_review"], width=0.58, color=cols)
for i, r in q6.iterrows():
    ax.text(i, r.avg_review + 0.07, f"{r.avg_review:.2f}", ha="center", fontsize=11, fontweight="bold", color=INK)
ax.set_xticks(list(xs))
ax.set_xticklabels([f"{b}\nn = {n:,}" for b, n in zip(q6["days_late_bucket"], q6["reviewed_orders"])], color=INK2)
ax.set_ylim(0, 5)
ax.set_ylabel("Average review score (1–5)")
ax.set_xlabel("Days delivered after the estimated date")
ax.grid(axis="y", color=GRID, lw=0.6)
ax.set_axisbelow(True)
fig.suptitle("The later the order, the lower the review", x=0.07, y=0.99, ha="left", fontsize=14.5,
             fontweight="bold", color=INK)
fig.text(0.07, 0.935, "Correlation, not proof of cause. Late orders may also differ in other ways (size, seller, region).",
         fontsize=9.5, color=INK2, ha="left")
fig.text(0.07, 0.015,
         f"Caveat (Q9): 75% of late-order reviews were written before the delivery date. Without them, late orders average "
         f"{x9['late']:.2f} vs {x9['on_time']:.2f} on time,\na gap of about 0.8 stars rather than 2.0. The buckets above include those early reviews.",
         fontsize=9, color=INK2, ha="left", va="bottom", linespacing=1.4)
fig.tight_layout(rect=(0, 0.08, 1, 0.93))
fig.subplots_adjust(top=0.895)
fig.savefig(OUT / "review_by_days_late.png")
plt.close(fig)
print("saved:", *[p.name for p in sorted(OUT.glob("*.png"))])
