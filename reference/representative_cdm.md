# Representative cumulative dynamic multipliers

Representative cumulative dynamic multipliers

## Usage

``` r
representative_cdm(object, ...)

# Default S3 method
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
  probability = 0.9,
  ...
)

# S3 method for class 'PosteriorBSVAR'
representative_cdm(
  object,
  horizon = NULL,
  method = c("median_target", "most_likely_admissible"),
  center = c("median", "mean"),
  variables = NULL,
  shocks = NULL,
  horizons = NULL,
  metric = c("l2", "weighted_l2"),
  standardize = c("none", "sd"),
  probability = 0.9,
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)
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

A list of class `RepresentativeCDM` (inheriting from
`RepresentativeResponse`) with elements `representative_draw` (the
selected CDM array), `posterior_draws` (all CDM draws), `draw_index`
(integer index of the selected draw), `method`, `score`,
`target_summary`, `selection_spec`, `probability`, and `object_type`.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

rep_cdm <- representative_cdm(post, horizon = 3)
rep_cdm$draw_index
#> [1] 4
```
