# Olist E-commerce: Revenue vs Freight & Delivery Performance

> **Answer:** _TBD (Week 4)._

## Question
Which product categories bring in the most revenue but lose the most to freight costs and late deliveries?

## Data
[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce): 9 tables, ~100k orders, 2016–2018. Table relationships are in [docs/erd.md](docs/erd.md).

## Method
1. Load the raw CSVs into staging tables (`sql/01_load_staging.sql`)
2. Clean the data and reconcile order totals against payments (`sql/02_cleaning.sql`)
3. Analyse categories (`sql/03_analysis.sql`)

## Data issues
_TBD, see `data_issues_log`._

## Limitations
- The dataset has no cost of goods, so freight as a % of price is used in place of margin.

## Reproduce
```bash
pip install -r requirements.txt
python scripts/setup_data.py   # downloads the CSVs and builds data/olist.duckdb
python scripts/profile.py      # writes docs/profiling.md
```
