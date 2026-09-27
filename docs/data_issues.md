# Data issues

Notes from `docs/profiling.md` and `docs/erd.md`, filtered to what actually affects the main question (revenue, freight %, and late-delivery rate by category) and the supporting question (does late delivery lower review scores).

## Week 1: profiling findings

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

## Week 2: cleaning decisions

Full detail and the exact fix for each row is in `data_issues_log` (built inside `sql/02_cleaning.sql`). Summary:

| Table(s) | Issue | Rows | Decision |
|---|---|---:|---|
| `stg_geolocation` | Lat/lng values outside Brazil's bounds (lat up to 45.07, lng up to 121.11) | 1,000,163 | Excluded from the clean layer entirely — not needed for the revenue/freight question. |
| `stg_sellers` | `seller_city` has inconsistent formatting: state codes appended, a zip code value, at least one typo | 3,095 | Not standardized — city text isn't used in the analysis. Whitespace trimmed only. |
| `stg_customers` | `customer_city` has 4,119 distinct spellings/formats | 99,441 | Same as above — trimmed only, not standardized. |
| `stg_products` | 2 products missing weight/dimensions entirely | 2 | Kept as `NULL` — negligible count, not used in the main analysis. |
| `stg_orders` | Missing `order_delivered_customer_date`; 2,957 of these have a non-delivered status | 2,957 | No fix needed — these orders never delivered, so they're naturally excluded from the lateness calculation. |
| `stg_orders` | Missing `order_delivered_customer_date` despite `order_status = delivered` | 8 | Kept as `NULL`, flagged as a genuine inconsistency — lateness can't be computed for these 8 orders. |
| `stg_order_payments` | `payment_value = 0`: 6 rows are `voucher` (plausible — voucher covered the full amount), 3 are `not_defined` | 9 | Kept as-is — voucher rows are legitimate; `not_defined` rows flagged but not excluded (negligible count). |
| `stg_products` | 610 products with no category, plus 13 whose category has no match in the translation table (`pc_gamer`, `portateis_cozinha_e_preparadores_de_alimentos`) | 623 | Bucketed uniformly as `'unknown'` via `COALESCE` on a `LEFT JOIN`. Verified no row fan-out (still 32,951 products). |
| `stg_orders` | Checked for orders delivered before purchase | 0 | None found — no fix needed. |
| `stg_order_payments` | `payment_installments = 0`, both rows `payment_type = credit_card` | 2 | Kept as-is — negligible count, doesn't affect the reconciliation buckets below. |
| `stg_order_items` | `shipping_limit_date` extends to 2020-04-09 while orders stop in Oct 2018 | 4 | No fix applied — not used in lateness or reconciliation calculations. |

### Reconciliation (`SUM(price + freight_value)` vs. `SUM(payment_value)` per order)

Each side aggregated separately before joining (joining at the item/payment grain first would fan out the rows and inflate totals). Mismatches sorted into three groups:

| Bucket | Orders | Total value | Explanation |
|---|---:|---:|---|
| Rounding | 317 | -$0.69 | Sub-10-cent floating-point noise, not a real discrepancy. |
| Installment interest | 235 | +$3,063.40 | Customer paid more than the order total; `payment_installments > 1` — expected financing interest. |
| Unexplained | 24 | -$192.32 | No identifiable cause. A genuine, small residual worth flagging — not attributable to installment interest or a voucher. |

A separate "voucher" bucket was tried but dropped: every voucher-flagged mismatch turned out to be rounding-sized (≤ a few cents), so those rows landed in the rounding bucket instead.
