# Add publication-oriented annotations to a bsvarPost plot

Add publication-oriented annotations to a bsvarPost plot

## Usage

``` r
annotate_bsvar_plot(
  plot,
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  yintercept = NULL,
  xintercept = NULL,
  xmin = NULL,
  xmax = NULL,
  window_fill = "grey70",
  window_alpha = 0.12
)
```

## Arguments

- plot:

  A `ggplot` object.

- title:

  Optional plot title.

- subtitle:

  Optional plot subtitle.

- caption:

  Optional plot caption.

- yintercept:

  Optional numeric vector of horizontal reference lines.

- xintercept:

  Optional numeric vector of vertical reference lines.

- xmin:

  Optional start of a highlighted x-window.

- xmax:

  Optional end of a highlighted x-window.

- window_fill:

  Fill colour for the highlighted window.

- window_alpha:

  Alpha for the highlighted window.

## Value

A `ggplot` object with annotations added.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

irf_tbl <- tidy_irf(post, horizon = 3)
p <- annotate_bsvar_plot(ggplot2::autoplot(irf_tbl), title = "IRFs")
```
