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
