# Table relationships

```mermaid
erDiagram
    stg_customers ||--|| stg_orders : "customer_id"
    stg_orders ||--o{ stg_order_payments : "order_id"
    stg_orders ||--o{ stg_order_reviews : "order_id"
    stg_orders ||--o{ stg_order_items : "order_id"
    stg_products ||--|{ stg_order_items : "product_id"
    stg_sellers ||--|{ stg_order_items : "seller_id"
    stg_category_translation |o--|{ stg_products : "product_category_name"
    stg_geolocation }o..o{ stg_customers : "zip_code_prefix (not unique)"
    stg_geolocation }o..o{ stg_sellers : "zip_code_prefix (not unique)"

    stg_customers {
        varchar customer_id PK
        varchar customer_unique_id "the real customer"
        varchar customer_zip_code_prefix
    }
    stg_orders {
        varchar order_id PK
        varchar customer_id FK
    }
    stg_order_items {
        varchar order_id PK, FK
        bigint order_item_id PK
        varchar product_id FK
        varchar seller_id FK
    }
    stg_order_payments {
        varchar order_id PK, FK
        bigint payment_sequential PK
    }
    stg_order_reviews {
        varchar review_id PK
        varchar order_id PK, FK
    }
    stg_products {
        varchar product_id PK
        varchar product_category_name FK
    }
    stg_sellers {
        varchar seller_id PK
        varchar seller_zip_code_prefix
    }
    stg_category_translation {
        varchar product_category_name PK
        varchar product_category_name_english
    }
    stg_geolocation {
        varchar geolocation_zip_code_prefix "not unique"
    }
```

Cardinalities are taken from the loaded data (see [profiling.md](profiling.md)).

Notes:
- `customer_id` is per order, so customers to orders is 1:1; use `customer_unique_id` to identify a real customer.
- 775 orders have no items, 1 order has no payment, and 768 orders have no review.
- `review_id` alone is not unique (789 duplicates) because one review can cover several orders; `(review_id, order_id)` is unique, and 547 orders have more than one review.
- A product has zero or one English category: 610 products have no category and 13 have a category missing from the translation table (`pc_gamer`, `portateis_cozinha_e_preparadores_de_alimentos`).
- `stg_geolocation` has many rows per zip prefix, so joining on it multiplies rows.
  Deduplicate it before joining.
  157 customer zip prefixes and 7 seller zip prefixes have no geolocation row.
