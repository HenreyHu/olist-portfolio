# Problem framing (Ask → Act)

| Step | What it means | Your plan |
|---|---|---|
| **Ask** | Define the problem, the stakeholder, and the questions | Week 1: problem statement, hypotheses (below) |
| **Prepare** | Find the data and check that it's usable | Week 1: download, profiling, ERD, data dictionary - done (`docs/profiling.md`, `docs/erd.md`) |
| **Process** | Clean the data and log the issues | Week 2: `sql/02_cleaning.sql`, `data_issues_log` |
| **Analyze** | Answer the questions | Week 3: `sql/03_analysis.sql` |
| **Share** | Present the findings | Week 4: charts, README |
| **Act** | Give recommendations | Week 4: the "answer first" part of the README |

## Ask

**Business task**
Olist's finance/ops leadership wants to know which product categories are worth the freight and delivery cost they carry, not just which categories bring in the most revenue.

**Stakeholder**
Finance/operations leadership at Olist (marketplace operator), deciding which categories to promote, renegotiate seller shipping terms for, or deprioritize.

**Primary question**
Which product categories bring in the most revenue but lose the most to freight cost and late delivery?

**Supporting question**
Does late delivery lower review scores?

**Hypotheses** *(to confirm or reject in Week 3, not assumed true)*
- H1: A handful of high-revenue categories also carry disproportionately high freight-to-price ratios (bulky/heavy goods costing more to ship relative to their price).
- H2: Categories with higher late-delivery rates have lower average review scores.

**Known limitation**
The dataset has no cost-of-goods field, so freight as a % of price is used as a stand-in for margin, not true profitability.
This is stated up front in the final README, not discovered halfway through.

**Why this framing, over "just find the best-selling category"**
Revenue-only ranking is descriptive: it says what sold, not what's worth prioritizing.
Weighing revenue against freight/delivery cost turns it into a decision-support question, and it still produces the best-selling ranking as an intermediate step (Week 3's revenue `RANK()`).
