# Render bsvarPost tables with knitr::kable

Convert `bsvarPost` tables or report bundles to a
[`knitr::kable`](https://rdrr.io/pkg/knitr/man/kable.html) object.

## Usage

``` r
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
```

## Arguments

- x:

  A `bsvar_post_tbl`, data frame, or `bsvar_report_bundle`.

- ...:

  Additional arguments passed to
  [`knitr::kable()`](https://rdrr.io/pkg/knitr/man/kable.html).

- caption:

  Optional table caption.

- digits:

  Optional number of digits used to round numeric columns before
  rendering.

- preset:

  Reporting preset. Use `"compact"` for a narrower, publication-oriented
  column selection.

## Value

A [`knitr::kable`](https://rdrr.io/pkg/knitr/man/kable.html) object.
