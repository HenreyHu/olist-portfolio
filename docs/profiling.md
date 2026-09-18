# Data profiling

## stg_category_translation

- Rows: **71**

| column | type | nulls | null % | distinct | min | max |
|---|---|---:|---:|---:|---|---|
| product_category_name | VARCHAR | 0 | 0.0 | 71 |  |  |
| product_category_name_english | VARCHAR | 0 | 0.0 | 71 |  |  |

## stg_customers

- Rows: **99,441**
- Duplicate keys on (customer_id): **0**

| column | type | nulls | null % | distinct | min | max |
|---|---|---:|---:|---:|---|---|
| customer_id | VARCHAR | 0 | 0.0 | 99,441 |  |  |
| customer_unique_id | VARCHAR | 0 | 0.0 | 96,096 |  |  |
| customer_zip_code_prefix | VARCHAR | 0 | 0.0 | 14,994 |  |  |
| customer_city | VARCHAR | 0 | 0.0 | 4,119 |  |  |
| customer_state | VARCHAR | 0 | 0.0 | 27 |  |  |

## stg_geolocation

- Rows: **1,000,163**

| column | type | nulls | null % | distinct | min | max |
|---|---|---:|---:|---:|---|---|
| geolocation_zip_code_prefix | VARCHAR | 0 | 0.0 | 19,015 |  |  |
| geolocation_lat | DOUBLE | 0 | 0.0 | 717,372 | -36.6053744107061 | 45.06593318269697 |
| geolocation_lng | DOUBLE | 0 | 0.0 | 717,615 | -101.46676644931476 | 121.10539381057764 |
| geolocation_city | VARCHAR | 0 | 0.0 | 8,011 |  |  |
| geolocation_state | VARCHAR | 0 | 0.0 | 27 |  |  |

## stg_order_items

- Rows: **112,650**
- Duplicate keys on (order_id, order_item_id): **0**

| column | type | nulls | null % | distinct | min | max |
|---|---|---:|---:|---:|---|---|
| order_id | VARCHAR | 0 | 0.0 | 98,666 |  |  |
| order_item_id | BIGINT | 0 | 0.0 | 21 | 1 | 21 |
| product_id | VARCHAR | 0 | 0.0 | 32,951 |  |  |
| seller_id | VARCHAR | 0 | 0.0 | 3,095 |  |  |
| shipping_limit_date | TIMESTAMP | 0 | 0.0 | 93,318 | 2016-09-19 00:15:34 | 2020-04-09 22:35:08 |
| price | DOUBLE | 0 | 0.0 | 5,968 | 0.85 | 6735.0 |
| freight_value | DOUBLE | 0 | 0.0 | 6,999 | 0.0 | 409.68 |

## stg_order_payments

- Rows: **103,886**
- Duplicate keys on (order_id, payment_sequential): **0**

| column | type | nulls | null % | distinct | min | max |
|---|---|---:|---:|---:|---|---|
| order_id | VARCHAR | 0 | 0.0 | 99,440 |  |  |
| payment_sequential | BIGINT | 0 | 0.0 | 29 | 1 | 29 |
| payment_type | VARCHAR | 0 | 0.0 | 5 |  |  |
| payment_installments | BIGINT | 0 | 0.0 | 24 | 0 | 24 |
| payment_value | DOUBLE | 0 | 0.0 | 29,077 | 0.0 | 13664.08 |

## stg_order_reviews

- Rows: **99,224**
- Duplicate keys on (review_id): **789**

