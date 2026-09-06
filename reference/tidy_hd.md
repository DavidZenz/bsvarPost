# Summarises posterior draws of historical decompositions

Transforms posterior draws of historical decompositions into a table
containing posterior means, medians, standard deviations, and
equal-tailed credible intervals, or retains the individual shock
contributions when requested.

## Usage

``` r
tidy_hd(object, ...)

# Default S3 method
tidy_hd(object, ...)
```

## Arguments

- object:

  A posterior model object or a `PosteriorHD` array.

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

# Posterior summaries of historical decompositions
result <- tidy_hd(post)
head(result)
#> # A tibble: 6 × 10
#>   model  object_type variable shock time      mean median     sd  lower upper
#>   <chr>  <chr>       <chr>    <chr> <chr>    <dbl>  <dbl>  <dbl>  <dbl> <dbl>
#> 1 model1 hd          ttr      ttr   1948.25  -2.38  -2.85  0.764  -3.00 -1.51
#> 2 model1 hd          ttr      ttr   1948.5   -3.89  -4.63  1.09   -4.72 -2.61
#> 3 model1 hd          ttr      ttr   1948.75  -4.59  -5.07  1.03   -5.19 -3.17
#> 4 model1 hd          ttr      ttr   1949     -5.96  -5.70  2.40   -8.92 -3.49
#> 5 model1 hd          ttr      ttr   1949.25  -9.25  -6.51  8.18  -20.2  -3.77
#> 6 model1 hd          ttr      ttr   1949.5  -18.0   -7.73 25.4   -52.2  -4.30
```
