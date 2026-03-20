# Tidy posterior impulse responses

Tidy posterior impulse responses

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

  Equal-tailed interval probability.

- draws:

  If `TRUE`, return draw-level rows.

- model:

  Optional model identifier.

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

# Tidy impulse responses
result <- tidy_irf(post, horizon = 3)
head(result)
#> # A tibble: 6 × 10
#>   model  object_type variable shock horizon   mean   median     sd   lower upper
#>   <chr>  <chr>       <chr>    <chr>   <dbl>  <dbl>    <dbl>  <dbl>   <dbl> <dbl>
#> 1 model1 irf         ttr      ttr         0 0.0521 0.0316   0.0354  0.0291 0.101
#> 2 model1 irf         ttr      ttr         1 0.0739 0.0286   0.0713  0.0263 0.171
#> 3 model1 irf         ttr      ttr         2 0.0868 0.0261   0.104   0.0236 0.231
#> 4 model1 irf         ttr      ttr         3 0.0950 0.0240   0.123   0.0209 0.265
#> 5 model1 irf         ttr      gs          0 0      0        0       0      0    
#> 6 model1 irf         ttr      gs          1 0.0306 0.000989 0.0823 -0.0209 0.141
```
