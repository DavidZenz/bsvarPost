# Defines a plot theme for posterior summaries

Returns a `ggplot2` theme with typographic and spacing conventions for
plots of posterior quantities.

## Usage

``` r
theme_bsvarpost(
  preset = c("default", "paper", "slides"),
  base_size = 11,
  base_family = ""
)
```

## Arguments

- preset:

  One of `"default"`, `"paper"`, or `"slides"`.

- base_size:

  Base font size.

- base_family:

  Base font family.

## Value

A `ggplot2` theme object.

## Examples

``` r
th <- theme_bsvarpost(preset = "paper")
```
