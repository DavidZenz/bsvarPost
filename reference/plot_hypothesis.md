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
  probability = 0.68,
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
