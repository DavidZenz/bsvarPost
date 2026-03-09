# Plot acceptance diagnostics across metrics and models

Plot acceptance diagnostics across metrics and models

## Usage

``` r
plot_acceptance_diagnostics(
  object,
  metrics = NULL,
  models = NULL,
  show_flags = TRUE,
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

  If `TRUE`, highlight flagged diagnostics in a different colour.

- ...:

  Additional arguments passed to
  [`acceptance_diagnostics()`](https://davidzenz.github.io/bsvarPost/reference/acceptance_diagnostics.md)
  when `object` is not already a diagnostics table.
