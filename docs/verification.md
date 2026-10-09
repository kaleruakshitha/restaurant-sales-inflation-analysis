# Original snapshot verification — October 2026

This repository now uses the original R script recovered from `Restaurant_Sales_and_Inflation_Project(1).zip`.

The saved September 29, 2026 project ZIP includes two original FRED CSV inputs, 199-row processed output, three published PNG charts, PDF/DOCX report, summary and validation record.

## Independently checked

- SHA-256 for source sales CSV: `7d14e9d8112e49bccad0ff241b5baee9b5c6695fc106fe617e7ceef7a89b22f1`
- SHA-256 for source CPI CSV: `0306d96144fcc110660c545779de68b2d9109f7f9fbea7ed43da43235210ab94`
- 199 sales rows, 200 CPI rows and 198 nonmissing matched price/sales observations
- October 2025 CPI stays missing, with adjusted sales also missing
- An independent pandas calculation reproduces the original saved processed data: maximum absolute differences are less than 1e-10 in all calculated numeric fields (for the 199-month snapshot)
- July 2026 reported sales: $103.824 billion; adjusted sales: $73.3514248637 billion; nominal year-over-year growth 5.201082%, price index change 3.400398%, adjusted growth 1.741467%

## Important distinction

The original R script was restored from the source ZIP and reviewed, but was **not rerun** with R here because Rscript was unavailable. The Python calculations agree with the saved output. The current GitHub repository does not yet include the original PNG report figures or the input snapshots; the provided ZIP retains them.

This is a descriptive time-series comparison and not a forecast, causal inflation study or analysis of profits or visits.
