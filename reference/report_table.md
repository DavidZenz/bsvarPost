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
#>    Model Variable Shock Horizon         Mean        Median       Lower
#> 1 model1      ttr   ttr       0  0.042208006  0.0395609551  0.03627439
#> 2 model1      ttr   ttr       1  0.044686083  0.0402647891  0.03763468
#> 3 model1      ttr   ttr       2  0.046049433  0.0409953104  0.03901607
#> 4 model1      ttr   ttr       3  0.046239927  0.0417528314  0.04026926
#> 5 model1      ttr    gs       0  0.000000000  0.0000000000  0.00000000
#> 6 model1      ttr    gs       1 -0.005694948 -0.0004618515 -0.02119356
#>          Upper object_type         sd
#> 1 5.396100e-02         irf 0.00859170
#> 2 6.057008e-02         irf 0.01157081
#> 3 6.269032e-02         irf 0.01210492
#> 4 6.007388e-02         irf 0.01002930
#> 5 0.000000e+00         irf 0.00000000
#> 6 9.713569e-05         irf 0.01135790
```
