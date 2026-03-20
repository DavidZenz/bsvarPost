# Export bsvarPost tables to CSV

Write a reporting-ready table to disk as a CSV file.

## Usage

``` r
write_bsvar_csv(
  x,
  file,
  row.names = FALSE,
  preset = c("default", "compact"),
  ...
)
```

## Arguments

- x:

  A `bsvar_post_tbl`, data frame, or `bsvar_report_bundle`.

- file:

  Output CSV path.

- row.names:

  Passed to
  [`utils::write.csv()`](https://rdrr.io/r/utils/write.table.html).

- preset:

  Reporting preset. Use `"compact"` for a narrower, publication-oriented
  column selection.

- ...:

  Additional arguments passed to
  [`utils::write.csv()`](https://rdrr.io/r/utils/write.table.html).

## Value

The normalized file path, invisibly.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
irf_tbl <- tidy_irf(post, horizon = 3)
tmp <- tempfile(fileext = ".csv")
write_bsvar_csv(irf_tbl, file = tmp)
unlink(tmp)
```
