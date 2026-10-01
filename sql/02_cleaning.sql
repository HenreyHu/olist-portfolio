-- Week 2: Clean layer, category translation, impossible-row flags, reconciliation.
-- Run from repo root: duckdb data/olist.duckdb < sql/02_cleaning.sql
-- ============================================================
-- Data issues log — created first so every step below can log into it
-- ============================================================
DROP TABLE IF EXISTS data_issues_log;

CREATE TABLE IF NOT EXISTS data_issues_log (
    issue         VARCHAR,
    table_name    VARCHAR,
    rows_affected BIGINT,
    fix_applied   VARCHAR
);

-- ============================================================
-- Step 1: Clean layer
-- ============================================================

-- stg_order_reviews: real key is (review_id, order_id), not review_id alone —
-- a review can legitimately cover more than one order. SELECT DISTINCT only
-- strips exact full-row duplicates, if any exist.
CREATE OR REPLACE TABLE clean_order_reviews AS
SELECT DISTINCT * FROM stg_order_reviews;

-- stg_geolocation: out of scope for the main revenue/freight question.
-- No clean table built — logged instead.
INSERT INTO data_issues_log VALUES (
    'lat/lng values outside Brazil bounds (lat up to 45.07, lng up to 121.11); not needed for main revenue/freight question',
    'stg_geolocation',
    1000163,
    'excluded from clean layer — out of scope'
);

-- stg_sellers: seller_state is clean; seller_city has inconsistent formatting
-- (state codes appended, a zip code value, at least one typo). Not standardized
-- since city text isn't used in the main/supporting questions — trim only.
CREATE OR REPLACE TABLE clean_sellers AS
SELECT
    seller_id,
    TRIM(seller_zip_code_prefix) AS seller_zip_code_prefix,
    TRIM(seller_city)            AS seller_city,
    TRIM(seller_state)           AS seller_state
FROM stg_sellers;

INSERT INTO data_issues_log VALUES (
    'seller_city has inconsistent formatting: state codes appended to some city names, a zip code value, and at least one apparent typo',
    'stg_sellers',
    3095,
    'not standardized — city text not used in main or supporting questions; trimmed whitespace only'
);

-- stg_customers: customer_state is clean (27 valid codes); customer_city
-- already known messy (4,119 spellings, flagged in Week 1) — same treatment.
CREATE OR REPLACE TABLE clean_customers AS
SELECT
    customer_id,
    customer_unique_id,
    TRIM(customer_zip_code_prefix) AS customer_zip_code_prefix,
    TRIM(customer_city)            AS customer_city,
    TRIM(customer_state)           AS customer_state
FROM stg_customers;

INSERT INTO data_issues_log VALUES (
    'customer_city has 4,119 distinct spellings/formats',
    'stg_customers',
    99441,
    'not standardized — city text not used in main or supporting questions; trimmed whitespace only'
);

-- stg_products: category NULL handling deferred to step 2 (translation join).
-- 2 products missing weight/dimensions entirely — kept as NULL, negligible.
CREATE OR REPLACE TABLE clean_products AS
SELECT
    product_id,
    TRIM(product_category_name) AS product_category_name,
    product_name_lenght,
    product_description_lenght,
    product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM stg_products;

INSERT INTO data_issues_log VALUES (
    '2 products missing weight/dimensions entirely',
    'stg_products',
    2,
    'kept as NULL — negligible row count, not used in main analysis'
);

-- stg_orders: cast/trim only here. Row-level flags (impossible/inconsistent
-- rows) come in step 3.
CREATE OR REPLACE TABLE clean_orders AS
SELECT
    order_id,
    customer_id,
    TRIM(order_status) AS order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM stg_orders;

INSERT INTO data_issues_log VALUES (
    'order_delivered_customer_date is NULL for 2,965 orders; 2,957 of these have a non-delivered status (shipped/canceled/unavailable/invoiced/processing/created/approved) and are expected to lack a delivery date',
    'stg_orders', 2957, 'no fix needed — excluded from lateness calc naturally since they never delivered'
);

INSERT INTO data_issues_log VALUES (
    'order_delivered_customer_date is NULL for 8 orders despite order_status = delivered — inconsistent, order claims completion but has no delivery timestamp',
    'stg_orders', 8, 'kept as NULL, flagged as impossible/inconsistent row in step 3 — cannot compute lateness for these'
);

-- stg_order_items / stg_order_payments: 0 duplicate keys, no bad prices found.
-- Straight cast/trim; deeper scrutiny happens in step 3 and step 4.
CREATE OR REPLACE TABLE clean_order_items AS
SELECT
    order_id, order_item_id, product_id, seller_id,
    shipping_limit_date, price, freight_value
FROM stg_order_items;

CREATE OR REPLACE TABLE clean_order_payments AS
SELECT
    order_id, payment_sequential, TRIM(payment_type) AS payment_type,
    payment_installments, payment_value
FROM stg_order_payments;

INSERT INTO data_issues_log VALUES (
    'payment_value = 0 for 9 rows: 6 are payment_type=voucher (plausible — voucher covered full amount on a multi-payment order), 3 are payment_type=not_defined (unclassified payment method)',
    'stg_order_payments', 9, 'kept as-is — voucher rows are legitimate; not_defined rows flagged but not excluded, negligible count'
);

-- stg_category_translation: 71 rows, 0 nulls — straight trim.
CREATE OR REPLACE TABLE clean_category_translation AS
SELECT
    TRIM(product_category_name)         AS product_category_name,
    TRIM(product_category_name_english) AS product_category_name_english
FROM stg_category_translation;

