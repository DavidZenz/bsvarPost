# Prepares tables of posterior results

Arranges posterior summaries in data frames with a consistent column
order and descriptive column names.

## Usage

``` r
report_table(x, ...)

# S3 method for class 'bsvar_post_tbl'
report_table(x, digits = NULL, preset = c("default", "compact"), ...)

# S3 method for class 'data.frame'
report_table(x, digits = NULL, preset = c("default", "compact"), ...)

# S3 method for class 'bsvar_report_bundle'
report_table(x, digits = NULL, preset = c("default", "compact"), ...)

# Default S3 method
report_table(x, ...)
```

## Arguments

- x:

  A `bsvar_post_tbl`, data frame, or `bsvar_report_bundle`.

- ...:

  Additional arguments passed to methods.

- digits:

  Optional number of digits used to round numeric columns before
  rendering.

- preset:

  Table specification. Use `"compact"` for a narrower selection of
  columns.

## Value

A data frame containing the selected posterior summaries.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
irf_tbl <- tidy_irf(post, horizon = 3)

head(report_table(irf_tbl))
#>    Model Variable Shock Horizon        Mean       Median       Lower
#> 1 model1      ttr   ttr       0  0.05669166  0.039540691  0.03224529
#> 2 model1      ttr   ttr       1  0.02847219  0.038575744 -0.02686510
#> 3 model1      ttr   ttr       2 -0.03958111  0.040769250 -0.31100177
#> 4 model1      ttr   ttr       3 -0.16450084  0.042930882 -0.82219632
#> 5 model1      ttr    gs       0  0.00000000  0.000000000  0.00000000
#> 6 model1      ttr    gs       1 -0.02820548 -0.002442656 -0.10786428
#>          Upper object_type         sd Analysis type Interval probability
#> 1 0.1038397138         irf 0.03428735      response                  0.9
#> 2 0.0641317998         irf 0.04159206      response                  0.9
#> 3 0.0711479138         irf 0.20044378      response                  0.9
#> 4 0.0779079614         irf 0.48761015      response                  0.9
#> 5 0.0000000000         irf 0.00000000      response                  0.9
#> 6 0.0001733657         irf 0.05912256      response                  0.9
#>   Interval method Scaling Scaling variable Scaling factor Units Source package
#> 1    equal_tailed    none             <NA>              1  <NA>         bsvars
#> 2    equal_tailed    none             <NA>              1  <NA>         bsvars
#> 3    equal_tailed    none             <NA>              1  <NA>         bsvars
#> 4    equal_tailed    none             <NA>              1  <NA>         bsvars
#> 5    equal_tailed    none             <NA>              1  <NA>         bsvars
#> 6    equal_tailed    none             <NA>              1  <NA>         bsvars
#>   Source version Draw count
#> 1            4.0          5
#> 2            4.0          5
#> 3            4.0          5
#> 4            4.0          5
#> 5            4.0          5
#> 6            4.0          5
```
