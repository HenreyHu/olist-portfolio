# Portfolio Project Plan: Olist E-commerce Analysis (4 weeks)

**Time budget:** ~8–10 hrs/week
**Stack:** DuckDB or PostgreSQL · Git/GitHub · Python (pandas + matplotlib) or Tableau Public
**Dataset:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (9 CSVs, ~100k orders, 2016–2018)

## Main question

> Which product categories bring in the most revenue but lose the most to freight costs and late deliveries?

**Supporting question**

Does late delivery lower review scores?

**Stated limitation:** the dataset has no cost of goods. Freight as a % of price stands in for margin, and the write-up must say so.

**Legend:** 🤖 = Claude can automate this · ✍️ = do it yourself (interviewers will ask about it)

---

## Week 1: Setup and exploration

- [x] 🤖 Create the repo structure (`data/raw`, `sql/`, `notebooks/`, `charts/`, `README.md`, `.gitignore` excluding `data/`)
- [x] 🤖 Download the 9 CSVs (public download, no Kaggle token needed)
- [x] 🤖 Load the CSVs into staging tables (`stg_*`) and save the load script as `sql/01_load_staging.sql`
- [x] 🤖 Profile every table (row counts, nulls per column, duplicate keys, min/max dates, unmatched foreign keys) → `docs/profiling.md`
- [x] 🤖 Draw a diagram of how the tables connect (Mermaid) → `docs/erd.md`
- [ ] ✍️ Read the profiling output and note the 5–10 issues that look most important
- [ ] ✍️ Write a draft data dictionary: what each table is for, its grain (what one row represents) and its keys
- [x] ✍️ Write a single-sentence problem statement at the top of the README

**Done when:** the repo is pushed with schema, profiling notes and a draft README.

## Week 2: Cleaning (the SQL core)

- [ ] ✍️ Build the clean layer (`sql/02_cleaning.sql`): cast data types, trim text, and remove duplicate rows
- [ ] ✍️ Join `product_category_name_translation` to get English category names, and handle categories that have no match
- [ ] ✍️ Flag impossible rows: delivered before purchase, missing delivery dates, zero or negative prices
- [ ] ✍️ **Reconciliation:** for each order, compare `SUM(price + freight_value)` against `SUM(payment_value)`
  - [ ] Group mismatches into installment interest, vouchers and unexplained
  - [ ] Count them and total their value for each group
- [ ] ✍️ Create a `data_issues_log` table with columns: issue, table, rows_affected, fix_applied

**Done when:** `02_cleaning.sql` runs end to end and the issues log is filled in.

## Week 3: Analysis

- [ ] ✍️ Calculate revenue, freight % and late-delivery % for each category (`sql/03_analysis.sql`)
- [ ] ✍️ `RANK()` categories by revenue and by freight %, and list those that rank high on revenue and badly on freight
- [ ] ✍️ Calculate month-over-month revenue growth (`LAG`) and a running total (`SUM() OVER`)
- [ ] ✍️ Compare average review score for late vs on-time orders
- [ ] ✍️ Write a comment above each query stating the question it answers
- [ ] 🤖 Export each query's results to `results/*.csv`

**Done when:** every question has a query, a result and a one-line takeaway.

## Week 4: Presentation (don't skip this)

- [ ] ✍️ Main chart: a scatter of revenue (x) vs freight % (y), with bubble size showing late-delivery rate
- [ ] ✍️ At most 2 supporting charts
- [ ] ✍️ Rewrite the README in this order: **answer first** → question → method → data issues → limitations
- [ ] ✍️ Write 2 resume bullets with numbers, e.g. "Cleaned and reconciled 100k+ orders across 9 tables; traced X% of payment mismatches to…"
- [ ] ✍️ Post on LinkedIn with the main chart and a link to the repo
- [ ] Optional: a one-page Tableau Public dashboard

**Done when:** a stranger can read the README in 60 seconds and repeat your conclusion.

---

## Ground rules

- **Sunday checkpoint:** push to GitHub every week, even if the work is messy.
- **If you fall behind:** cut the supporting questions, never Week 4.
- **Use of automation:** let Claude handle the setup and boilerplate, but write the cleaning and analysis SQL yourself so you can explain every line in an interview.

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
