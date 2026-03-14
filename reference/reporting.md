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
#>    Model Variable Shock Horizon        Mean      Median       Lower
#> 1 model1      ttr   ttr       0  0.05754515  0.04806737  0.04368855
#> 2 model1      ttr   ttr       1  0.07829688  0.05286291  0.04328229
#> 3 model1      ttr   ttr       2  0.10079462  0.06200503  0.04332046
#> 4 model1      ttr   ttr       3  0.12464119  0.07311891  0.04382685
#> 5 model1      ttr    gs       0  0.00000000  0.00000000  0.00000000
#> 6 model1      ttr    gs       1 -0.02455106 -0.01044670 -0.07170458
#>          Upper object_type         sd
#> 1  0.091199426         irf 0.02472531
#> 2  0.165635428         irf 0.06446679
#> 3  0.241270387         irf 0.10386285
#> 4  0.315650268         irf 0.14087868
#> 5  0.000000000         irf 0.00000000
#> 6 -0.006726165         irf 0.03491052

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
