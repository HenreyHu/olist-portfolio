# Data issues

Notes from `docs/profiling.md` and `docs/erd.md`, filtered to what actually affects the main question (revenue, freight %, and late-delivery rate by category) and the supporting question (does late delivery lower review scores).

| Issue | Rows affected | Why it matters |
|---|---:|---|
| No `order_delivered_customer_date` | 2,965 orders | "Late" is defined as delivered date vs. estimated date. No delivered date means no way to classify the order as on-time or late, which directly breaks the late-delivery measure and feeds straight into H2 (late delivery vs. review score). |
| Duplicate `review_id`s / orders with multiple reviews | 789 duplicate `review_id`s, 547 orders with >1 review | `review_id` alone isn't unique. A naive join of reviews to orders double-counts rows and skews the average review score, which also feeds H2. Need to join on `(review_id, order_id)`, not `review_id`. |
| Products with no category / category missing translation | 610 products with no category, 13 categories with no English translation | The whole analysis groups by category. These products either need an explicit "unknown" bucket or get dropped — either choice changes the revenue-by-category totals, so the decision needs to be stated, not silent. |
| Orders with no items / no payment | 775 orders with no items, 1 order with no payment | An order with no items has no revenue line and no category, so an inner join to `order_items` naturally drops it from the category analysis — this isn't a bug to fix, just worth documenting so it's clear why the row count changes between `orders` and the revenue table. |
| `shipping_limit_date` extends to 2020 while orders stop in Oct 2018 | — | Flagged as a data-quality oddity, but it doesn't touch the core metrics: lateness is measured off `order_delivered_customer_date` vs. `order_estimated_delivery_date`, not `shipping_limit_date`. Noted so it's clear this was seen and deliberately not treated as a fix-it item. |
| Payments with 0 installments or 0 value | — | More relevant to the Week 2 revenue/payment reconciliation (`SUM(price + freight_value)` vs. `SUM(payment_value)`) than to the category-level revenue/freight/lateness metric. Mentioned briefly here, addressed properly in the reconciliation step. |
| `customer_city` has 4,119 spellings | — | Only matters for geographic grouping, which isn't part of the main or supporting question. Flagged for later, not blocking Week 1–3 work. |

**Priority for cleaning (Week 2):** delivery-date nulls, review duplicates, and missing categories are the three that would silently distort the main question's numbers if left unhandled — these get fixed first. The rest are documented but not blocking.
