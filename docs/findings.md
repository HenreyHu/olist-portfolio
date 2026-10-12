# Findings (Week 3)

Scope: delivered orders purchased Jan 2017 to Aug 2018 (96,203 orders). Late = delivered date after estimated date, compared at date level. Sources: `results/q1.csv` to `q9.csv`.

**Q1 - Category summary.** The 15 biggest categories make about 76% of revenue. Health & beauty (9.3%) and watches & gifts (8.8%) lead, but watches & gifts pays only 8.4% of price in freight against 14.5% for health & beauty. Late % barely differs across the top 15 (5.4% to 8.1%).

**Q2 - Candidates.** Furniture & decor, housewares, telephony and office furniture are in the top 15 on both revenue and freight %, at 22.4% to 25.0% of price. Late % does not separate them from other categories, so freight is the main cost signal. Office furniture is the outlier on delivery: 20.5 days on average (others 11 to 13.6) and the lowest review score (3.65).

**Q3 - Trend.** Revenue grew through 2017 and peaked in Nov 2017 (+52.4% on October), then fell 26.5% in December. Growth is calculated inside the Jan 2017 to Aug 2018 window only.

**Q4 - Reviews.** Late orders average 2.27 stars against 4.29 for on-time orders, a gap of about 2 stars. 6.8% of delivered orders are late.

**Q5 - Lateness over time.** Lateness is driven by when the order was placed. Most months sit at 3% to 7% late, but Nov 2017 (12.4%), Feb 2018 (14.1%) and Mar 2018 (19.0%) spike, and review scores dip in the same months.

**Q6 - Days late.** Review score falls with each extra delay: 4.29 on time, 3.29 for 1 to 3 days late, 2.11 for 4 to 7 days, 1.70 for 8+ days. This is correlation, not proof of cause.

**Q7 - Action labels (top 15 categories).** Rule: high freight = above the median freight % of the 15, high revenue = at or above their median revenue, slow = delivery days above 1.25 x the median. Promote (8): health & beauty, watches & gifts, computers & accessories, cool stuff, auto, toys, baby, perfumery. Renegotiate freight (4): bed/bath/table, sports & leisure, furniture & decor, housewares. Deprioritize (2): garden tools, telephony. Fix delivery (1): office furniture.

**Q8 - Exposure.** Of $10.06M revenue in the top 15: Promote $5.72M (56.8%, freight 13.7%), Renegotiate freight $3.30M (32.8%, freight $674K at 20.5% of price), Deprioritize $0.78M (7.7%, freight 21.3%), Fix delivery $0.27M (2.7%, freight 25.0%, 8.1% late). The Renegotiate group is where freight terms matter most.

**Q9 - Review timing.** 5,119 reviews were written before the delivered date, 4,775 of them on late orders (about 75% of all late-order reviews, averaging 1.84 stars). Excluding them, late orders average 3.52 against 4.29 on time, so the gap is about 0.8 stars rather than 2.0. Report both: early reviews likely reflect customers complaining while still waiting, so lateness still hurts, but the 2-star headline overstates it.

**Limitation.** No cost of goods in the dataset, so freight % of price stands in for margin.
