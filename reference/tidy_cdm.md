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
#>   model  object_type variable shock horizon    mean     median      sd     lower
#>   <chr>  <chr>       <chr>    <chr>   <dbl>   <dbl>      <dbl>   <dbl>     <dbl>
#> 1 model1 cdm         ttr      ttr         0 0.0374   0.0311    0.0172   0.0276  
#> 2 model1 cdm         ttr      ttr         1 0.0768   0.0593    0.0417   0.0539  
#> 3 model1 cdm         ttr      ttr         2 0.117    0.0849    0.0713   0.0790  
#> 4 model1 cdm         ttr      ttr         3 0.159    0.109     0.104    0.103   
#> 5 model1 cdm         ttr      gs          0 0        0         0        0       
#> 6 model1 cdm         ttr      gs          1 0.00376 -0.0000791 0.00912 -0.000996
#> # ℹ 1 more variable: upper <dbl>
```
