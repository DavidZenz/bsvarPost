# Tidy structural shocks

Tidy structural shocks

## Usage

``` r
tidy_shocks(object, ...)

# Default S3 method
tidy_shocks(object, ...)
```

## Arguments

- object:

  A posterior model object or posterior IRF array.

- ...:

  Additional arguments passed to computation methods.

## Value

A `bsvar_post_tbl` (tibble subclass) with columns `model`,
`object_type`, `variable`, `shock`, `time`, `mean`, `median`, `sd`,
`lower`, and `upper`. When `draws = TRUE`, columns `draw` and `value`
replace the summary statistics.

## Examples

``` r
# Small posterior (S = 5 draws)
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

# Tidy structural shocks
result <- tidy_shocks(post)
head(result)
#> # A tibble: 6 × 9
#>   model  object_type variable time     mean median    sd lower upper
#>   <chr>  <chr>       <chr>    <chr>   <dbl>  <dbl> <dbl> <dbl> <dbl>
#> 1 model1 shocks      ttr      1948.25 -3.58  -4.10 1.23  -4.25 -1.91
#> 2 model1 shocks      ttr      1948.5  -2.69  -3.04 0.890 -3.21 -1.49
#> 3 model1 shocks      ttr      1948.75 -1.85  -2.06 0.609 -2.23 -1.02
#> 4 model1 shocks      ttr      1949    -1.94  -2.15 0.602 -2.31 -1.12
#> 5 model1 shocks      ttr      1949.25 -2.14  -2.36 0.619 -2.53 -1.31
#> 6 model1 shocks      ttr      1949.5  -2.40  -2.68 0.659 -2.84 -1.50
```
