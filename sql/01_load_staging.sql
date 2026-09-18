-- Load raw Olist CSVs into staging tables (run from repo root).
-- duckdb data/olist.duckdb < sql/01_load_staging.sql

CREATE OR REPLACE TABLE stg_customers      AS SELECT * FROM read_csv_auto('data/raw/olist_customers_dataset.csv');
CREATE OR REPLACE TABLE stg_geolocation    AS SELECT * FROM read_csv_auto('data/raw/olist_geolocation_dataset.csv');
CREATE OR REPLACE TABLE stg_order_items    AS SELECT * FROM read_csv_auto('data/raw/olist_order_items_dataset.csv');
CREATE OR REPLACE TABLE stg_order_payments AS SELECT * FROM read_csv_auto('data/raw/olist_order_payments_dataset.csv');
CREATE OR REPLACE TABLE stg_order_reviews  AS SELECT * FROM read_csv_auto('data/raw/olist_order_reviews_dataset.csv');
CREATE OR REPLACE TABLE stg_orders         AS SELECT * FROM read_csv_auto('data/raw/olist_orders_dataset.csv');
CREATE OR REPLACE TABLE stg_products       AS SELECT * FROM read_csv_auto('data/raw/olist_products_dataset.csv');
CREATE OR REPLACE TABLE stg_sellers        AS SELECT * FROM read_csv_auto('data/raw/olist_sellers_dataset.csv');
CREATE OR REPLACE TABLE stg_category_translation AS SELECT * FROM read_csv_auto('data/raw/product_category_name_translation.csv');
