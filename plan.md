# Portfolio Project Plan: Olist E-commerce Analysis (4 weeks)

**Time budget:** ~8–10 hrs/week
**Stack:** DuckDB · Git/GitHub · Python (pandas + matplotlib) or Tableau Public
**Dataset:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (9 CSVs, ~100k orders, 2016–2018)

**Legend:** 🤖 = Claude can automate this · ✍️ = do it yourself (interviewers will ask about it)

---

## Project statement (read this first)

**Who it's for:** finance and operations leadership at Olist, a marketplace operator.

**The decision they face:** which product categories to promote, which to renegotiate shipping costs for, which delivery problems to fix, and which to deprioritize.

**The problem:** ranking categories by revenue hides what they cost to deliver. A top-revenue category can give back 20%+ of its price in freight, and late deliveries pull review scores down.

**What this project hands them:** a category priority list. The top ~15 categories (about 75% of revenue) each get one action label (Promote / Renegotiate freight / Fix delivery / Deprioritize), with an estimate of how much revenue sits behind each label.

**One-sentence version (paste as line 1 of the README):**
> I ranked Olist's product categories by revenue against what they cost to ship and how reliably they arrive, so finance and ops can decide which categories to promote, which to renegotiate shipping for, and which delivery problems to fix first.

**Main question:** Which product categories bring in the most revenue but lose the most to freight costs and late deliveries?

**Supporting question:** Does late delivery lower review scores?

**Stated limitations (must appear in the README):**
- No cost of goods in the dataset, so freight as a % of price stands in for margin.
- "Late" is measured against Olist's own estimated delivery date, which is padded (median promise about 23 days vs about 10 days actual), so lateness is a measure of broken promises, not of slow shipping.

---

## Where you are: Ask → Act

| Step | Status | Where |
|---|---|---|
| Ask | Done | `docs/ask.md` (stakeholder, question, hypotheses) |
| Prepare | Done | `docs/profiling.md`, `docs/erd.md`, `docs/data_dictionary.md` |
| Process | Done, with loose ends | `sql/02_cleaning.sql`, `docs/data_issues.md` (loose ends are Week 3A below) |
| **Analyze** | **Week 3** | `sql/03_analysis.sql` |
| **Share** | **Week 4, first half** | charts + README (answer first) |
| **Act** | **Week 4, second half** | 3 recommendations, impact estimate, next steps |

Analyze, Share and Act are what an employer actually sees, so they get the most time from here on.

---

## Week 1: Setup and exploration (done)

- [x] 🤖 Create the repo structure
- [x] 🤖 Download the 9 CSVs
- [x] 🤖 Load the CSVs into staging tables (`stg_*`) → `sql/01_load_staging.sql`
- [x] 🤖 Profile every table → `docs/profiling.md`
- [x] 🤖 Draw the table relationships (Mermaid) → `docs/erd.md`
- [x] ✍️ Read the profiling output and note the 5–10 issues that matter most
- [x] ✍️ Write a draft data dictionary
- [x] ✍️ Write a single-sentence problem statement at the top of the README

## Week 2: Cleaning (done)

- [x] ✍️ Build the clean layer (`sql/02_cleaning.sql`)
- [x] ✍️ Join `product_category_name_translation`, handle unmatched categories (`unknown`)
- [x] ✍️ Flag impossible rows
- [x] ✍️ Reconciliation of `SUM(price + freight_value)` vs `SUM(payment_value)` (rounding / installment interest / unexplained)
- [x] ✍️ Create `data_issues_log`

---

## Week 3: Analyze (the part that answers the question)

Details of each late-delivery problem below are in `docs/late_delivery_alignment.md`.

### 3A. Make late delivery trustworthy (do this first, about 2 hrs)

The late-delivery numbers will mislead if these are skipped. Put each decision as a comment at the top of `sql/03_analysis.sql`.

