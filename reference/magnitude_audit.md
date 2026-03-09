# Audit magnitude statements for IRFs or CDMs

Audit magnitude statements for IRFs or CDMs

## Usage

``` r
magnitude_audit(
  object,
  type = c("irf", "cdm"),
  variable,
  shock,
  horizon,
  relation = c("<", "<=", ">", ">=", "=="),
  value = 0,
  compare_to = NULL,
  absolute = FALSE,
  probability = 0.68,
  draws = FALSE,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)
```

## Arguments

- object:

  A posterior model object or response object.

- type:

  Response object type to audit.

- variable:

  Response variable selection on the left-hand side.

- shock:

  Shock selection on the left-hand side.

- horizon:

  Horizon selection on the left-hand side.

- relation:

  Comparison operator.

- value:

  Scalar comparison value for threshold statements.

- compare_to:

  Optional right-hand-side response specification with elements
  `variable`, `shock`, and `horizon`.

- absolute:

  If `TRUE`, compare absolute responses.

- probability:

  Equal-tailed interval probability used for gap summaries.

- draws:

  If `TRUE`, return draw-level gaps and indicators.

- model:

  Optional model identifier.

- scale_by:

  Optional scaling mode for CDMs.

- scale_var:

  Optional scaling variable specification.

- ...:

  Additional arguments passed to computation methods.