| column | type | nulls | null % | distinct | min | max |
|---|---|---:|---:|---:|---|---|
| review_id | VARCHAR | 0 | 0.0 | 98,410 |  |  |
| order_id | VARCHAR | 0 | 0.0 | 98,673 |  |  |
| review_score | BIGINT | 0 | 0.0 | 5 | 1 | 5 |
| review_comment_title | VARCHAR | 87,656 | 88.3 | 4,527 |  |  |
| review_comment_message | VARCHAR | 58,247 | 58.7 | 36,159 |  |  |
| review_creation_date | TIMESTAMP | 0 | 0.0 | 636 | 2016-10-02 00:00:00 | 2018-08-31 00:00:00 |
| review_answer_timestamp | TIMESTAMP | 0 | 0.0 | 98,248 | 2016-10-07 18:32:28 | 2018-10-29 12:27:35 |

## stg_orders

- Rows: **99,441**
- Duplicate keys on (order_id): **0**

| column | type | nulls | null % | distinct | min | max |
|---|---|---:|---:|---:|---|---|
| order_id | VARCHAR | 0 | 0.0 | 99,441 |  |  |
| customer_id | VARCHAR | 0 | 0.0 | 99,441 |  |  |
| order_status | VARCHAR | 0 | 0.0 | 8 |  |  |
| order_purchase_timestamp | TIMESTAMP | 0 | 0.0 | 98,875 | 2016-09-04 21:15:19 | 2018-10-17 17:30:18 |
| order_approved_at | TIMESTAMP | 160 | 0.2 | 90,733 | 2016-09-15 12:16:38 | 2018-09-03 17:40:06 |
| order_delivered_carrier_date | TIMESTAMP | 1,783 | 1.8 | 81,018 | 2016-10-08 10:34:01 | 2018-09-11 19:48:28 |
| order_delivered_customer_date | TIMESTAMP | 2,965 | 3.0 | 95,664 | 2016-10-11 13:46:32 | 2018-10-17 13:22:46 |
| order_estimated_delivery_date | TIMESTAMP | 0 | 0.0 | 459 | 2016-09-30 00:00:00 | 2018-11-12 00:00:00 |

## stg_products

- Rows: **32,951**
- Duplicate keys on (product_id): **0**

| column | type | nulls | null % | distinct | min | max |
|---|---|---:|---:|---:|---|---|
| product_id | VARCHAR | 0 | 0.0 | 32,951 |  |  |
| product_category_name | VARCHAR | 610 | 1.9 | 73 |  |  |
| product_name_lenght | BIGINT | 610 | 1.9 | 66 | 5 | 76 |
| product_description_lenght | BIGINT | 610 | 1.9 | 2,960 | 4 | 3992 |
| product_photos_qty | BIGINT | 610 | 1.9 | 19 | 1 | 20 |
| product_weight_g | BIGINT | 2 | 0.0 | 2,204 | 0 | 40425 |
| product_length_cm | BIGINT | 2 | 0.0 | 99 | 7 | 105 |
| product_height_cm | BIGINT | 2 | 0.0 | 102 | 2 | 105 |
| product_width_cm | BIGINT | 2 | 0.0 | 95 | 6 | 118 |

## stg_sellers

- Rows: **3,095**
- Duplicate keys on (seller_id): **0**

| column | type | nulls | null % | distinct | min | max |
|---|---|---:|---:|---:|---|---|
| seller_id | VARCHAR | 0 | 0.0 | 3,095 |  |  |
| seller_zip_code_prefix | VARCHAR | 0 | 0.0 | 2,246 |  |  |
| seller_city | VARCHAR | 0 | 0.0 | 611 |  |  |
| seller_state | VARCHAR | 0 | 0.0 | 23 |  |  |

## Orphan foreign keys

| child | parent | orphan rows |
|---|---|---:|
| stg_orders.customer_id | stg_customers.customer_id | 0 |
| stg_order_items.order_id | stg_orders.order_id | 0 |
| stg_order_items.product_id | stg_products.product_id | 0 |
| stg_order_items.seller_id | stg_sellers.seller_id | 0 |
| stg_order_payments.order_id | stg_orders.order_id | 0 |
| stg_order_reviews.order_id | stg_orders.order_id | 0 |
| stg_products.product_category_name | stg_category_translation.product_category_name | 13 |
