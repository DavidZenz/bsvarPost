# Autoplot tidy posterior outputs

Autoplot tidy posterior outputs

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

  A `bsvar_post_tbl` returned by the tidy or comparison helpers.

- variables:

  Optional variable filter.

- shocks:

  Optional shock filter.

- models:

  Optional model filter.

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
