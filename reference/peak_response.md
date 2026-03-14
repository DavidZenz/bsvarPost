# Peak response summaries for posterior IRFs and CDMs

Summarise the peak response level and the horizon at which that peak
occurs.

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

  Optional response-variable subset (character or integer vector).

- shocks:

  Optional shock subset (character or integer vector).

- variable:

  **Deprecated.** Use `variables` instead.

- shock:

  **Deprecated.** Use `shocks` instead.

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
#> 1 model1 peak_irf    ttr      ttr     0.0515       0.0312    0.0331      0.0296 
#> 2 model1 peak_irf    ttr      gs      0.00735      0.00412   0.00599     0.00275
#> 3 model1 peak_irf    ttr      gdp     0.0328       0.000101  0.0526      0      
#> 4 model1 peak_irf    gs       ttr     0.000155     0.00226   0.00720    -0.00957
#> 5 model1 peak_irf    gs       gs      0.0544       0.0286    0.0570      0.0269 
#> 6 model1 peak_irf    gs       gdp     0.0387       0         0.0864      0      
#> 7 model1 peak_irf    gdp      ttr     0.00291      0.0119    0.0794     -0.0967 
#> 8 model1 peak_irf    gdp      gs      0.0307       0.0122    0.0392      0.00107
#> 9 model1 peak_irf    gdp      gdp     0.0990       0.0372    0.116       0.0122 
#> # ℹ 6 more variables: upper_value <dbl>, mean_horizon <dbl>,
#> #   median_horizon <dbl>, sd_horizon <dbl>, lower_horizon <dbl>,
#> #   upper_horizon <dbl>
```
