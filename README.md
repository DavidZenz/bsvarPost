# bsvarPost

`bsvarPost` is a companion post-estimation toolkit for
[`bsvars`](https://cran.r-project.org/package=bsvars) and
[`bsvarSIGNs`](https://cran.r-project.org/package=bsvarSIGNs).

It focuses on the layer after estimation:

- cumulative dynamic multipliers via `cdm()`
- tidy extractors for posterior objects
- comparison helpers across multiple models
- `ggplot2` plotting for tidy outputs
- optional `tsibble` conversion for tidy outputs
- bridge helpers for APRScenario-style forecast tables
- representative-model summaries and posterior audit helpers

## Installation

From GitHub:

```r
install.packages(c("bsvars", "bsvarSIGNs"))
remotes::install_github("DavidZenz/bsvarPost")
```

## `bsvars` example

```r
library(bsvars)
library(bsvarPost)

data(us_fiscal_lsuw)
set.seed(1)

spec <- specify_bsvar$new(us_fiscal_lsuw, p = 1)
post <- estimate(spec, S = 100, thin = 1, show_progress = FALSE)

cdm_obj <- cdm(post, horizon = 8)
summary(cdm_obj)
plot(cdm_obj)

irf_tbl <- tidy_irf(post, horizon = 8)
cdm_tbl <- tidy_cdm(post, horizon = 8)
fevd_tbl <- tidy_fevd(post, horizon = 8)
fc_tbl <- tidy_forecast(post, horizon = 8)

ggplot2::autoplot(cdm_tbl)
```

Representative-model summaries and posterior probability statements:

```r
rep_irf <- median_target_irf(post, horizon = 8)
summary(rep_irf)
plot(rep_irf)

hypothesis_irf(post, variable = 1, shock = 1, horizon = 4, relation = ">", value = 0)
magnitude_audit(post, type = "cdm", variable = 1, shock = 1, horizon = 8, relation = ">", value = 0)
```

Response-shape summaries:

```r
peak_tbl <- peak_response(
  post,
  type = "irf",
  horizon = 8,
  variable = 1,
  shock = 1
)
peak_tbl

duration_tbl <- duration_response(
  post,
  type = "cdm",
  horizon = 8,
  variable = 1,
  shock = 1,
  relation = ">",
  value = 0,
  mode = "total"
)
duration_tbl

half_life_tbl <- half_life_response(
  post,
  type = "irf",
  horizon = 8,
  variable = 1,
  shock = 1,
  baseline = "peak"
)
half_life_tbl

time_tbl <- time_to_threshold(
  post,
  type = "cdm",
  horizon = 8,
  variable = 1,
  shock = 1,
  relation = ">",
  value = 0
)
time_tbl
```

The same summaries can be compared across several models:

```r
compare_peak_response(
  baseline = post,
  alternative = post,
  type = "irf",
  horizon = 8,
  variable = 1,
  shock = 1
)

compare_duration_response(
  baseline = post,
  alternative = post,
  type = "cdm",
  horizon = 8,
  variable = 1,
  shock = 1,
  relation = ">",
  value = 0,
  mode = "total"
)

compare_half_life_response(
  baseline = post,
  alternative = post,
  type = "irf",
  horizon = 8,
  variable = 1,
  shock = 1,
  baseline = "peak"
)

compare_time_to_threshold(
  baseline = post,
  alternative = post,
  type = "cdm",
  horizon = 8,
  variable = 1,
  shock = 1,
  relation = ">",
  value = 0
)
```

Optional normalization:

```r
cdm_scaled <- cdm(post, horizon = 8, scale_by = "shock_sd")
```

## `bsvarSIGNs` example

```r
library(bsvarSIGNs)
library(bsvarPost)

data(optimism)

sign_irf <- matrix(c(0, 1, rep(NA, 23)), 5, 5)

spec <- specify_bsvarSIGN$new(
  optimism * 100,
  p = 4,
  sign_irf = sign_irf
)

post <- estimate(spec, S = 100, thin = 1, show_progress = FALSE)

cdm_obj <- cdm(post, horizon = 12)
summary(cdm_obj)

irf_tbl <- tidy_irf(post, horizon = 12)
cdm_tbl <- tidy_cdm(post, horizon = 12)

ggplot2::autoplot(irf_tbl)
ggplot2::autoplot(cdm_tbl)
```

Representative sign-restricted summaries and restriction auditing:

```r
rep_irf <- most_likely_admissible_irf(post, horizon = 12)
summary(rep_irf)

audit_tbl <- restriction_audit(post)
audit_tbl
```

## Model comparison

```r
cmp <- compare_cdm(
  baseline = post,
  alternative = post,
  horizon = 8
)

ggplot2::autoplot(cmp)
```

Restriction comparisons:

```r
compare_restrictions(model_a = post, model_b = post, restrictions = list(
  irf_restriction(variable = 1, shock = 1, horizon = 0, sign = 1)
))
```

## Historical decomposition events

```r
hd_event <- tidy_hd_event(post, start = 1, end = 4)
shock_ranking(post, start = 1, end = 4, ranking = "absolute")

plot_hd_event(post, start = 1, end = 4)
plot_shock_ranking(post, start = 1, end = 4, ranking = "absolute", top_n = 5)
```

Event-window comparisons:

```r
compare_hd_event(model_a = post, model_b = post, start = 1, end = 4)
```

## `tsibble` bridge

If `tsibble` is installed:

```r
library(tsibble)

fc_tbl <- tidy_forecast(post, horizon = 8)
fc_tsbl <- as_tsibble_post(fc_tbl)
```

For IRF/CDM/FEVD outputs, `horizon` is used as the tsibble index and
`model`/`variable`/`shock` columns are used as keys when available.

## APRScenario bridge

APRScenario expects forecast summaries with columns:

- `hor`
- `variable`
- `lower`
- `center`
- `upper`

Convert a `bsvarPost` forecast summary into that shape with:

```r
fc_tbl <- tidy_forecast(post, horizon = 8)

apr_tbl <- as_apr_cond_forc(
  fc_tbl,
  origin = as.Date("2024-01-01"),
  frequency = "quarter"
)
```

Convert an APRScenario-style table back into a `bsvarPost` tidy table with:

```r
fc_tbl <- tidy_apr_forecast(apr_tbl)
ggplot2::autoplot(fc_tbl)
```

If `APRScenario` is installed, `apr_gen_mats()` forwards to
`APRScenario::gen_mats()`.

```r
if (requireNamespace("APRScenario", quietly = TRUE)) {
  mats <- apr_gen_mats(post, specification = spec)
}
```
