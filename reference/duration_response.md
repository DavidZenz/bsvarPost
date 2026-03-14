# Duration summaries for posterior IRFs and CDMs

Summarise how long a response satisfies a threshold condition over the
available horizons.

## Usage

``` r
duration_response(object, ...)

# Default S3 method
duration_response(object, ...)

# S3 method for class 'PosteriorIR'
duration_response(
  object,
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  relation = c(">", ">=", "<", "<="),
  value = 0,
  absolute = FALSE,
  mode = c("consecutive", "total"),
  probability = 0.9,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVAR'
duration_response(
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
  mode = c("consecutive", "total"),
  probability = 0.9,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARMIX'
duration_response(
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
  mode = c("consecutive", "total"),
  probability = 0.9,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARMSH'
duration_response(
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
  mode = c("consecutive", "total"),
  probability = 0.9,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARSV'
duration_response(
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
  mode = c("consecutive", "total"),
  probability = 0.9,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVART'
duration_response(
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
  mode = c("consecutive", "total"),
  probability = 0.9,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARSIGN'
duration_response(
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
  mode = c("consecutive", "total"),
  probability = 0.9,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorCDM'
duration_response(
  object,
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  relation = c(">", ">=", "<", "<="),
  value = 0,
  absolute = FALSE,
  mode = c("consecutive", "total"),
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

- mode:

  Either `"consecutive"` for the duration until first violation or
  `"total"` for the total count of satisfying horizons.

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
`shock`, `relation`, `threshold`, `mode`, `mean_duration`,
`median_duration`, `sd_duration`, `lower_duration`, and
`upper_duration`.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

dur <- duration_response(post, horizon = 3, relation = ">", value = 0)
print(dur)
#> # A tibble: 9 × 12
#>   model  object_type  variable shock relation threshold mode       mean_duration
#>   <chr>  <chr>        <chr>    <chr> <chr>        <dbl> <chr>              <dbl>
#> 1 model1 duration_irf ttr      ttr   >                0 consecuti…           4  
#> 2 model1 duration_irf ttr      gs    >                0 consecuti…           0  
#> 3 model1 duration_irf ttr      gdp   >                0 consecuti…           0  
#> 4 model1 duration_irf gs       ttr   >                0 consecuti…           2.2
#> 5 model1 duration_irf gs       gs    >                0 consecuti…           4  
#> 6 model1 duration_irf gs       gdp   >                0 consecuti…           0  
#> 7 model1 duration_irf gdp      ttr   >                0 consecuti…           2.6
#> 8 model1 duration_irf gdp      gs    >                0 consecuti…           2.6
#> 9 model1 duration_irf gdp      gdp   >                0 consecuti…           4  
#> # ℹ 4 more variables: median_duration <dbl>, sd_duration <dbl>,
#> #   lower_duration <dbl>, upper_duration <dbl>
```
