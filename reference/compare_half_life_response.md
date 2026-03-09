# Compare half-life summaries across models

Compare half-life summaries across models

## Usage

``` r
compare_half_life_response(
  ...,
  horizon = 10,
  type = c("irf", "cdm"),
  variable = NULL,
  shock = NULL,
  fraction = 0.5,
  baseline = c("peak", "initial"),
  absolute = TRUE,
  probability = 0.68,
  scale_by = c("none", "shock_sd"),
  scale_var = NULL
)
```

## Arguments

- ...:

  Posterior model objects or a named list of model objects.

- horizon:

  Maximum horizon used when `object` is a posterior model object.

- type:

  Response type for posterior model objects: `"irf"` or `"cdm"`.

- variable:

  Optional response-variable subset.

- shock:

  Optional shock subset.

- fraction:

  Fraction of the reference level used to define the half-life.

- baseline:

  Reference level: `"peak"` or `"initial"`.

- absolute:

  If `TRUE`, compute half-lives using absolute responses.

- probability:

  Equal-tailed interval probability.

- scale_by:

  Optional scaling mode for CDMs.

- scale_var:

  Optional scaling variable specification.
