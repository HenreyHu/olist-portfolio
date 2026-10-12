-- Week 3: Analysis. Run with: python scripts/run_analysis.py (views come from sql/03a_views.sql)
--
-- DECISIONS (3A)
-- Late: delivered DATE is after estimated DATE. The estimate is always midnight, so a timestamp comparison would count same-day deliveries as late.
-- Window: orders purchased Jan 2017 to Aug 2018. Late 2016 has about 330 orders and Sep-Oct 2018 about 20, which distort growth and late %.
-- Scope: order_status = delivered with a delivery date. This drops the 8 delivered orders with no date and the canceled orders that have one.
-- Grain: lateness is per order and category is per item. An order counts once toward every category it contains.
-- Reviews: averaged per order first, because some orders have more than one review.
-- Revenue is SUM(price), and freight % is freight divided by price. There is no cost of goods in the data.

-- Q1: For each category, what are revenue, share of revenue, freight % of price, late %, delivery days and review score?
SELECT * FROM v_category_summary
ORDER BY revenue DESC;

-- Q2: Which high-revenue categories also rank badly on freight %?
-- Categories under 100 orders are excluded so small samples do not dominate. Candidates are top 15 on both ranks.
WITH ranked AS (
    SELECT *,
        RANK() OVER (ORDER BY revenue DESC)     AS rank_revenue,
        RANK() OVER (ORDER BY freight_pct DESC) AS rank_freight
    FROM v_category_summary
    WHERE orders >= 100
)
SELECT * FROM ranked
WHERE rank_revenue <= 15 AND rank_freight <= 15
ORDER BY rank_revenue;

-- Q3: How does monthly revenue change month over month, and what is the running total?
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', d.purchase_date) AS month,
        ROUND(SUM(oi.price), 2)              AS revenue
    FROM clean_order_items oi
    JOIN v_order_delivery d ON oi.order_id = d.order_id
    GROUP BY 1
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month)                      AS prev_revenue,
    ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
                / LAG(revenue) OVER (ORDER BY month), 1)    AS mom_growth_pct,
    ROUND(SUM(revenue) OVER (ORDER BY month), 2)            AS running_total
FROM monthly
ORDER BY month;

-- Q4: Do late orders get lower review scores than on-time orders?
SELECT
    CASE WHEN is_late = 1 THEN 'late' ELSE 'on_time' END AS delivery,
    COUNT(review_score)                                   AS reviewed_orders,
    ROUND(AVG(review_score), 2)                           AS avg_review
FROM v_order_delivery
GROUP BY 1
ORDER BY 1;

-- Q5: Is lateness driven by when the order was placed? Monthly late % and average review.
SELECT
    DATE_TRUNC('month', purchase_date) AS month,
    COUNT(*)                           AS orders,
    ROUND(100.0 * AVG(is_late), 1)     AS late_pct,
    ROUND(AVG(review_score), 2)        AS avg_review
FROM v_order_delivery
GROUP BY 1
ORDER BY 1;

-- Q6: How much does review score fall the later an order arrives?
SELECT
    CASE WHEN days_late = 0 THEN '0 on time'
         WHEN days_late <= 3 THEN '1-3 days'
         WHEN days_late <= 7 THEN '4-7 days'
         ELSE '8+ days' END AS days_late_bucket,
    COUNT(review_score)     AS reviewed_orders,
    ROUND(AVG(review_score), 2) AS avg_review
FROM v_order_delivery
GROUP BY 1
ORDER BY MIN(days_late);

-- Q7: Which action does each of the top 15 categories get, and why?
SELECT category, action, revenue, revenue_share_pct, freight_pct, avg_delivery_days, late_pct, avg_review
FROM v_category_action
ORDER BY action, revenue DESC;

-- Q8: Exposure table. How much revenue, freight spend and late orders sit behind each action?
-- An order that spans several categories counts once per category, so order totals can slightly overlap.
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
    a.action,
    COUNT(DISTINCT a.category)                    AS categories,
    COUNT(*)                                      AS orders,
    ROUND(SUM(c.price), 2)                        AS revenue,
    ROUND(SUM(c.freight), 2)                      AS freight_spend,
    ROUND(100.0 * SUM(c.freight) / SUM(c.price), 1) AS freight_pct,
    SUM(d.is_late)                                AS late_orders,
    ROUND(100.0 * AVG(d.is_late), 1)              AS late_pct
FROM cat_orders c
JOIN v_category_action a ON c.category = a.category
JOIN v_order_delivery d  ON c.order_id = d.order_id
GROUP BY a.action
ORDER BY revenue DESC;

-- Q9: Does the late vs on-time review gap hold without reviews written before the delivery date?
-- Per review, not per order. Early = review created before the delivered date.
WITH r AS (
    SELECT
        d.is_late,
        rv.review_score,
        CAST(rv.review_creation_date AS DATE) < CAST(o.order_delivered_customer_date AS DATE) AS early_review
    FROM clean_order_reviews rv
    JOIN clean_orders o     ON rv.order_id = o.order_id
    JOIN v_order_delivery d ON o.order_id  = d.order_id
)
SELECT slice, delivery, COUNT(*) AS reviews, ROUND(AVG(review_score), 2) AS avg_review
FROM (
    SELECT 'all reviews' AS slice, CASE WHEN is_late = 1 THEN 'late' ELSE 'on_time' END AS delivery, review_score FROM r
    UNION ALL
    SELECT 'excluding early reviews', CASE WHEN is_late = 1 THEN 'late' ELSE 'on_time' END, review_score FROM r WHERE NOT early_review
    UNION ALL
    SELECT 'early reviews only', CASE WHEN is_late = 1 THEN 'late' ELSE 'on_time' END, review_score FROM r WHERE early_review
)
GROUP BY slice, delivery
ORDER BY slice, delivery;
