# Posterior probability statements for impulse responses

Evaluate threshold or pairwise posterior probability statements on
impulse response draws.

## Usage

``` r
hypothesis_irf(object, ...)

# S3 method for class 'PosteriorIR'
hypothesis_irf(
  object,
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
  ...
)

# S3 method for class 'PosteriorBSVAR'
hypothesis_irf(
  object,
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
  ...
)
```

## Arguments

- object:

  A posterior model object or a `PosteriorIR` object.

- ...:

  Additional arguments passed to computation methods.

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
