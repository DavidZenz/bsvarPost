# Tidy historical decompositions

Tidy historical decompositions

## Usage

``` r
tidy_hd(object, ...)

# Default S3 method
tidy_hd(object, ...)
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

# Tidy historical decompositions
result <- tidy_hd(post)
head(result)
#> # A tibble: 6 × 10
#>   model  object_type variable shock time     mean median    sd  lower upper
#>   <chr>  <chr>       <chr>    <chr> <chr>   <dbl>  <dbl> <dbl>  <dbl> <dbl>
#> 1 model1 hd          ttr      ttr   1948.25  0      0    0       0     0   
#> 2 model1 hd          ttr      ttr   1948.5  -3.15  -3.32 0.621  -3.80 -2.41
#> 3 model1 hd          ttr      ttr   1948.75 -5.08  -5.27 1.09   -6.35 -3.93
#> 4 model1 hd          ttr      ttr   1949    -5.84  -5.84 1.48   -7.70 -4.34
#> 5 model1 hd          ttr      ttr   1949.25 -6.76  -6.58 2.01   -9.31 -4.74
#> 6 model1 hd          ttr      ttr   1949.5  -7.95  -7.63 2.61  -11.3  -5.41
```
