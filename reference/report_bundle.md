# Create reporting bundles from bsvarPost outputs

Bundle a reporting-ready table, a plot, and a caption into a compact
object for downstream publication workflows.

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

  Additional arguments passed to the inferred plot builder.

## Value

A list of class `bsvar_report_bundle` with elements `table`, `plot`,
`caption`, and `object_type`.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
irf_tbl <- tidy_irf(post, horizon = 3)

rb <- report_bundle(irf_tbl)
print(rb)
#> <bsvar_report_bundle>
#> rows: 36 cols: 10 
#> object_type: irf 
#> plot: available
```
