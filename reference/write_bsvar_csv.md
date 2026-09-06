# Writes posterior summaries to a CSV file

Writes a table of posterior summaries to disk as a
comma-separated-values file.

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

  Path of the CSV file.

- row.names:

  Whether row names are written; passed to
  [`utils::write.csv()`](https://rdrr.io/r/utils/write.table.html).

- preset:

  Table specification. Use `"compact"` for a narrower selection of
  columns.

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
