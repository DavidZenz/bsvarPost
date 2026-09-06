# Summarises posterior draws of impulse responses

Transforms posterior draws of impulse responses into a table containing
posterior means, medians, standard deviations, and equal-tailed credible
intervals, or retains the individual draws when requested.

## Usage

``` r
tidy_irf(object, ...)

# Default S3 method
tidy_irf(object, ...)

# S3 method for class 'PosteriorBSVAR'
tidy_irf(
  object,
  horizon = NULL,
  probability = 0.9,
  draws = FALSE,
  model = "model1",
  ...
)
```

## Arguments

- object:

  A posterior model object or posterior IRF array.

- ...:

  Additional arguments passed to computation methods.

- horizon:

  Forecast horizon when `object` is a posterior model object.

- probability:

  Probability mass of the equal-tailed credible interval.

- draws:

  If `TRUE`, report individual posterior draws rather than posterior
  summaries.

- model:

  Label identifying the model specification.

## Value

A `bsvar_post_tbl` (tibble subclass) with columns `model`,
`object_type`, `variable`, `shock`, `horizon`, `mean`, `median`, `sd`,
`lower`, and `upper`. When `draws = TRUE`, columns `draw` and `value`
replace the summary statistics.

## Examples

``` r
# Small posterior (S = 5 draws)
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

# Posterior summaries of impulse responses
result <- tidy_irf(post, horizon = 3)
head(result)
#> # A tibble: 6 × 10
#>   model  object_type variable shock horizon   mean median     sd  lower  upper
#>   <chr>  <chr>       <chr>    <chr>   <dbl>  <dbl>  <dbl>  <dbl>  <dbl>  <dbl>
#> 1 model1 irf         ttr      ttr         0  0.132  0.125 0.0161  0.121  0.155
#> 2 model1 irf         ttr      ttr         1  0.240  0.230 0.0287  0.219  0.278
#> 3 model1 irf         ttr      ttr         2  0.367  0.372 0.0189  0.344  0.387
#> 4 model1 irf         ttr      ttr         3  0.516  0.515 0.0723  0.427  0.594
#> 5 model1 irf         ttr      gs          0  0      0     0       0      0    
#> 6 model1 irf         ttr      gs          1 -0.217 -0.165 0.115  -0.374 -0.157
```
