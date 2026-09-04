# Prepare reporting-ready tables

Format `bsvarPost` outputs into data frames with stable column order and
presentation-oriented names.

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

  Reporting preset. Use `"compact"` for a narrower, publication-oriented
  column selection.

## Value

A data frame with reporting-ready columns.

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
#>          Upper object_type         sd
#> 1 0.1038397138         irf 0.03428735
#> 2 0.0641317998         irf 0.04159206
#> 3 0.0711479138         irf 0.20044378
#> 4 0.0779079614         irf 0.48761015
#> 5 0.0000000000         irf 0.00000000
#> 6 0.0001733657         irf 0.05912256
```
