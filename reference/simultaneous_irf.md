# Simultaneous posterior bands for impulse responses

Construct simultaneous bands over a selected set of impulse responses
using the empirical sup-norm around the posterior median path.

## Usage

``` r
simultaneous_irf(object, ...)

# Default S3 method
simultaneous_irf(object, ...)

# S3 method for class 'PosteriorIR'
simultaneous_irf(
  object,
  probability = 0.9,
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVAR'
simultaneous_irf(
  object,
  horizon = NULL,
  probability = 0.9,
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVARMIX'
simultaneous_irf(
  object,
  horizon = NULL,
  probability = 0.9,
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVARMSH'
simultaneous_irf(
  object,
  horizon = NULL,
  probability = 0.9,
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVARSV'
simultaneous_irf(
  object,
  horizon = NULL,
  probability = 0.9,
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVART'
simultaneous_irf(
  object,
  horizon = NULL,
  probability = 0.9,
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVARSIGN'
simultaneous_irf(
  object,
  horizon = NULL,
  probability = 0.9,
  variables = NULL,
  shocks = NULL,
  variable = NULL,
  shock = NULL,
  model = "model1",
  ...
)
```

## Arguments

- object:

  A posterior model object or a `PosteriorIR` object.

- ...:

  Additional arguments passed to computation methods.

- probability:

  Coverage probability for the simultaneous band.

- variables:

  Optional response-variable subset (character or integer vector).

- shocks:

  Optional shock subset (character or integer vector).

- variable:

  **Deprecated.** Use `variables` instead.

- shock:

  **Deprecated.** Use `shocks` instead.

- model:

  Optional model identifier.

- horizon:

  Maximum horizon used when `object` is a posterior model object.

## Value

A `bsvar_post_tbl` with columns `model`, `object_type`, `variable`,
`shock`, `horizon`, `median`, `lower`, `upper`, `simultaneous_prob`, and
`critical_value`.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

sb <- simultaneous_irf(post, horizon = 3)
head(sb)
#> # A tibble: 6 × 10
#>   model  object_type      variable shock horizon  median  lower upper
#>   <chr>  <chr>            <chr>    <chr>   <dbl>   <dbl>  <dbl> <dbl>
#> 1 model1 simultaneous_irf ttr      ttr         0 0.0346  -0.301 0.370
#> 2 model1 simultaneous_irf gs       ttr         0 0.0211  -0.315 0.357
#> 3 model1 simultaneous_irf gdp      ttr         0 0.00933 -0.326 0.345
#> 4 model1 simultaneous_irf ttr      gs          0 0       -0.336 0.336
#> 5 model1 simultaneous_irf gs       gs          0 0.0939  -0.242 0.430
#> 6 model1 simultaneous_irf gdp      gs          0 0.0122  -0.324 0.348
#> # ℹ 2 more variables: simultaneous_prob <dbl>, critical_value <dbl>
```
