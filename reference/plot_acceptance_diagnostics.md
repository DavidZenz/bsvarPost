# Plot acceptance diagnostics across metrics and models

Plot acceptance diagnostics across metrics and models

## Usage

``` r
plot_acceptance_diagnostics(
  object,
  metrics = NULL,
  models = NULL,
  show_flags = TRUE,
  preset = c("default", "paper", "slides"),
  base_size = 11,
  base_family = "",
  title = NULL,
  subtitle = NULL,
  caption = NULL,
  ...
)
```

## Arguments

- object:

  A tidy acceptance-diagnostics table, or a `PosteriorBSVARSIGN` object
  that can be converted with
  [`acceptance_diagnostics()`](https://davidzenz.github.io/bsvarPost/reference/acceptance_diagnostics.md).

- metrics:

  Optional metric filter.

- models:

  Optional model filter.

- show_flags:

  If `TRUE`, highlight flagged diagnostics in a different marker.

- preset:

  One of `"default"`, `"paper"`, or `"slides"`.

- base_size:

  Base font size.

- base_family:

  Base font family.

- title:

  Optional plot title.

- subtitle:

  Optional plot subtitle.

- caption:

  Optional plot caption.

- ...:

  Additional arguments passed to
  [`acceptance_diagnostics()`](https://davidzenz.github.io/bsvarPost/reference/acceptance_diagnostics.md)
  when `object` is not already a diagnostics table.

## Value

A grid plot object.

## Examples

``` r
# \donttest{
data(optimism, package = "bsvarSIGNs")
sign_irf <- matrix(c(1, rep(NA, 3)), 2, 2)
spec_s <- suppressMessages(
  bsvarSIGNs::specify_bsvarSIGN$new(optimism[, 1:2], p = 1,
                                     sign_irf = sign_irf)
)
post_s <- bsvars::estimate(spec_s, S = 5, show_progress = FALSE)

p <- plot_acceptance_diagnostics(post_s)
# }
```
