# Optional: one-page Tableau Public dashboard

Skip this if time is tight. The README and charts already answer the question. Build it only if you want an interactive version to link from LinkedIn.

## Data (no new SQL needed)
Connect to these three files in `results/` (Text file / CSV):
- `q7.csv`: one row per top-15 category (revenue, freight_pct, avg_delivery_days, late_pct, avg_review, action)
- `q5.csv`: one row per month (late_pct, avg_review)
- `q6.csv`: review score by days-late bucket

Do not join them. Use each as its own data source and its own sheet.

## Sheets
1. **Category map** (from `q7`): Columns = `revenue`, Rows = `freight_pct`, Mark = Circle, Color = `action`, Size = `avg_delivery_days`, Detail = `category`. Add reference lines at the median of each axis (Analytics pane > Reference line > Median). Label only: office_furniture, furniture_decor, housewares, bed_bath_table, watches_gifts.
2. **Late % by month** (from `q5`): Columns = `month` (continuous, month), Rows = `late_pct`, Mark = Bar. Second sheet below it with `avg_review` as a line. Two sheets on one shared timeline, not a dual axis.
3. **Review by days late** (from `q6`): Columns = `days_late_bucket`, Rows = `avg_review`, Mark = Bar, label the bars.

## Dashboard
- Size: Automatic, one page. Title: "Which Olist categories are worth their freight and delivery cost?"
- Layout: Category map on the left (about 60% width), the two supporting sheets stacked on the right.
- Add a text box with the three numbers: 76% of revenue in the top 15, R$3.3M at 20.5% freight, 48% of late orders in 3 months.
- Add the Q9 caveat under the review chart: "75% of late-order reviews were written before delivery. Without them the gap is about 0.8 stars, not 2.0."
- Keep the same colours as the README chart: Promote blue, Renegotiate freight orange, Fix delivery green, Deprioritize grey.

## Publish
File > Save to Tableau Public (needs a free account). Put the public link in the README under the answer block.