- [x] ✍️ **Define "late" at date level:** `CAST(order_delivered_customer_date AS DATE) > CAST(order_estimated_delivery_date AS DATE)`. The estimate is always midnight, so a timestamp comparison counts same-day deliveries as late.
- [x] ✍️ **Set the analysis window:** orders purchased Jan 2017 to Aug 2018. Late 2016 has about 330 orders (Dec 2016 has 1) and Sep–Oct 2018 has about 20 orders, none delivered. Both distort month-over-month growth and late %.
- [x] ✍️ **Set the order scope:** `order_status = 'delivered'` with a non-NULL delivery date. This drops the 8 delivered orders with no date and the 6 canceled orders that have one.
- [x] ✍️ **Pick one grain rule for lateness vs category.** Lateness is per order, category is per item. Either (a) count an item as late if its order was late and report late % per item, or (b) keep only single-category orders (about 786 orders span more than one category; about 1,278 have more than one seller). State the rule you chose.
- [x] ✍️ **Build `v_order_delivery`** (one row per order): late flag, days late, delivery days, review score. Join this to items, never the reverse, to avoid fan-out.
- [x] ✍️ **Check lateness over time:** monthly late %. A quick pass shows spikes in Nov 2017 and Feb–Mar 2018 while most months are under about 8%. If lateness is driven by when an order was placed, say so rather than blaming categories.
- [x] ✍️ **Check the spread across categories:** late % for the top 15 categories by revenue. In a quick pass it barely differs (about 5–8%), so late % alone may not separate categories. If so, use average delivery days as the delivery measure on the chart and report late % in the table.
- [x] ✍️ **Check review timing:** about 5,100 reviews were created before the delivered date, mostly on late orders. Keep them but flag them, and report the late vs on-time score gap with and without them.
- [x] ✍️ Add rows to `data_issues_log` for the timestamp oddities found (6 canceled orders with a delivery date, 23 delivered before carrier pickup, 161 carrier pickups before purchase).
- [x] ✍️ Make date loading explicit: the raw CSVs use `d/m/yyyy` dates, not ISO. DuckDB read them correctly (profile ranges are right) but pandas defaults misread them and show about 24% late instead of about 8%. Add `dateformat`/`timestampformat` to `01_load_staging.sql` and a note in the README.

### 3B. Analysis queries (`sql/03_analysis.sql`)

- [x] ✍️ Per category: revenue, revenue share, freight % of price, late %, average delivery days, average review score
- [x] ✍️ `RANK()` categories by revenue and by freight %; list the ones that rank high on revenue and badly on freight
- [x] ✍️ **Assign each of the top ~15 categories an action label** with a simple, written rule, for example: high revenue + low freight = Promote; high revenue + high freight = Renegotiate freight; slow or late = Fix delivery; low revenue + high freight = Deprioritize. Define "high" (e.g. above median) in a comment.
- [x] ✍️ Month-over-month revenue growth (`LAG`) and running total (`SUM() OVER`), within the analysis window only
- [x] ✍️ Average review score for late vs on-time orders, plus by days-late bucket (1–3, 4–7, 8+)
- [x] ✍️ **Exposure table:** for each action label, the revenue, freight spend and number of late orders behind it. This is the raw material for the impact estimate in Week 4.
- [x] ✍️ Write a comment above each query stating the question it answers
- [x] 🤖 Export each query's results to `results/*.csv`

**Done when:** every question has a query, a result and a one-line takeaway, and the late-delivery decisions in 3A are written down.

---

## Week 4: Share and Act (don't skip this)

### Share: show the answer

