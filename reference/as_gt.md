# Render bsvarPost tables with gt

Convert posterior summary tables or
[`report_bundle()`](https://davidzenz.github.io/bsvarPost/reference/report_bundle.md)
results to a `gt::gt_tbl` object.

## Usage

``` r
as_gt(x, ...)

# S3 method for class 'bsvar_post_tbl'
as_gt(x, caption = NULL, digits = NULL, preset = c("default", "compact"), ...)

# S3 method for class 'data.frame'
as_gt(x, caption = NULL, digits = NULL, preset = c("default", "compact"), ...)

# S3 method for class 'bsvar_report_bundle'
as_gt(x, caption = NULL, digits = NULL, preset = c("default", "compact"), ...)

# Default S3 method
as_gt(x, ...)
```

## Arguments

- x:

  A `bsvar_post_tbl`, data frame, or `bsvar_report_bundle`.

- ...:

  Additional arguments passed to
  [`gt::gt()`](https://gt.rstudio.com/reference/gt.html).

- caption:

  Optional table caption.

- digits:

  Optional number of digits used to round numeric columns before
  rendering.

- preset:

  Table specification. Use `"compact"` for a narrower selection of
  columns.

## Value

A `gt::gt_tbl` object.
