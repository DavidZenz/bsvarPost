# Summarises historical-decomposition contributions over selected periods

Transforms posterior draws of historical decompositions into cumulative
structural-shock contributions over a selected historical period and
reports their posterior summaries.

## Usage

``` r
tidy_hd_event(object, ...)

# Default S3 method
tidy_hd_event(object, ...)

# S3 method for class 'bsvar_post_tbl'
tidy_hd_event(
  object,
  start,
  end = start,
  probability = 0.9,
  draws = FALSE,
  ...
)

# S3 method for class 'PosteriorHD'
tidy_hd_event(
  object,
  start,
  end = start,
  probability = 0.9,
  draws = FALSE,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVAR'
tidy_hd_event(
  object,
  start,
  end = start,
  probability = 0.9,
  draws = FALSE,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVARMIX'
tidy_hd_event(
  object,
  start,
  end = start,
  probability = 0.9,
  draws = FALSE,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVARMSH'
tidy_hd_event(
  object,
  start,
  end = start,
  probability = 0.9,
  draws = FALSE,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVARSV'
tidy_hd_event(
  object,
  start,
  end = start,
  probability = 0.9,
  draws = FALSE,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVART'
tidy_hd_event(
  object,
  start,
  end = start,
  probability = 0.9,
  draws = FALSE,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVARSIGN'
tidy_hd_event(
  object,
  start,
  end = start,
  probability = 0.9,
  draws = FALSE,
  model = "model1",
  ...
)
```

## Arguments

- object:

  A posterior model object, `PosteriorHD`, or a posterior-summary table
  of historical decompositions.

- ...:

  Additional arguments passed to computation methods.

- start:

  First time index to include.

- end:

  Last time index to include. Defaults to `start`.

- probability:

  Probability mass of the equal-tailed credible interval.

- draws:

  If `TRUE`, return draw-level cumulative contributions.

- model:

  Label identifying the model specification.

## Value

A `bsvar_post_tbl` with columns `model`, `object_type`, `variable`,
`shock`, `event_start`, `event_end`, `median`, `mean`, `sd`, `lower`,
and `upper`. When `draws = TRUE`, columns `draw` and `value` replace the
summary statistics.

## See also

[posterior_provenance](https://davidzenz.github.io/bsvarPost/reference/posterior_provenance.md)

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

hd_event <- tidy_hd_event(post, start = "1948.25", end = "1948.5")
head(hd_event)
#> # A tibble: 6 × 21
#>   model  object_type variable shock    mean   median    sd  lower    upper
#>   <chr>  <chr>       <chr>    <chr>   <dbl>    <dbl> <dbl>  <dbl>    <dbl>
#> 1 model1 hd_event    ttr      ttr   -4.24   -5.01    2.21  -5.68  -1.27   
#> 2 model1 hd_event    ttr      gs    -0.0442  0.00234 0.136 -0.228  0.0400 
#> 3 model1 hd_event    ttr      gdp    1.15    1.37    1.15  -0.336  2.25   
#> 4 model1 hd_event    gs       ttr    0.300   0.335   0.450 -0.226  0.805  
#> 5 model1 hd_event    gs       gs     0.0151 -1.33    3.36  -1.97   4.59   
#> 6 model1 hd_event    gs       gdp   -0.104  -0.0466  0.127 -0.247  0.00602
#> # ℹ 12 more variables: analysis_type <chr>, interval_probability <dbl>,
#> #   interval_method <chr>, scale_by <chr>, scale_var <chr>, scale_factor <dbl>,
#> #   units <chr>, source_package <chr>, source_version <chr>, n_draws <int>,
#> #   event_start <chr>, event_end <chr>
```
