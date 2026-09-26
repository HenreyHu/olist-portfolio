# Data dictionary

One entry per staging table: what it holds, what one row represents (grain), and its keys. Keys are taken from `docs/erd.md`.

## stg_customers
**Purpose:** one delivery address/profile used for a single order.
**Grain:** one row per `customer_id` — note that `customer_id` is generated per order, so it is *not* the same as a unique person. Use `customer_unique_id` (96,096 distinct vs. 99,441 `customer_id`s) to identify a real repeat customer.
**Keys:** PK `customer_id`.

## stg_orders
**Purpose:** one purchase order placed by a customer, with its status and the four lifecycle timestamps (approved, handed to carrier, delivered, estimated delivery).
**Grain:** one row per order.
**Keys:** PK `order_id` · FK `customer_id` → `stg_customers`.

## stg_order_items
**Purpose:** one line item within an order — a single product/seller pairing bought in that order, with its price and freight cost.
**Grain:** one row per item per order (an order with 3 products is 3 rows, not 1) — this is the fan-out trap: summing `price` without grouping by order first will overcount if you've joined in anything at the order grain.
**Keys:** PK `(order_id, order_item_id)` · FK `order_id` → `stg_orders` · FK `product_id` → `stg_products` · FK `seller_id` → `stg_sellers`.

## stg_order_payments
**Purpose:** one payment installment/method applied to an order (an order can be split across multiple payment methods or installments).
**Grain:** one row per payment sequence per order.
**Keys:** PK `(order_id, payment_sequential)` · FK `order_id` → `stg_orders`.

## stg_order_reviews
**Purpose:** one customer review left for an order.
**Grain:** one row per review-order pairing, *not* one row per review — `review_id` alone has 789 duplicates because a single review can cover more than one order. `(review_id, order_id)` is the real unique combination.
**Keys:** PK `(review_id, order_id)` · FK `order_id` → `stg_orders`.

## stg_products
**Purpose:** one product listing, its category, and physical dimensions/weight.
**Grain:** one row per product.
**Keys:** PK `product_id` · FK `product_category_name` → `stg_category_translation`.

## stg_sellers
**Purpose:** one seller/marketplace vendor and their location.
**Grain:** one row per seller.
**Keys:** PK `seller_id`.

## stg_category_translation
**Purpose:** maps the Portuguese product category name to its English translation.
**Grain:** one row per category name.
**Keys:** PK `product_category_name`.

## stg_geolocation
**Purpose:** lat/lng sightings tied to a zip code prefix.
**Grain:** one row per lat/lng sighting per zip prefix — there is no real primary key, and many rows share the same zip prefix. Deduplicate before joining, or a join to `customers`/`sellers` on zip prefix will multiply rows.
**Keys:** none (no unique key) · joined to `stg_customers`/`stg_sellers` on zip code prefix (not a formal FK — the relationship isn't 1:1).
