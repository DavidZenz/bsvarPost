# Combine posterior summaries, figures, and captions

Combine a table of posterior summaries, its corresponding figure, and a
caption in a single object.

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

  Optional `ggplot` object. If omitted, a figure is selected when the
  posterior quantity represented by the supplied table can be inferred;
  otherwise the `plot` element is `NULL`.

- caption:

  Optional table caption.

- digits:

  Optional number of digits used to round numeric columns before
  rendering.

- preset:

  Table specification. Use `"compact"` for a narrower selection of
  columns.

- ...:

  Additional arguments passed to the corresponding plotting function.

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
