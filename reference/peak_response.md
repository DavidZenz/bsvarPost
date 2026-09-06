# Summarises peak responses from posterior draws

Transforms posterior draws of impulse responses or cumulative dynamic
multipliers into summaries of peak response magnitudes and their
horizons.

## Usage

``` r
peak_response(object, ...)

# Default S3 method
peak_response(object, ...)

# S3 method for class 'PosteriorIR'
peak_response(
  object,
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  absolute = FALSE,
  probability = 0.9,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVAR'
peak_response(
  object,
  horizon = NULL,
  type = c("irf", "cdm"),
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  absolute = FALSE,
  probability = 0.9,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARMIX'
peak_response(
  object,
  horizon = NULL,
  type = c("irf", "cdm"),
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  absolute = FALSE,
  probability = 0.9,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARMSH'
peak_response(
  object,
  horizon = NULL,
  type = c("irf", "cdm"),
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  absolute = FALSE,
  probability = 0.9,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARSV'
peak_response(
  object,
  horizon = NULL,
  type = c("irf", "cdm"),
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  absolute = FALSE,
  probability = 0.9,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVART'
peak_response(
  object,
  horizon = NULL,
  type = c("irf", "cdm"),
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  absolute = FALSE,
  probability = 0.9,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARSIGN'
peak_response(
  object,
  horizon = NULL,
  type = c("irf", "cdm"),
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  absolute = FALSE,
  probability = 0.9,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorCDM'
peak_response(
  object,
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
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

  Response variables to include (character or integer vector).

- shocks:

  Structural shocks to include (character or integer vector).

- variable:

  **Deprecated.** Use `variables` instead.

- shock:

  **Deprecated.** Use `shocks` instead.

- absolute:

  If `TRUE`, search for the largest absolute response.

- probability:

  Probability mass of the equal-tailed credible interval.

- model:

  Label identifying the model specification.

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
`shock`, `mean_value`, `median_value`, `sd_value`, `lower_value`,
`upper_value`, `mean_horizon`, `median_horizon`, `sd_horizon`,
`lower_horizon`, and `upper_horizon`.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

pk <- peak_response(post, horizon = 3)
print(pk)
#> # A tibble: 9 × 14
#>   model  object_type variable shock mean_value median_value sd_value lower_value
#>   <chr>  <chr>       <chr>    <chr>      <dbl>        <dbl>    <dbl>       <dbl>
#> 1 model1 peak_irf    ttr      ttr       0.641        0.343    0.669     0.336   
#> 2 model1 peak_irf    ttr      gs        0.290        0        0.648     0       
#> 3 model1 peak_irf    ttr      gdp       0.0319       0        0.0713    0       
#> 4 model1 peak_irf    gs       ttr       0.158        0.238    0.218    -0.142   
#> 5 model1 peak_irf    gs       gs        0.452        0.114    0.803     0.0483  
#> 6 model1 peak_irf    gs       gdp       0.0348       0.0103   0.0625    0.000474
#> 7 model1 peak_irf    gdp      ttr       1.50         0.992    1.24      0.891   
#> 8 model1 peak_irf    gdp      gs        0.941        0.337    1.53      0.105   
#> 9 model1 peak_irf    gdp      gdp       0.120        0.0976   0.0600    0.0831  
#> # ℹ 6 more variables: upper_value <dbl>, mean_horizon <dbl>,
#> #   median_horizon <dbl>, sd_horizon <dbl>, lower_horizon <dbl>,
#> #   upper_horizon <dbl>
```
