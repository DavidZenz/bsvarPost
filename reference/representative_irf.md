# Representative impulse responses

Select a representative impulse-response draw from the posterior.

## Usage

``` r
representative_irf(object, ...)

# Default S3 method
representative_irf(object, ...)

# S3 method for class 'PosteriorIR'
representative_irf(
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
representative_irf(
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
  ...
)

median_target_irf(object, ...)

most_likely_admissible_irf(object, ...)
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

## Value

A list of class `RepresentativeIR` (inheriting from
`RepresentativeResponse`) with elements `representative_draw` (the
selected IRF array), `posterior_draws` (all IRF draws), `draw_index`
(integer index of the selected draw), `method`, `score`,
`target_summary`, `selection_spec`, `probability`, and `object_type`.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

rep_irf <- representative_irf(post, horizon = 3)
rep_irf$draw_index
#> [1] 4
```
