DELETE FROM data_issues_log WHERE issue LIKE 'Timestamp:%';

INSERT INTO data_issues_log
SELECT 'Timestamp: canceled orders that still have a delivery date', 'stg_orders', COUNT(*),
       'kept - excluded by the delivered-only scope in 03_analysis.sql'
FROM clean_orders
WHERE order_status = 'canceled' AND order_delivered_customer_date IS NOT NULL;

INSERT INTO data_issues_log
SELECT 'Timestamp: delivered to customer before carrier pickup', 'stg_orders', COUNT(*),
       'kept - lateness uses the customer delivery date, the carrier date is not used'
FROM clean_orders
WHERE order_delivered_customer_date < order_delivered_carrier_date;

INSERT INTO data_issues_log
SELECT 'Timestamp: carrier pickup before purchase', 'stg_orders', COUNT(*),
       'kept - the carrier date is not used in any metric'
FROM clean_orders
WHERE order_delivered_carrier_date < order_purchase_timestamp
;
SELECT issue, rows_affected FROM data_issues_log WHERE issue LIKE 'Timestamp:%'
