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
#>   model  object_type variable shock horizon    mean    median     sd    lower
#>   <chr>  <chr>       <chr>    <chr>   <dbl>   <dbl>     <dbl>  <dbl>    <dbl>
#> 1 model1 irf         ttr      ttr         0 0.0493  0.0303    0.0401  0.0280 
#> 2 model1 irf         ttr      ttr         1 0.0347  0.0289    0.0104  0.0262 
#> 3 model1 irf         ttr      ttr         2 0.0356  0.0275    0.0143  0.0246 
#> 4 model1 irf         ttr      ttr         3 0.0352  0.0261    0.0154  0.0232 
#> 5 model1 irf         ttr      gs          0 0       0         0       0      
#> 6 model1 irf         ttr      gs          1 0.00771 0.0000907 0.0178 -0.00102
#> # ℹ 1 more variable: upper <dbl>
```
