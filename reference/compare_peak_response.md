# Compare peak response summaries across models

Compare peak response summaries across models

## Usage

``` r
compare_peak_response(
  ...,
  horizon = 10,
  type = c("irf", "cdm"),
  variable = NULL,
  shock = NULL,
  absolute = FALSE,
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

- absolute:

  If `TRUE`, search for the largest absolute response.

- probability:

  Equal-tailed interval probability.

- scale_by:

  Optional scaling mode for CDMs.

- scale_var:

  Optional scaling variable specification.
