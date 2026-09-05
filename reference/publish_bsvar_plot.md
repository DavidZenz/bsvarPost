# Visualise posterior results with consistent graphical conventions

Identifies the posterior quantity represented by a `bsvarPost` result,
constructs the corresponding visualisation, and applies consistent
graphical conventions and optional annotations.

## Usage

``` r
publish_bsvar_plot(
  object,
  family = NULL,
  preset = c("default", "paper", "slides"),
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  base_size = 11,
  base_family = "",
  ...
)
```

## Arguments

- object:

  A `ggplot` object, `bsvar_post_tbl`, representative-response object,
  or
  [`report_bundle()`](https://davidzenz.github.io/bsvarPost/reference/report_bundle.md)
  result.

- family:

  Optional specification of the posterior quantity represented by
  `object`.

- preset:

  One of `"default"`, `"paper"`, or `"slides"`.

- title:

  Optional plot title.

- subtitle:

  Optional plot subtitle.

- caption:

  Optional plot caption.

- base_size:

  Base font size for the applied theme.

- base_family:

  Base font family for the applied theme.

- ...:

  Additional arguments passed to the underlying plot constructor when
  `object` is not already a `ggplot`.

## Value

A `ggplot` object.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

irf_tbl <- tidy_irf(post, horizon = 3)
p <- publish_bsvar_plot(irf_tbl)
```
