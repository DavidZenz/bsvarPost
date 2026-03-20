# Tidy event-window historical decompositions

Aggregate historical decomposition draws or summaries over a selected
event window.

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

  A posterior model object, `PosteriorHD`, or tidy historical
  decomposition table.

- ...:

  Additional arguments passed to computation methods.

- start:

  First time index to include.

- end:

  Last time index to include. Defaults to `start`.

- probability:

  Equal-tailed interval probability.

- draws:

  If `TRUE`, return draw-level cumulative contributions.

- model:

  Optional model identifier.

## Value

A `bsvar_post_tbl` with columns `model`, `object_type`, `variable`,
`shock`, `event_start`, `event_end`, `median`, `mean`, `sd`, `lower`,
and `upper`. When `draws = TRUE`, columns `draw` and `value` replace the
summary statistics.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

hd_event <- tidy_hd_event(post, start = "1948.25", end = "1948.5")
head(hd_event)
#> # A tibble: 6 × 11
#>   model  object_type variable shock event_start event_end   mean  median    sd
#>   <chr>  <chr>       <chr>    <chr> <chr>       <chr>      <dbl>   <dbl> <dbl>
#> 1 model1 hd_event    gdp      gdp   1948.25     1948.5    0.872   1.49   1.79 
#> 2 model1 hd_event    gs       gdp   1948.25     1948.5    0       0      0    
#> 3 model1 hd_event    ttr      gdp   1948.25     1948.5    0       0      0    
#> 4 model1 hd_event    gdp      gs    1948.25     1948.5    0.0469  0.0461 0.115
#> 5 model1 hd_event    gs       gs    1948.25     1948.5    0.0715 -0.232  0.703
#> 6 model1 hd_event    ttr      gs    1948.25     1948.5    0       0      0    
#> # ℹ 2 more variables: lower <dbl>, upper <dbl>
```
