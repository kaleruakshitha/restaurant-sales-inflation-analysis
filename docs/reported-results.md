# Results documented in the October 2026 project report

**Saved source snapshot:** September 29, 2026. All results belong to this snapshot and may differ after data revisions.

| Month | Reported sales ($bn) | Adjusted sales (January 2019 $bn) | Reported index | Adjusted index |
| --- | ---: | ---: | ---: | ---: |
| January 2019 | 60.194 | 60.194 | 100.00 | 100.00 |
| July 2025 | 98.691 | 72.096 | 163.95 | 119.77 |
| July 2026 | 103.824 | 73.351 | 172.48 | 121.86 |

July 2026 year over year: reported sales **+5.201%**; food-away-from-home CPI **+3.400%**; adjusted sales **+1.741%**.

The 3.46-percentage-point difference between nominal and adjusted growth is *not* the inflation rate itself. Exact growth decomposition uses `(1 + reported_growth) / (1 + CPI_growth) - 1`. October 2025 CPI was missing in the saved dataset; no interpolation was used. Adjusted revenue does not measure physical sales volume, transactions, same-store growth, or profit.

The source report documents calculations independently checked in Python. The final R export script was reviewed but not rerun in the report-building environment. Code in this repository is a reconstructed version, not the original script.
