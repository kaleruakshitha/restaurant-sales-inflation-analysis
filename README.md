# Restaurant Sales Growth and Inflation (2010–2026)

**Independent business analytics project | Akshitha Kaleru | October 2026**

## Business question
Are U.S. food services and drinking places growing after accounting for rising food-away-from-home prices?

## Findings from the September 29, 2026 data snapshot

| Metric | July 2026 finding |
| --- | ---: |
| Reported monthly sales | $103.824 billion |
| Sales in January 2019 dollars | $73.351 billion |
| Reported year-over-year growth | 5.201% |
| Food-away-from-home CPI year-over-year change | 3.400% |
| Inflation-adjusted year-over-year growth | 1.741% |
| Reported growth since January 2019 | 72.48% |
| Adjusted growth since January 2019 | 21.86% |

**Takeaway:** Revenue growth remained positive after the approximate CPI adjustment, but was considerably smaller than nominal growth. This is not a measure of meals, customer traffic, profits, or causal inflation effects.

## Data sources
- US Census food services/drinking places sales: [FRED MRTSSM722USS](https://fred.stlouisfed.org/series/MRTSSM722USS), millions USD, seasonally adjusted
- BLS food-away-from-home CPI: [FRED CUSR0000SEFV](https://fred.stlouisfed.org/series/CUSR0000SEFV), 1982–84=100, seasonally adjusted

The project report used saved September 29, 2026 CSV files containing **199 sales observations** (January 2010–July 2026), and 200 CPI observations through August 2026. October 2025 CPI is unavailable in the preserved snapshot and is intentionally **not interpolated**. There are 198 valid paired months. Current FRED downloads may contain revisions or differ from the saved snapshot.

## Methods
1. Parse CSV dates and check for duplicate month keys.
2. Keep all sales months using a **left join** on observation date.
3. Set January 2019 CPI (=280.380 in saved snapshot) as the base period.
4. Compute `real_sales = nominal_sales × base_CPI / current_CPI`.
5. Express nominal and adjusted sales as indices relative to January 2019 (=100).
6. Compute year-over-year growth by matching exactly the same calendar month in the previous year (not by shifting after dropping missing values).
7. Check the growth ratio identity and preserve missing results.

No regression or forecasting model was fitted. CPI and sales coverage are not identical; deflation is an **approximation**.

## Reproducing the calculations

1. Download both CSV series from FRED. To reproduce the original report exactly, use the **September 29, 2026 snapshots**, including the October 2025 missing CPI observation. Otherwise results may reflect revised data.
2. Save them to `data/raw/MRTSSM722USS.csv` and `data/raw/CUSR0000SEFV.csv`.
3. From the project root, run:

```bash
Rscript scripts/analyze_restaurant_sales.R
```

The script uses **base R only**, checks data integrity, and writes CSV summary outputs and PNG charts to `outputs/`. It is a **reconstructed reference implementation** from the report, not a recovered copy of the original RStudio script. R execution using original source files has not been verified in this package.

## Skills demonstrated
**R and RStudio:** CSV ingestion, dates, validation, joins, vector calculations, time-series indexing, year-over-year comparisons, and visual communication. **Business interpretation:** separate price-level effects from reported revenue and avoid unsupported conclusions about demand or profit.

## Repository structure
- `scripts/analyze_restaurant_sales.R`: reconstructed base R pipeline
- `docs/reported-results.md`: documented analysis findings
- `data/raw/`: input folder, excluded from publication
- `outputs/`: locally generated tables/charts

## Important limitation
The exact original CSV snapshots, original R script, and figures from the completed report are not included. Reported results above came from the completed written analysis and should not be represented as newly reproduced until the original data snapshot is restored and run.