# Plot comparison summaries for restriction-audit tables

Plot comparison summaries for restriction-audit tables

## Usage

``` r
plot_compare_restrictions(
  object,
  models = NULL,
  restriction_types = NULL,
  top_n = NULL
)
```

## Arguments

- object:

  A comparison table returned by
  [`compare_restrictions()`](https://davidzenz.github.io/bsvarPost/reference/compare_restrictions.md).

- models:

  Optional model filter.

- restriction_types:

  Optional restriction-type filter.

- top_n:

  Optional number of highest-probability restrictions to keep within
  each model.

## Value

A `ggplot` object.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post1 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
post2 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

r <- list(irf_restriction("gdp", "gdp", 0, sign = 1))
comp <- compare_restrictions(m1 = post1, m2 = post2, restrictions = r)
p <- plot_compare_restrictions(comp)
```
