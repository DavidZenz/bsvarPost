# Half-life summaries for posterior IRFs and CDMs

Summarise the first horizon at which a response falls to a chosen
fraction of its initial or peak level.

## Usage

``` r
half_life_response(object, ...)

# Default S3 method
half_life_response(object, ...)

# S3 method for class 'PosteriorIR'
half_life_response(
  object,
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  fraction = 0.5,
  baseline = c("peak", "initial"),
  absolute = TRUE,
  probability = 0.9,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVAR'
half_life_response(
  object,
  horizon = NULL,
  type = c("irf", "cdm"),
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  fraction = 0.5,
  baseline = c("peak", "initial"),
  absolute = TRUE,
  probability = 0.9,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARMIX'
half_life_response(
  object,
  horizon = NULL,
  type = c("irf", "cdm"),
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  fraction = 0.5,
  baseline = c("peak", "initial"),
  absolute = TRUE,
  probability = 0.9,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARMSH'
half_life_response(
  object,
  horizon = NULL,
  type = c("irf", "cdm"),
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  fraction = 0.5,
  baseline = c("peak", "initial"),
  absolute = TRUE,
  probability = 0.9,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARSV'
half_life_response(
  object,
  horizon = NULL,
  type = c("irf", "cdm"),
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  fraction = 0.5,
  baseline = c("peak", "initial"),
  absolute = TRUE,
  probability = 0.9,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVART'
half_life_response(
  object,
  horizon = NULL,
  type = c("irf", "cdm"),
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  fraction = 0.5,
  baseline = c("peak", "initial"),
  absolute = TRUE,
  probability = 0.9,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARSIGN'
half_life_response(
  object,
  horizon = NULL,
  type = c("irf", "cdm"),
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  fraction = 0.5,
  baseline = c("peak", "initial"),
  absolute = TRUE,
  probability = 0.9,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorCDM'
half_life_response(
  object,
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  fraction = 0.5,
  baseline = c("peak", "initial"),
  absolute = TRUE,
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

- fraction:

  Fraction of the reference level used to define the half-life.

- baseline:

  Reference level: `"peak"` uses the largest response over the available
  horizons, `"initial"` uses the horizon-0 response.

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
`shock`, `fraction`, `baseline`, `mean_half_life`, `median_half_life`,
`sd_half_life`, `lower_half_life`, `upper_half_life`, and
`reached_prob`.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

hl <- half_life_response(post, horizon = 3)
print(hl)
#> # A tibble: 9 × 12
#>   model  object_type   variable shock fraction baseline mean_half_life
#>   <chr>  <chr>         <chr>    <chr>    <dbl> <chr>             <dbl>
#> 1 model1 half_life_irf ttr      ttr        0.5 peak                 NA
#> 2 model1 half_life_irf ttr      gs         0.5 peak                  1
#> 3 model1 half_life_irf ttr      gdp        0.5 peak                 NA
#> 4 model1 half_life_irf gs       ttr        0.5 peak                  1
#> 5 model1 half_life_irf gs       gs         0.5 peak                  3
#> 6 model1 half_life_irf gs       gdp        0.5 peak                 NA
#> 7 model1 half_life_irf gdp      ttr        0.5 peak                  3
#> 8 model1 half_life_irf gdp      gs         0.5 peak                  2
#> 9 model1 half_life_irf gdp      gdp        0.5 peak                 NA
#> # ℹ 5 more variables: median_half_life <dbl>, sd_half_life <dbl>,
#> #   lower_half_life <dbl>, upper_half_life <dbl>, reached_prob <dbl>
```
