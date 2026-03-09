# Compare duration summaries across models

Compare duration summaries across models

## Usage

``` r
compare_duration_response(
  ...,
  horizon = 10,
  type = c("irf", "cdm"),
  variable = NULL,
  shock = NULL,
  relation = c(">", ">=", "<", "<="),
  value = 0,
  absolute = FALSE,
  mode = c("consecutive", "total"),
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

- relation:

  Comparison operator.

- value:

  Threshold value.

- absolute:

  If `TRUE`, compare absolute responses.

- mode:

  Either `"consecutive"` or `"total"`.

- probability:

  Equal-tailed interval probability.

- scale_by:

  Optional scaling mode for CDMs.

- scale_var:

  Optional scaling variable specification.
