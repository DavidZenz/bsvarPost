# Time-to-threshold summaries for posterior IRFs and CDMs

Summarise the first horizon at which a response satisfies a threshold
condition.

## Usage

``` r
time_to_threshold(object, ...)

# Default S3 method
time_to_threshold(object, ...)

# S3 method for class 'PosteriorIR'
time_to_threshold(
  object,
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  relation = c(">", ">=", "<", "<="),
  value = 0,
  absolute = FALSE,
  probability = 0.9,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVAR'
time_to_threshold(
  object,
  horizon = NULL,
  type = c("irf", "cdm"),
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  relation = c(">", ">=", "<", "<="),
  value = 0,
  absolute = FALSE,
  probability = 0.9,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARMIX'
time_to_threshold(
  object,
  horizon = NULL,
  type = c("irf", "cdm"),
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  relation = c(">", ">=", "<", "<="),
  value = 0,
  absolute = FALSE,
  probability = 0.9,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARMSH'
time_to_threshold(
  object,
  horizon = NULL,
  type = c("irf", "cdm"),
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  relation = c(">", ">=", "<", "<="),
  value = 0,
  absolute = FALSE,
  probability = 0.9,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARSV'
time_to_threshold(
  object,
  horizon = NULL,
  type = c("irf", "cdm"),
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  relation = c(">", ">=", "<", "<="),
  value = 0,
  absolute = FALSE,
  probability = 0.9,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVART'
time_to_threshold(
  object,
  horizon = NULL,
  type = c("irf", "cdm"),
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  relation = c(">", ">=", "<", "<="),
  value = 0,
  absolute = FALSE,
  probability = 0.9,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARSIGN'
time_to_threshold(
  object,
  horizon = NULL,
  type = c("irf", "cdm"),
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  relation = c(">", ">=", "<", "<="),
  value = 0,
  absolute = FALSE,
  probability = 0.9,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorCDM'
time_to_threshold(
  object,
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  relation = c(">", ">=", "<", "<="),
  value = 0,
  absolute = FALSE,
  probability = 0.9,
  model = "model1",
  ...
)
```

## Arguments

- object:

  A posterior model object, `PosteriorIR`, or `PosteriorCDM`.

- ...:

  Additional arguments passed to computation methods.

- variables:

  Optional response-variable subset (character or integer vector).

- shocks:

  Optional shock subset (character or integer vector).

- variable:

  **Deprecated.** Use `variables` instead.

- shock:

  **Deprecated.** Use `shocks` instead.

- relation:

  Comparison operator.

- value:

  Threshold value.

- absolute:

  If `TRUE`, search for the largest absolute response.

- probability:

  Equal-tailed interval probability.

- model:

  Optional model identifier.

- horizon:

  Maximum horizon used when `object` is a posterior model object.

- type:

  Response type for posterior model objects: `"irf"` or `"cdm"`.

- scale_by:

  Optional scaling mode for CDMs.

- scale_var:

  Optional scaling variable specification.

## Value

A `bsvar_post_tbl` with columns `model`, `object_type`, `variable`,
`shock`, `relation`, `threshold`, `mean_horizon`, `median_horizon`,
`sd_horizon`, `lower_horizon`, `upper_horizon`, and `reached_prob`.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

ttt <- time_to_threshold(post, horizon = 3, relation = ">", value = 0)
print(ttt)
#> # A tibble: 9 × 12
#>   model  object_type           variable shock relation threshold mean_horizon
#>   <chr>  <chr>                 <chr>    <chr> <chr>        <dbl>        <dbl>
#> 1 model1 time_to_threshold_irf ttr      ttr   >                0            0
#> 2 model1 time_to_threshold_irf ttr      gs    >                0            1
#> 3 model1 time_to_threshold_irf ttr      gdp   >                0            1
#> 4 model1 time_to_threshold_irf gs       ttr   >                0            1
#> 5 model1 time_to_threshold_irf gs       gs    >                0            0
#> 6 model1 time_to_threshold_irf gs       gdp   >                0            1
#> 7 model1 time_to_threshold_irf gdp      ttr   >                0            0
#> 8 model1 time_to_threshold_irf gdp      gs    >                0           NA
#> 9 model1 time_to_threshold_irf gdp      gdp   >                0            0
#> # ℹ 5 more variables: median_horizon <dbl>, sd_horizon <dbl>,
#> #   lower_horizon <dbl>, upper_horizon <dbl>, reached_prob <dbl>
```
