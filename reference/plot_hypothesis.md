# Plot posterior probability statements for IRFs or CDMs

Plot posterior probability statements for IRFs or CDMs

## Usage

``` r
plot_hypothesis(
  object,
  type = c("irf", "cdm"),
  variable = NULL,
  shock = NULL,
  horizon = NULL,
  relation = c("<", "<=", ">", ">=", "=="),
  value = 0,
  compare_to = NULL,
  absolute = FALSE,
  probability = 0.9,
  models = NULL,
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)
```

## Arguments

- object:

  A hypothesis table, a magnitude-audit table, or an object accepted by
  [`hypothesis_irf()`](https://davidzenz.github.io/bsvarPost/reference/hypothesis_irf.md)
  /
  [`hypothesis_cdm()`](https://davidzenz.github.io/bsvarPost/reference/hypothesis_cdm.md).

- type:

  One of `"irf"` or `"cdm"` when `object` is not already a tidy
  posterior-statement table.

- variable:

  Optional left-hand-side response variable selection.

- shock:

  Optional left-hand-side shock selection.

- horizon:

  Optional left-hand-side horizon selection.

- relation:

  Comparison operator.

- value:

  Scalar comparison value for threshold statements.

- compare_to:

  Optional right-hand-side response specification.

- absolute:

  If `TRUE`, compare absolute responses.

- probability:

  Equal-tailed interval probability used for gap summaries.

- models:

  Optional model filter.

- scale_by:

  Optional scaling mode for CDMs.

- scale_var:

  Optional scaling variable specification.

- ...:

  Additional arguments passed to computation methods.

## Value

A `ggplot` object.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

h <- hypothesis_irf(post, variable = "gdp", shock = "gdp",
                    horizon = 0:2, relation = ">", value = 0)
#> Warning: In hypothesis_irf(): 'variable' is deprecated and will be removed in a future version.
#> Use 'variables' instead.
#> Warning: In hypothesis_irf(): 'shock' is deprecated and will be removed in a future version.
#> Use 'shocks' instead.
p <- plot_hypothesis(h)
```
