# Apply a publication-oriented style to a bsvarPost plot

Apply a publication-oriented style to a bsvarPost plot

## Usage

``` r
style_bsvar_plot(
  plot,
  preset = c("default", "paper", "slides"),
  palette = NULL,
  ribbon_alpha = NULL,
  base_size = 11,
  base_family = "",
  legend_position = NULL
)
```

## Arguments

- plot:

  A `ggplot` object, typically returned by
  [`ggplot2::autoplot()`](https://ggplot2.tidyverse.org/reference/autoplot.html),
  [`plot_hd_event()`](https://davidzenz.github.io/bsvarPost/reference/plot_hd_event.md),
  [`plot_hd_stacked()`](https://davidzenz.github.io/bsvarPost/reference/plot_hd_stacked.md),
  or
  [`plot_shock_ranking()`](https://davidzenz.github.io/bsvarPost/reference/plot_shock_ranking.md).

- preset:

  One of `"default"`, `"paper"`, or `"slides"`.

- palette:

  Optional vector of colours used for both line and fill scales.

- ribbon_alpha:

  Optional alpha override for ribbon layers.

- base_size:

  Base font size for the applied theme.

- base_family:

  Base font family for the applied theme.

- legend_position:

  Optional legend position override.

## Value

A `ggplot` object with the applied style.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

irf_tbl <- tidy_irf(post, horizon = 3)
p <- style_bsvar_plot(ggplot2::autoplot(irf_tbl), preset = "paper")
```