-- ============================================================
-- Step 2: Category translation join
-- ============================================================

-- 610 products with NULL category, plus 13 whose category (pc_gamer,
-- portateis_cozinha_e_preparadores_de_alimentos) has no match in the
-- translation table. Both bucketed as 'unknown' via COALESCE on a LEFT JOIN.
-- Verified: row count stays at 32,951 (no fan-out from the join).
CREATE OR REPLACE TABLE clean_products_categorized AS
SELECT
    p.*,
    COALESCE(t.product_category_name_english, 'unknown') AS product_category_name_english
FROM clean_products p
LEFT JOIN clean_category_translation t
  ON p.product_category_name = t.product_category_name;

INSERT INTO data_issues_log VALUES (
    '610 products with NULL product_category_name, plus 13 products whose category (pc_gamer, portateis_cozinha_e_preparadores_de_alimentos) has no match in the translation table',
    'stg_products', 623, 'bucketed as english category = ''unknown'' via COALESCE on a LEFT JOIN; applies uniformly to both NULL and unmatched categories'
);

-- ============================================================
-- Step 3: Impossible-row flags
-- ============================================================

-- Delivered before purchase: checked, none found.
INSERT INTO data_issues_log VALUES (
    'Checked for orders delivered before purchase',
    'stg_orders', 0, 'none found — no fix needed'
);

-- payment_installments = 0: 2 rows, both credit_card with positive payment_value.
INSERT INTO data_issues_log VALUES (
    'payment_installments = 0 for 2 rows, both payment_type=credit_card with positive payment_value — likely a data entry gap, should be >=1',
    'stg_order_payments', 2, 'kept as-is — negligible count, does not affect reconciliation buckets since these rows simply fall outside the installment-interest group'
);

-- shipping_limit_date reaching 2020 while orders stop in Oct 2018: 4 rows.
INSERT INTO data_issues_log VALUES (
    'shipping_limit_date extends to 2020-04-09 for 4 rows while orders themselves stop in Oct 2018',
    'stg_order_items', 4, 'no fix applied — shipping_limit_date not used in lateness or reconciliation calculations, flagged for visibility only'
);

-- Note: zero/negative prices in stg_order_items were also checked — min price
-- is 0.85, so 0 rows found. Not logged as a separate row since nothing to note
-- beyond "checked, clean."

-- ============================================================
-- Step 4: Reconciliation
-- ============================================================

-- Per order: SUM(price + freight_value) from items vs. SUM(payment_value)
-- from payments. Each side aggregated in its own CTE before joining, to
-- avoid row fan-out from joining at the item/payment grain.
-- Mismatches bucketed as: rounding (sub-10-cent floating point noise),
-- installment_interest (paid more, installments > 1), or unexplained.
-- (A separate voucher bucket was tried but every voucher-flagged mismatch
-- turned out to be rounding-sized, so it collapsed into that bucket.)
CREATE OR REPLACE TABLE order_reconciliation AS
WITH items_agg AS (
    SELECT order_id, ROUND(SUM(price + freight_value), 2) AS order_total
    FROM clean_order_items
    GROUP BY order_id
),
payments_agg AS (
    SELECT
        order_id,
        ROUND(SUM(payment_value), 2) AS paid_total,
        MAX(payment_installments) AS max_installments,
        BOOL_OR(payment_type = 'voucher') AS has_voucher
    FROM clean_order_payments
    GROUP BY order_id
),
mismatches AS (
    SELECT
        i.order_id,
        i.order_total,
        p.paid_total,
        ROUND(p.paid_total - i.order_total, 2) AS diff,
        p.max_installments,
        p.has_voucher
    FROM items_agg i
    JOIN payments_agg p ON i.order_id = p.order_id
    WHERE ROUND(p.paid_total - i.order_total, 2) != 0
)
SELECT *,
    CASE
        WHEN ABS(diff) <= 0.10 THEN 'rounding'
        WHEN diff > 0 AND max_installments > 1 THEN 'installment_interest'
        ELSE 'unexplained'
    END AS bucket
FROM mismatches;

INSERT INTO data_issues_log VALUES (
    'Reconciliation: SUM(price+freight_value) vs SUM(payment_value) per order. Buckets: rounding (317 orders, -$0.69, sub-10-cent floating point noise), installment_interest (235 orders, +$3,063.40, diff>0 with installments>1), unexplained (24 orders, -$192.32, no identifiable cause)',
    'clean_order_items, clean_order_payments', 576, 'bucketed via CASE on diff sign, installment count, and voucher flag; rounding threshold at $0.10 added after inspecting distribution'
);

-- ============================================================
-- Verification (sanity checks — safe to run after the script)
-- ============================================================

-- SELECT COUNT(*) FROM clean_order_reviews;                              -- 99,224
-- SELECT COUNT(*) FROM clean_sellers;                                    -- 3,095
-- SELECT COUNT(*) FROM clean_customers;                                  -- 99,441
-- SELECT COUNT(*) FROM clean_products;                                   -- 32,951
-- SELECT COUNT(*) FROM clean_products_categorized;                       -- 32,951
-- SELECT COUNT(*) FROM clean_orders;                                     -- 99,441
-- SELECT COUNT(*) FROM clean_order_items;                                -- 112,650
-- SELECT COUNT(*) FROM clean_order_payments;                             -- 103,886
-- SELECT COUNT(*) FROM clean_category_translation;                       -- 71
-- SELECT bucket, COUNT(*), ROUND(SUM(diff),2) FROM order_reconciliation
--   GROUP BY bucket ORDER BY 2 DESC;
-- SELECT * FROM data_issues_log;
