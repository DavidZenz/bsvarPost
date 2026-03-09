# Plot simultaneous posterior bands

Plot simultaneous posterior bands

## Usage

``` r
plot_simultaneous(
  object,
  type = c("irf", "cdm"),
  horizon = 10,
  probability = 0.68,
  variable = NULL,
  shock = NULL,
  models = NULL,
  facet_scales = "free_y",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)
```

## Arguments

- object:

  A simultaneous-band table or an object accepted by
  [`simultaneous_irf()`](https://davidzenz.github.io/bsvarPost/reference/simultaneous_irf.md)
  /
  [`simultaneous_cdm()`](https://davidzenz.github.io/bsvarPost/reference/simultaneous_cdm.md).

- type:

  One of `"irf"` or `"cdm"` when `object` is not already a
  simultaneous-band table.

- horizon:

  Maximum horizon used when `object` is a posterior model object.

- probability:

  Coverage probability for the simultaneous band.

- variable:

  Optional response-variable subset.

- shock:

  Optional shock subset.

- models:

  Optional model filter.

- facet_scales:

  Facet scales passed to `ggplot2`.

- scale_by:

  Optional scaling mode for CDMs.

- scale_var:

  Optional scaling variable specification.

- ...:

  Additional arguments passed to computation methods.
