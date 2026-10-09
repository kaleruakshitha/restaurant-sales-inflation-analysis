# Restaurant sales and inflation project
# Run from the project root in RStudio: source("scripts/analyze_restaurant_sales.R")
# Uses base R only. Saved data snapshot downloaded September 29, 2026.

dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs", recursive = TRUE, showWarnings = FALSE)

sales <- read.csv("data/raw/MRTSSM722USS.csv", na.strings = c("", ".", "NA"))
cpi <- read.csv("data/raw/CUSR0000SEFV.csv", na.strings = c("", ".", "NA"))
sales$observation_date <- as.Date(sales$observation_date)
cpi$observation_date <- as.Date(cpi$observation_date)
stopifnot(!anyNA(sales$observation_date), !anyNA(cpi$observation_date))
stopifnot(!anyDuplicated(sales$observation_date), !anyDuplicated(cpi$observation_date))
stopifnot(is.numeric(sales$MRTSSM722USS), is.numeric(cpi$CUSR0000SEFV))
stopifnot(all(sales$MRTSSM722USS > 0), all(cpi$CUSR0000SEFV > 0, na.rm = TRUE))

monthly <- merge(sales, cpi, by = "observation_date", all.x = TRUE, sort = TRUE)
stopifnot(nrow(monthly) == nrow(sales))
base_month <- as.Date("2019-01-01")
base_row <- which(monthly$observation_date == base_month)
stopifnot(length(base_row) == 1L)
base_cpi <- monthly$CUSR0000SEFV[base_row]
base_sales <- monthly$MRTSSM722USS[base_row]
stopifnot(!is.na(base_cpi), base_cpi > 0)

monthly$real_sales <- monthly$MRTSSM722USS * base_cpi / monthly$CUSR0000SEFV
monthly$reported_index <- monthly$MRTSSM722USS / base_sales * 100
monthly$real_index <- monthly$real_sales / base_sales * 100

prior_dates <- as.Date(paste0(as.integer(format(monthly$observation_date, "%Y")) - 1,
                             format(monthly$observation_date, "-%m-%d")))
prior_rows <- match(prior_dates, monthly$observation_date)
monthly$reported_growth_pct <- (monthly$MRTSSM722USS /
                                 monthly$MRTSSM722USS[prior_rows] - 1) * 100
monthly$inflation_pct <- (monthly$CUSR0000SEFV /
                           monthly$CUSR0000SEFV[prior_rows] - 1) * 100
monthly$real_growth_pct <- (monthly$real_sales /
                             monthly$real_sales[prior_rows] - 1) * 100

valid <- !is.na(monthly$real_sales)
stopifnot(max(abs(monthly$real_sales[valid] * monthly$CUSR0000SEFV[valid] /
                    base_cpi - monthly$MRTSSM722USS[valid])) < 1e-7)
stopifnot(abs(monthly$real_sales[base_row] - base_sales) < 1e-7)
growth_check <- ((1 + monthly$reported_growth_pct/100) /
                  (1 + monthly$inflation_pct/100) - 1) * 100
stopifnot(max(abs(growth_check - monthly$real_growth_pct), na.rm = TRUE) < 1e-7)
stopifnot(identical(is.na(monthly$real_sales), is.na(monthly$CUSR0000SEFV)))

latest <- monthly[which.max(monthly$observation_date), ]
summary <- data.frame(
  latest_month = as.character(latest$observation_date),
  reported_sales_billions = latest$MRTSSM722USS/1000,
  real_sales_billions = latest$real_sales/1000,
  reported_growth_pct = latest$reported_growth_pct,
  inflation_pct = latest$inflation_pct,
  real_growth_pct = latest$real_growth_pct,
  reported_change_since_jan2019_pct = latest$reported_index - 100,
  real_change_since_jan2019_pct = latest$real_index - 100
)
write.csv(monthly, "data/processed/monthly_analysis.csv", row.names = FALSE, na = "")
write.csv(summary, "outputs/latest_month_summary.csv", row.names = FALSE)
write.csv(monthly[is.na(monthly$CUSR0000SEFV), ],
          "outputs/missing_price_months.csv", row.names = FALSE, na = "")
print(summary)
cat("Sales rows:", nrow(sales), " CPI rows:", nrow(cpi),
    " Valid pairs:", sum(valid), "\n")

png("outputs/figure_1_real_sales_R.png", width = 2200, height = 1300, res = 250)
par(mar = c(5, 5, 3, 1))
plot(monthly$observation_date, monthly$real_sales/1000, type = "l", col = "#087F8C",
     lwd = 2, xlab = "Year", ylab = "Billions of January 2019 dollars",
     main = "Restaurant sales adjusted for inflation",
     sub = "October 2025 unavailable because CPI is missing")
dev.off()

png("outputs/figure_2_sales_index_R.png", width = 2200, height = 1300, res = 250)
par(mar = c(5, 5, 3, 1))
plot(monthly$observation_date, monthly$reported_index, type = "l", col = "#245DE0",
     lwd = 2, ylim = range(c(monthly$reported_index, monthly$real_index), na.rm = TRUE),
     xlab = "Year", ylab = "Sales index January 2019 = 100",
     main = "Reported and inflation adjusted sales",
     sub = "Adjusted line has a gap in October 2025")
lines(monthly$observation_date, monthly$real_index, col = "#C3473C", lwd = 2)
abline(h = 100, lty = 2, col = "gray")
legend("topleft", c("Reported sales", "Inflation adjusted sales"),
       col = c("#245DE0", "#C3473C"), lwd = 2, bty = "n")
dev.off()

png("outputs/figure_3_july_growth_R.png", width = 2200, height = 1300, res = 250)
par(mar = c(6, 5, 3, 1))
values <- c(latest$reported_growth_pct, latest$inflation_pct, latest$real_growth_pct)
positions <- barplot(values, names.arg = c("Reported sales", "Price index", "Adjusted sales"),
        col = c("#245DE0", "#B77714", "#087F8C"), ylim = c(0, max(values) * 1.25),
        ylab = "Year over year percent change", main = "July 2026 compared with July 2025")
text(positions, values, labels = paste0(round(values, 2), "%"), pos = 3)
dev.off()

cat("Saved processed data and all three charts.\n")
