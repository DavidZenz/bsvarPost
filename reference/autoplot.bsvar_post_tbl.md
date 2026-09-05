# Visualise posterior summaries

Visualise posterior summaries

## Usage

``` r
# S3 method for class 'bsvar_post_tbl'
autoplot(
  object,
  variables = NULL,
  shocks = NULL,
  models = NULL,
  facet_scales = "free_y",
  ...
)
```

## Arguments

- object:

  A `bsvar_post_tbl` containing posterior summaries or model
  comparisons.

- variables:

  Response variables to include.

- shocks:

  Structural shocks to include.

- models:

  Model specifications to include.

- facet_scales:

  Facet scales passed to `ggplot2`.

- ...:

  Unused.

## Value

A `ggplot` object.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

irf_tbl <- tidy_irf(post, horizon = 3)
p <- ggplot2::autoplot(irf_tbl)
```
