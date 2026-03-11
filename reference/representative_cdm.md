# Representative cumulative dynamic multipliers

Representative cumulative dynamic multipliers

## Usage

``` r
representative_cdm(object, ...)

# S3 method for class 'PosteriorCDM'
representative_cdm(
  object,
  method = c("median_target", "most_likely_admissible"),
  center = c("median", "mean"),
  variables = NULL,
  shocks = NULL,
  horizons = NULL,
  metric = c("l2", "weighted_l2"),
  standardize = c("none", "sd"),
  probability = 0.68,
  ...
)

# S3 method for class 'PosteriorBSVAR'
representative_cdm(
  object,
  horizon = 10,
  method = c("median_target", "most_likely_admissible"),
  center = c("median", "mean"),
  variables = NULL,
  shocks = NULL,
  horizons = NULL,
  metric = c("l2", "weighted_l2"),
  standardize = c("none", "sd"),
  probability = 0.68,
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

median_target_cdm(object, ...)

most_likely_admissible_cdm(object, ...)
```

## Arguments

- object:

  A posterior model object or a `PosteriorIR`.

- ...:

  Additional arguments passed to computation methods.

- method:

  Representative-model selection method.

- center:

  Posterior summary used as the target for median-target selection.

- variables:

  Optional subset of response variables.

- shocks:

  Optional subset of shocks.

- horizons:

  Optional subset of horizons.

- metric:

  Distance metric used for median-target selection.

- standardize:

  Optional standardisation used in distance computation.

- probability:

  Equal-tailed interval probability used for summaries.

- horizon:

  Forecast horizon when `object` is a posterior model object.

- scale_by:

  Optional scaling mode for CDMs.

- scale_var:

  Optional scaling variable specification.

## Value

A `RepresentativeCDM` object. Use
[`summary()`](https://rdrr.io/r/base/summary.html) to obtain the tidy
representative table.
