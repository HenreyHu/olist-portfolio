SELECT COUNT(*) AS rows_compared,
       SUM((n.order_purchase_timestamp IS DISTINCT FROM date_trunc('minute', s.order_purchase_timestamp))::INT)       AS purchase,
       SUM((n.order_approved_at IS DISTINCT FROM date_trunc('minute', s.order_approved_at))::INT)                     AS approved,
       SUM((n.order_delivered_carrier_date IS DISTINCT FROM date_trunc('minute', s.order_delivered_carrier_date))::INT)   AS carrier,
       SUM((n.order_delivered_customer_date IS DISTINCT FROM date_trunc('minute', s.order_delivered_customer_date))::INT) AS delivered,
       SUM((n.order_estimated_delivery_date IS DISTINCT FROM date_trunc('minute', s.order_estimated_delivery_date))::INT) AS estimated
FROM read_csv('data/raw/olist_orders_dataset.csv', timestampformat='%d/%m/%Y %H:%M') n
JOIN stg_orders s ON n.order_id = s.order_id
