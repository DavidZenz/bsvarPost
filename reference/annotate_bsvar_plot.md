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
