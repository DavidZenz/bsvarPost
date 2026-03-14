# Export bsvarPost tables as reporting objects

These helpers target the package's tidy tabular outputs, especially
`bsvar_post_tbl` objects returned by the extraction, comparison,
hypothesis, audit, and summary helpers.

## Usage

``` r
report_bundle(
  object,
  plot = NULL,
  caption = NULL,
  digits = NULL,
  preset = c("default", "compact"),
  ...
)

report_table(x, ...)

# S3 method for class 'bsvar_post_tbl'
report_table(x, digits = NULL, preset = c("default", "compact"), ...)

# S3 method for class 'data.frame'
report_table(x, digits = NULL, preset = c("default", "compact"), ...)

# S3 method for class 'bsvar_report_bundle'
report_table(x, digits = NULL, preset = c("default", "compact"), ...)

# Default S3 method
report_table(x, ...)

as_kable(x, ...)

# S3 method for class 'bsvar_post_tbl'
as_kable(
  x,
  caption = NULL,
  digits = NULL,
  preset = c("default", "compact"),
  ...
)

# S3 method for class 'data.frame'
as_kable(
  x,
  caption = NULL,
  digits = NULL,
  preset = c("default", "compact"),
  ...
)

# S3 method for class 'bsvar_report_bundle'
as_kable(
  x,
  caption = NULL,
  digits = NULL,
  preset = c("default", "compact"),
  ...
)

# Default S3 method
as_kable(x, ...)

as_gt(x, ...)

# S3 method for class 'bsvar_post_tbl'
as_gt(x, caption = NULL, digits = NULL, preset = c("default", "compact"), ...)

# S3 method for class 'data.frame'
as_gt(x, caption = NULL, digits = NULL, preset = c("default", "compact"), ...)

# S3 method for class 'bsvar_report_bundle'
as_gt(x, caption = NULL, digits = NULL, preset = c("default", "compact"), ...)

# Default S3 method
as_gt(x, ...)

as_flextable(x, ...)

# S3 method for class 'bsvar_post_tbl'
as_flextable(
  x,
  caption = NULL,
  digits = NULL,
  preset = c("default", "compact"),
  ...
)

# S3 method for class 'data.frame'
as_flextable(
  x,
  caption = NULL,
  digits = NULL,
  preset = c("default", "compact"),
  ...
)

# S3 method for class 'bsvar_report_bundle'
as_flextable(
  x,
  caption = NULL,
  digits = NULL,
  preset = c("default", "compact"),
  ...
)

# Default S3 method
as_flextable(x, ...)

write_bsvar_csv(
  x,
  file,
  row.names = FALSE,
  preset = c("default", "compact"),
  ...
)

# S3 method for class 'bsvar_report_bundle'
print(x, ...)
```

## Arguments

- object:

  A `bsvar_post_tbl`, data frame, or `bsvar_report_bundle`.

- plot:

  Optional `ggplot` object. If omitted, `bsvarPost` will try to choose a
  sensible default plot for the supplied table.

- caption:

  Optional table caption.

- digits:

  Optional number of digits used to round numeric columns before
  rendering.

- preset:

  Reporting preset. Use `"compact"` for a narrower, publication-oriented
  column selection.

- ...:

  Additional arguments passed to the backend formatter.

- x:

  A `bsvar_post_tbl` or data frame.

- file:

  Output CSV path.

- row.names:

  Passed to
  [`utils::write.csv()`](https://rdrr.io/r/utils/write.table.html).

## Value

- `report_bundle()`:

  A list of class `bsvar_report_bundle` with elements `table`, `plot`,
  `caption`, and `object_type`.

- `report_table()`:

  A data frame with reporting-ready columns.

- `as_kable()`:

  A [`knitr::kable`](https://rdrr.io/pkg/knitr/man/kable.html) object.

- `as_gt()`:

  A `gt::gt_tbl` object.

- `as_flextable()`:

  A
  [`flextable::flextable`](https://davidgohel.github.io/flextable/reference/flextable.html)
  object.

- `write_bsvar_csv()`:

  The file path (returned invisibly).

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

irf_tbl <- tidy_irf(post, horizon = 3)

# Report table
rt <- report_table(irf_tbl)
head(rt)
#>    Model Variable Shock Horizon       Mean       Median         Lower
#> 1 model1      ttr   ttr       0 0.04274337 0.0329951693  0.0287148222
#> 2 model1      ttr   ttr       1 0.05973787 0.0270632019  0.0216077639
#> 3 model1      ttr   ttr       2 0.07313949 0.0252268990 -0.0174972921
#> 4 model1      ttr   ttr       3 0.06833054 0.0235072535 -0.1260623605
#> 5 model1      ttr    gs       0 0.00000000 0.0000000000  0.0000000000
#> 6 model1      ttr    gs       1 0.00163395 0.0003055543 -0.0003440199
#>         Upper object_type          sd
#> 1 0.075412878         irf 0.023763510
#> 2 0.158032659         irf 0.072233274
#> 3 0.250142138         irf 0.130822612
#> 4 0.336607419         irf 0.208372228
#> 5 0.000000000         irf 0.000000000
#> 6 0.005700754         irf 0.002945923

# Report bundle
rb <- report_bundle(irf_tbl)
print(rb)
#> <bsvar_report_bundle>
#> rows: 36 cols: 10 
#> object_type: irf 
#> plot: available

# Write to CSV
tmp <- tempfile(fileext = ".csv")
write_bsvar_csv(irf_tbl, file = tmp)
unlink(tmp)

if (FALSE) { # \dontrun{
# Requires optional packages
as_gt(irf_tbl)
as_flextable(irf_tbl)
} # }
```
