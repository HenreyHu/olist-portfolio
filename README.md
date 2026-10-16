# Olist E-commerce: Revenue vs Freight & Delivery Performance

I ranked Olist's product categories by revenue against what they cost to ship and how reliably they arrive, so finance and ops can decide which categories to promote, which to renegotiate shipping for, and which delivery problems to fix first.

## Answer

| 76% | R$3.3M at 20.5% | 48% |
|---|---|---|
| of revenue comes from the top 15 categories (R$10.1M of R$13.2M) | revenue in 4 big categories (bed/bath/table, sports & leisure, furniture & decor, housewares) that pay 20.5% of price in freight, against 13.7% for the 8 categories to promote | of all late orders fall in just 3 of 20 months (Nov 2017, Feb and Mar 2018) |

The top 15 categories make 76% of revenue. Seven of them carry freight above 16.6% of price (the top-15 median), putting R$4.3M of revenue at high freight cost. Late deliveries average 6.8% of orders and late orders score 2.27 stars against 4.29, but late % is 5–8% in every top-15 category and spikes by month instead, so the main levers are **freight terms in four categories** and **delivery capacity in the peak months**, not a category-by-category delivery fix. The one delivery exception is office furniture (20.5 days on average, others 11–13.6).

![Revenue vs freight % for the top 15 categories](charts/main_revenue_vs_freight.png)

Currency is Brazilian reais (R$). Period: orders placed Jan 2017 to Aug 2018, delivered orders only (96,203 orders).

## Recommendations

Full reasoning, next steps and missing data are in [docs/act.md](docs/act.md).

| # | Action | Owner | Size | Confidence |
|---|---|---|---|---|
| 1 | **Renegotiate freight terms** for bed/bath/table, sports & leisure, furniture & decor, housewares | Ops / seller management, with finance | R$3.30M revenue (33% of top 15), R$674K freight at 20.5% of price | Medium-low: no carrier cost data, and bulky goods have a physical freight floor |
| 2 | **Fix delivery:** add capacity or tighter seller promises before Nov and Feb–Mar peaks; investigate office furniture | Ops / logistics | 3,159 late orders in 3 months (48% of all late orders); office furniture R$267K, 20.5 days, 3.65 stars | Medium on timing, low on cause: Nov 2017 follows a volume jump, Feb–Mar 2018 do not |
| 3 | **Promote** the 8 low-freight categories, led by watches & gifts (8.4% freight) and health & beauty; hold promotion of garden tools and telephony until freight improves | Marketing / category management, with finance | R$5.72M revenue (57% of top 15) at 13.7% freight; held back: R$0.78M at 21.3% | Low-medium: freight % stands in for margin, true margin is unknown |

**Impact scenario (not a forecast).** If the four renegotiation categories' freight fell from 20.5% to the top-15 median of 16.6% on the same orders, freight would be about **R$127K lower** (about R$64K if only half the gap closed). Review-score effects are correlation, not proof of cause: score falls from 4.29 on time to 3.29, 2.11 and 1.70 as lateness grows (below), but late orders may differ in other ways too.

## Supporting question: does late delivery lower review scores?

Yes, they move together, but the gap is smaller than the headline. Late orders average 2.27 stars against 4.29. About 75% of late-order reviews were written *before* the delivery date (customers complaining while still waiting). Without them the gap is 3.52 against 4.29, about 0.8 stars rather than 2.0. Both numbers are reported.

![Monthly late % and average review score](charts/late_pct_and_reviews_by_month.png)

![Review score by days late](charts/review_by_days_late.png)

## Question and who it's for

Which product categories bring in the most revenue but lose the most to freight costs and late deliveries? Audience: finance and operations leadership at Olist, a marketplace operator. Stakeholder, hypotheses and framing are in [docs/ask.md](docs/ask.md).

## Method

1. Load the raw CSVs into staging tables (`sql/01_load_staging.sql`)
2. Clean the data and reconcile order totals against payments (`sql/02_cleaning.sql`)
3. Analyse categories (`sql/03a_views.sql`, `sql/03_analysis.sql`). Each top-15 category gets one action label from a written rule: slow delivery = Fix delivery; high freight and high revenue = Renegotiate freight; high freight and low revenue = Deprioritize; everything else = Promote. "High" means above the top-15 median (rule in `sql/03a_views.sql`)

Every number above traces to a query in `sql/03_analysis.sql` and a file in `results/` (`q1.csv` to `q9.csv`). Two derived tables, `q10_freight_scenario.csv` and `q11_peak_months.csv`, are arithmetic on those results made by `scripts/derive_scenarios.py`. Week 3 findings, query by query: [docs/findings.md](docs/findings.md).

## Data issues and the late-delivery decisions

Full log in `data_issues_log` (built by `sql/02_cleaning.sql`) and written up in [docs/data_issues.md](docs/data_issues.md). Highlights: 610 products with no category + 13 with an untranslated one were bucketed as `unknown`; 8 orders are marked `delivered` but have no delivery date and can't be scored for lateness; reconciling order totals against payments left only 24 orders (out of ~99k) genuinely unexplained after separating out rounding noise and installment interest.

Decisions that change the late-delivery numbers (written at the top of `sql/03_analysis.sql`):
- **Late** = delivered *date* after estimated *date*. The estimate is always midnight, so a timestamp comparison would count same-day deliveries as late.
- **Window**: orders purchased Jan 2017 to Aug 2018. Late 2016 (about 330 orders) and Sep–Oct 2018 (about 20, none delivered) distort growth and late %.
- **Scope**: `delivered` orders with a delivery date.
- **Grain**: lateness is per order, category is per item. An order counts once toward every category it contains, so category order counts slightly overlap.
- **Reviews** are averaged per order first, because some orders have more than one.
- **Dates**: the raw CSVs are day-first (`d/m/yyyy`), so `sql/01_load_staging.sql` reads the orders file with an explicit `timestampformat`. Tools that assume month-first (the pandas default) misread them and badly overstate late orders.

## Limitations
- The dataset has no cost of goods, so freight as a % of price is used in place of margin.
- "Late" is measured against Olist's own estimated delivery date, which is padded (median promise about 23 days, median actual about 10), so lateness measures broken promises, not slow shipping.
- Freight is the shipping charge on the order, not a carrier cost. There is no carrier cost per shipment, so the freight scenario shows what the numbers imply, not what Olist would save.
- Review scores and lateness are correlated, not shown to be cause and effect.

## Reproduce
```bash
pip install -r requirements.txt
python scripts/setup_data.py        # downloads the CSVs (no Kaggle token needed) and builds data/olist.duckdb
python scripts/profile.py           # writes docs/profiling.md
python scripts/run_analysis.py      # runs sql/03_analysis.sql, writes results/q*.csv
python scripts/derive_scenarios.py  # writes results/q10_freight_scenario.csv and q11_peak_months.csv
python scripts/make_charts.py       # writes charts/*.png
```
