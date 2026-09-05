# Render bsvarPost tables with flextable

Convert posterior summary tables or
[`report_bundle()`](https://davidzenz.github.io/bsvarPost/reference/report_bundle.md)
results to a
[`flextable::flextable`](https://davidgohel.github.io/flextable/reference/flextable.html)
object.

## Usage

``` r
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
```

## Arguments

- x:

  A `bsvar_post_tbl`, data frame, or `bsvar_report_bundle`.

- ...:

  Additional arguments passed to
  [`flextable::flextable()`](https://davidgohel.github.io/flextable/reference/flextable.html).

- caption:

  Optional table caption.

- digits:

  Optional number of digits used to round numeric columns before
  rendering.

- preset:

  Table specification. Use `"compact"` for a narrower selection of
  columns.

## Value

A
[`flextable::flextable`](https://davidgohel.github.io/flextable/reference/flextable.html)
object.
