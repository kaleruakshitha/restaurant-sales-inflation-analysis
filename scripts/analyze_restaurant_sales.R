# Reconstructed base R implementation of the documented restaurant sales workflow.
# Runs with base R; inputs required from FRED at the paths below.
# Current FRED downloads may differ from the report's Sept 29, 2026 snapshot.

sales_path <- 'data/raw/MRTSSM722USS.csv'
cpi_path <- 'data/raw/CUSR0000SEFV.csv'
if (!file.exists(sales_path) || !file.exists(cpi_path)) {
  stop('Download both FRED CSV series into data/raw/ first. See README.md.')
}
sales <- read.csv(sales_path, stringsAsFactors = FALSE, check.names = FALSE)
cpi <- read.csv(cpi_path, stringsAsFactors = FALSE, check.names = FALSE)
parse_fred <- function(df, value_name) {
  if (!('observation_date' %in% names(df))) stop('CSV requires observation_date column')
  measure <- setdiff(names(df), 'observation_date')
  if (length(measure) != 1L) stop('Expected exactly one FRED value column')
  out <- data.frame(observation_date = as.Date(df$observation_date),
                    value = suppressWarnings(as.numeric(df[[measure]])))
  if (anyNA(out$observation_date) || anyDuplicated(out$observation_date)) {
    stop('Invalid or duplicate observation_date values')
  }
  names(out)[2] <- value_name
  out
}
sales <- parse_fred(sales, 'nominal_sales')
cpi <- parse_fred(cpi, 'cpi')
sales <- sales[sales$observation_date >= as.Date('2010-01-01') &
                 sales$observation_date <= as.Date('2026-07-01'), ]
if (any(!is.finite(sales$nominal_sales) | sales$nominal_sales <= 0)) stop('Invalid sales')
if (any(!is.na(cpi$cpi) & (cpi$cpi <= 0 | !is.finite(cpi$cpi)))) stop('Invalid CPI')
# Order from original sales, rather than dropping months with absent CPI.
x <- merge(sales, cpi, by='observation_date', all.x=TRUE, sort=FALSE)
x <- x[order(x$observation_date), ]
stopifnot(nrow(x) == nrow(sales), !anyDuplicated(x$observation_date))
base_date <- as.Date('2019-01-01')
base <- x[x$observation_date == base_date, ]
if (nrow(base) != 1 || is.na(base$cpi)) stop('January 2019 base CPI unavailable')
x$real_sales <- x$nominal_sales * base$cpi / x$cpi
x$reported_index <- 100 * x$nominal_sales / base$nominal_sales
x$real_index <- 100 * x$real_sales / base$nominal_sales
# The exact date one calendar year earlier, including leap-year safety.
previous_year_date <- function(d) as.Date(sprintf('%s-%s', as.integer(format(d,'%Y'))-1L, format(d,'%m-%d')))
prior <- match(previous_year_date(x$observation_date), x$observation_date)
yoy <- function(z) 100 * (z / z[prior] - 1)
x$reported_growth_pct <- yoy(x$nominal_sales)
x$inflation_pct <- yoy(x$cpi)
x$real_growth_pct <- yoy(x$real_sales)
# Ratio identity is checked only where all three are known.
ok <- complete.cases(x[, c('reported_growth_pct','inflation_pct','real_growth_pct')])
check <- 100 * ((1 + x$reported_growth_pct[ok]/100) /
                (1 + x$inflation_pct[ok]/100) - 1)
stopifnot(all(abs(check - x$real_growth_pct[ok]) < 1e-8))
stopifnot(abs(x$real_sales[x$observation_date==base_date] - base$nominal_sales) < 1e-8)
dir.create('outputs', recursive=TRUE, showWarnings=FALSE)
write.csv(x, 'outputs/monthly_analysis.csv', row.names=FALSE, na='')
latest <- tail(x,1)
write.csv(latest, 'outputs/latest_month_summary.csv', row.names=FALSE, na='')
png('outputs/adjusted_sales.png', width=1100, height=600)
plot(x$observation_date, x$real_sales/1000, type='l', col='steelblue', lwd=2,
     main='US Food Services Sales: January 2019 Dollars', xlab='Month', ylab='Billions of dollars')
dev.off()
png('outputs/sales_indices.png', width=1100, height=600)
plot(x$observation_date, x$reported_index, type='l', lwd=2, col='black',
     main='Reported vs Inflation-Adjusted Sales (January 2019 = 100)',
     xlab='Month', ylab='Index')
lines(x$observation_date, x$real_index, col='steelblue', lwd=2)
legend('topleft', legend=c('Reported','Adjusted'), col=c('black','steelblue'), lty=1, bty='n')
dev.off()
cat(sprintf('Wrote %d monthly rows; %d usable sales/CPI pairs.\n', nrow(x), sum(!is.na(x$cpi))))
