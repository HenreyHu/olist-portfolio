# Act: what Olist should do

Sources: `results/q1.csv` to `q11_peak_months.csv`. Currency is Brazilian reais (R$). Top 15 categories = R$10.06M, 76% of R$13.2M total revenue.

## Recommendations

**1. Renegotiate freight terms for bed/bath/table, sports & leisure, furniture & decor and housewares.**
- Owner: ops / seller management, with finance.
- Size: R$3.30M revenue (33% of the top 15), R$674K freight at 20.5% of price, against 13.7% for the Promote group (Q8).
- Confidence: medium-low. No carrier cost data, and bulky goods have a physical freight floor, so the median may not be reachable for furniture or housewares.

**2. Fix delivery where it is concentrated: peak months and office furniture.**
- Owner: ops / logistics.
- Size: Nov 2017, Feb 2018 and Mar 2018 hold 3,159 late orders, 48% of all 6,544 (Q5). About 2,283 of them are above what a normal month (4.2% late) would produce. Office furniture: R$267K, 1,248 orders, 20.5 days on average (others 11.0 to 13.6), 3.65 stars, 8.1% late (Q7).
- Confidence: medium on the timing, low on the cause. Nov 2017 follows a volume jump (7,288 orders vs 4,478 in Oct), but Feb and Mar 2018 do not (6,555 and 7,003 vs 7,069 in Jan), so volume alone does not explain it. Seller and carrier data would.

**3. Promote the 8 low-freight categories; hold garden tools and telephony.**
- Owner: marketing / category management, with finance.
- Size: Promote = R$5.72M (57% of top 15), 13.7% freight. Lead with watches & gifts (R$1.16M, 8.4% freight) and health & beauty (R$1.23M, 14.5%). Deprioritize = R$0.78M at 21.3% freight (Q8).
- Confidence: low-medium. Low freight % is not high margin; cost of goods is missing.

## Impact scenario (not a forecast)

If each above-median category's freight % fell to the top-15 median of 16.6% on the same orders (`results/q10_freight_scenario.csv`):

| Scope | Half the gap closed | Full gap closed |
|---|---:|---:|
| 4 Renegotiate categories | R$64K | R$127K |
| All 7 above-median categories | R$93K | R$186K |

Furniture & decor (R$50K) and housewares (R$41K) are the biggest pieces of the full-gap case. Review effects are correlation, not proof of cause.

## Next steps and missing data
- Cost of goods per category, to replace freight % with real margin.
- Carrier cost per shipment, to tell what Olist pays from what the customer is charged.
- Promised vs actual shipping time per seller, to find where the Nov and Feb–Mar delays happened.
- Run the 60-second test: a friend reads the top of the README and repeats the conclusion.

## Resume bullets
- Analysed 96K delivered marketplace orders (Jan 2017 to Aug 2018) across 9 tables in SQL (DuckDB); ranked 15 categories (76% of revenue) by freight and delivery cost, flagging 4 categories with R$3.3M of revenue at 20.5% of price in freight and sizing a R$64K to R$127K freight-reduction scenario.
- Showed late delivery is time-driven, not category-driven: 3 of 20 months held 48% of late orders, and late orders scored 2.27 vs 4.29 stars (0.8-star gap after excluding reviews written before delivery).
- Optional third, from Week 2: reconciled order totals against payments, with only 24 of ~99K orders left unexplained after separating rounding and installment interest.

## LinkedIn post
Main chart, one line ("Seven of Olist's top 15 categories ship at above-median freight, holding R$4.3M of revenue; lateness comes from 3 bad months, not bad categories"), link to the repo.