- [ ] ✍️ **Main chart:** scatter of revenue (x) vs freight % (y), one dot per top category, coloured by action label, bubble size = average delivery days (or late % if the 3A spread check shows it separates categories). Label the 5–6 categories that matter; don't label all.
- [ ] ✍️ **Supporting chart 1:** monthly late % with average review score on the same timeline (shows lateness is time-driven and what it costs in reviews)
- [ ] ✍️ **Supporting chart 2:** average review score by days-late bucket
- [ ] ✍️ **Rewrite the README in this order:**
  1. One-sentence project statement (above)
  2. **Answer first:** 3 numbers and the main chart
  3. Recommendations (see Act)
  4. Question and who it's for (link `docs/ask.md`)
  5. Method (3 steps)
  6. Data issues and the late-delivery decisions
  7. Limitations
  8. Reproduce
- [ ] ✍️ Check with a friend: they read the top of the README for 60 seconds and repeat the conclusion

**Answer-first block to fill in (numbers come from your Week 3 results):**
> The top [N] categories make [X]% of revenue. [A] of them also carry freight above [Y]% of price, putting [Z] of revenue at high freight cost. Late deliveries average [W]% of orders and cut review scores from [S1] to [S2], but late % is [similar across categories / concentrated in months M1–M2], so the main lever is [freight terms in categories … / delivery capacity in months …].

### Act: say what to do about it

- [ ] ✍️ **Write 3 recommendations.** Each one needs: the action, the owner (finance, ops, seller management), the size (revenue, freight spend or orders it touches), and your confidence (what could make it wrong).
  - Example shape: "Renegotiate shipping terms for [categories A, B]: they hold [X]% of revenue at [Y]% freight. Owner: ops/seller management. Cutting freight by [Z] points would be worth about [amount] on the same sales. Confidence: medium, no carrier cost data."
- [ ] ✍️ **Size the impact as a scenario, not a forecast:** use the exposure table. Example: "If the worst categories' freight % fell to the median, freight would be [amount] lower on the same orders." Label review-score effects as correlation, not proof of cause.
- [ ] ✍️ **Next steps and missing data:** what you would need to firm this up (cost of goods, carrier cost per shipment, promised vs actual shipping time per seller).
- [ ] ✍️ Write 2 resume bullets with numbers, e.g. "Analysed 100k+ marketplace orders across 9 tables in SQL; ranked categories by revenue vs freight and delivery cost, flagging [N] categories holding [X]% of revenue at [Y]% freight" and "Reconciled order totals against payments; traced [X]% of mismatches to installment interest, leaving [24] orders unexplained"
- [ ] ✍️ Post on LinkedIn: the main chart, the one-line answer, link to the repo
- [ ] Optional: a one-page Tableau Public dashboard

**Done when:** a stranger can read the README in 60 seconds, repeat your conclusion, and say what Olist should do next.

---

## Ground rules

- **Sunday checkpoint:** push to GitHub every week, even if the work is messy.
- **If you fall behind:** cut the supporting charts and the optional dashboard, never Share and Act.
- **Use of automation:** let Claude handle the setup and boilerplate, but write the cleaning and analysis SQL yourself so you can explain every line in an interview.
- **Numbers rule:** every number in the README must trace to a query in `sql/` and a file in `results/`.

## Week 1 automation prompt (for Claude Code)

```
In this folder, set up a portfolio analytics project:
1. Create dirs: data/raw, sql, docs, results, charts, notebooks. Add .gitignore excluding data/. git init.
2. Download Kaggle dataset olistbr/brazilian-ecommerce into data/raw (kaggle CLI; token is in ~/.kaggle).
3. Create olist.duckdb; load each CSV into a stg_<name> table. Save the DDL to sql/01_schema.sql.
4. Profile every table: row count, null count per column, duplicate primary keys,
   min/max of date columns, orphan FKs (order_items→orders, orders→customers,
   order_items→products, order_items→sellers, payments→orders, reviews→orders).
   Write the results to docs/profiling.md as tables.
5. Write docs/erd.md with a Mermaid erDiagram of the 9 tables and their keys.
6. Write a README.md skeleton: Question / Answer (TBD) / Method / Data issues / Limitations.
Do NOT write cleaning or analysis queries. Keep it minimal.
```
