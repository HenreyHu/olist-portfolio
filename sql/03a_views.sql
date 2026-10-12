-- Week 3A views. Decisions are documented at the top of 03_analysis.sql
CREATE OR REPLACE VIEW v_order_delivery AS
WITH rev AS (
    SELECT order_id, AVG(review_score) AS review_score
    FROM clean_order_reviews
    GROUP BY order_id
)
SELECT
    o.order_id,
    CAST(o.order_purchase_timestamp AS DATE)       AS purchase_date,
    CASE WHEN CAST(o.order_delivered_customer_date AS DATE) > CAST(o.order_estimated_delivery_date AS DATE)
         THEN 1 ELSE 0 END                         AS is_late,
    GREATEST(DATE_DIFF('day', CAST(o.order_estimated_delivery_date AS DATE),
                              CAST(o.order_delivered_customer_date AS DATE)), 0) AS days_late,
    DATE_DIFF('day', CAST(o.order_purchase_timestamp AS DATE),
                     CAST(o.order_delivered_customer_date AS DATE))              AS delivery_days,
    r.review_score
FROM clean_orders o
LEFT JOIN rev r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND CAST(o.order_purchase_timestamp AS DATE) >= DATE '2017-01-01'
  AND CAST(o.order_purchase_timestamp AS DATE) <  DATE '2018-09-01';

CREATE OR REPLACE VIEW v_category_summary AS
WITH cat_orders AS (
    SELECT
        p.product_category_name_english AS category,
        oi.order_id,
        SUM(oi.price)         AS price,
        SUM(oi.freight_value) AS freight
    FROM clean_order_items oi
    JOIN clean_products_categorized p ON oi.product_id = p.product_id
    GROUP BY 1, 2
)
SELECT
    c.category,
    COUNT(*)                                              AS orders,
    ROUND(SUM(c.price), 2)                                AS revenue,
    ROUND(100.0 * SUM(c.price) / SUM(SUM(c.price)) OVER (), 1) AS revenue_share_pct,
    ROUND(100.0 * SUM(c.freight) / SUM(c.price), 1)       AS freight_pct,
    ROUND(100.0 * AVG(d.is_late), 1)                      AS late_pct,
    ROUND(AVG(d.delivery_days), 1)                        AS avg_delivery_days,
    ROUND(AVG(d.review_score), 2)                         AS avg_review
FROM cat_orders c
JOIN v_order_delivery d ON c.order_id = d.order_id
GROUP BY c.category
;

-- Action label per category. Scope is the top 15 categories by revenue (min 100 orders).
-- HIGH freight = freight % above the median of those 15. HIGH revenue = revenue at or above their median.
-- SLOW = average delivery days more than 1.25 x the median of those 15.
-- Rules in order: SLOW = Fix delivery. HIGH freight and HIGH revenue = Renegotiate freight.
-- HIGH freight and LOW revenue = Deprioritize. Everything else = Promote.
CREATE OR REPLACE VIEW v_category_action AS
WITH top15 AS (
    SELECT * FROM v_category_summary
    WHERE orders >= 100
    ORDER BY revenue DESC
    LIMIT 15
),
thr AS (
    SELECT MEDIAN(freight_pct)       AS med_freight,
           MEDIAN(revenue)           AS med_revenue,
           MEDIAN(avg_delivery_days) AS med_days
    FROM top15
)
SELECT
    t.*,
    CASE WHEN t.avg_delivery_days > 1.25 * thr.med_days                  THEN 'Fix delivery'
         WHEN t.freight_pct > thr.med_freight AND t.revenue >= thr.med_revenue THEN 'Renegotiate freight'
         WHEN t.freight_pct > thr.med_freight                            THEN 'Deprioritize'
         ELSE 'Promote' END AS action
FROM top15 t
CROSS JOIN thr
