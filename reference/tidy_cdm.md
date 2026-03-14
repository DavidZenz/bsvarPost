# Tidy cumulative dynamic multipliers

Tidy cumulative dynamic multipliers

## Usage

``` r
tidy_cdm(object, ...)

# Default S3 method
tidy_cdm(object, ...)

# S3 method for class 'PosteriorBSVAR'
tidy_cdm(
  object,
  horizon = NULL,
  probability = 0.9,
  draws = FALSE,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
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

- scale_by:

  Optional scaling mode for CDMs.

- scale_var:

  Optional scaling variable specification.

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

# Tidy cumulative dynamic multipliers
result <- tidy_cdm(post, horizon = 3)
head(result)
#> # A tibble: 6 × 10
#>   model  object_type variable shock horizon     mean   median      sd    lower
#>   <chr>  <chr>       <chr>    <chr>   <dbl>    <dbl>    <dbl>   <dbl>    <dbl>
#> 1 model1 cdm         ttr      ttr         0  0.0817   0.0641  0.0419   0.0547 
#> 2 model1 cdm         ttr      ttr         1  0.174    0.134   0.0955   0.110  
#> 3 model1 cdm         ttr      ttr         2  0.280    0.211   0.163    0.168  
#> 4 model1 cdm         ttr      ttr         3  0.402    0.295   0.248    0.227  
#> 5 model1 cdm         ttr      gs          0  0        0       0        0      
#> 6 model1 cdm         ttr      gs          1 -0.00283 -0.00662 0.00862 -0.00724
#> # ℹ 1 more variable: upper <dbl>
```
