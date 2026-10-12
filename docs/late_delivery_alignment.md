# Late-delivery data alignment checks

Why the late-delivery numbers can't be trusted yet, and what to decide before writing `sql/03_analysis.sql`.

**How these figures were found:** a quick pass in pandas over the raw CSVs in `data/raw/`. Treat them as pointers, not results: reproduce each one in SQL and use your own numbers in the README. Figures marked "window" use delivered orders purchased Jan 2017 to Aug 2018.

## 1. "Late" is defined too strictly

`order_estimated_delivery_date` is always midnight (00:00). Comparing timestamps means any delivery on the promised day, after midnight, counts as late.

| Definition | Late % (all delivered orders with a date) |
|---|---:|
| `delivered_ts > estimated_ts` | 8.11% (7,827 of 96,476) |
| `DATE(delivered) > DATE(estimated)` | 6.77% |

**Decision:** use the date-level definition and write it at the top of `03_analysis.sql`.

## 2. Raw CSV dates are `d/m/yyyy`, not ISO

The raw files hold values like `24/7/2018 20:41`. DuckDB's `read_csv_auto` parsed them correctly (your profile ranges match). Reading the same files in pandas without `dayfirst=True` gives about 23.6% late instead of 8.1%, so anyone reproducing in Python gets a wrong answer without an error.

**Decision:** pass an explicit `dateformat`/`timestampformat` in `01_load_staging.sql`, and note it in the README's Reproduce section.

## 3. Lateness is driven by when the order was placed

Late % by purchase month (all delivered orders): most months sit at about 1–8%, with spikes in Nov 2017 (14.3%), Feb 2018 (16.0%) and Mar 2018 (21.4%). Late % by category is flat by comparison: across the top 20 categories (window) it ranges about 4.6–8.0%, while freight % ranges about 4.4–25% and average delivery time about 10.8–20.8 days.

**What it means:** late % alone barely separates categories, so a chart sized by late % would show noise. Freight % and delivery days separate them; lateness is better told as a time story plus a review-score story.

**Decision:** run the monthly late % and the top-15 spread check first (Week 3A), then pick the bubble-size metric.

## 4. Thin months at both ends

2016 has about 330 orders in total (Dec 2016 has 1). Sep–Oct 2018 has about 20 orders and none delivered. A single order gives 100% late for Sep 2016 and distorts `LAG` month-over-month growth for Jan 2017.

**Decision:** analysis window = orders purchased Jan 2017 to Aug 2018.

## 5. Lateness is per order, category is per item

`order_items` has one row per item. About 9,800 orders have more than one item, about 786 span more than one category and about 1,278 have more than one seller. An order has a single delivered date even when several sellers ship separately, so lateness can't be pinned to a specific item or seller.

**Decision:** pick a grain rule (count each item as late if its order was late, or restrict to single-category orders), write it down, and join order-level fields to items (not the other way) so revenue isn't double-counted.

## 6. Review timing mixes two stories

About 5,100 of 95,830 reviewed delivered orders have a review created before the delivered date, and about 4,770 of those are late orders. Their average score is about 1.85 (customer complaining the parcel hasn't arrived). Late vs on-time average scores (window) are about 2.27 vs 4.29.

**Decision:** keep them but report the late vs on-time gap with and without early reviews. Also: 547 orders have more than one review and 646 delivered orders have none; average per order before joining.

## 7. Small timestamp inconsistencies (log them)

| Issue | Orders |
|---|---:|
| `canceled` status but has a delivered date | 6 |
| Delivered before carrier pickup | 23 |
| Carrier pickup before purchase | 161 |
| `delivered` status, no delivered date (already logged) | 8 |

**Decision:** exclude from lateness (they're not usable), add rows to `data_issues_log`.

## 8. The promise is padded

Median estimated delivery is about 23 days after purchase; median actual delivery is about 10 days. Only about 7% are late because the estimate is generous, not because shipping is fast everywhere. Say this in the Limitations section and consider average delivery days as a second delivery measure.
