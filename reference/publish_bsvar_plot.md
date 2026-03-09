# Build a publication-ready bsvarPost plot

This helper detects a supported `bsvarPost` output family, constructs
the corresponding plot when needed, and applies the matching plot
template plus optional annotations.

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
  or report bundle.

- family:

  Optional output family override.

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
