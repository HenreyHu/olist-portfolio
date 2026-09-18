# Table relationships

```mermaid
erDiagram
    stg_customers ||--o{ stg_orders : "customer_id"
    stg_orders ||--o{ stg_order_items : "order_id"
    stg_orders ||--o{ stg_order_payments : "order_id"
    stg_orders ||--o{ stg_order_reviews : "order_id"
    stg_products ||--o{ stg_order_items : "product_id"
    stg_sellers ||--o{ stg_order_items : "seller_id"
    stg_category_translation ||--o{ stg_products : "product_category_name"
    stg_geolocation }o..o{ stg_customers : "zip_code_prefix (not unique)"
    stg_geolocation }o..o{ stg_sellers : "zip_code_prefix (not unique)"
```

Notes:
- `customer_id` is per order; use `customer_unique_id` to identify a real customer.
- `stg_geolocation` has many rows per zip prefix, so joining on it multiplies rows. Deduplicate it before joining.
