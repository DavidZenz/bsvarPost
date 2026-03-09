# Autoplot tidy posterior outputs

Autoplot tidy posterior outputs

## Usage

``` r
# S3 method for class 'bsvar_post_tbl'
autoplot(
  object,
  variables = NULL,
  shocks = NULL,
  models = NULL,
  facet_scales = "free_y",
  ...
)
```

## Arguments

- object:

  A `bsvar_post_tbl` returned by the tidy or comparison helpers.

- variables:

  Optional variable filter.

- shocks:

  Optional shock filter.

- models:

  Optional model filter.

- facet_scales:

  Facet scales passed to `ggplot2`.

- ...:

  Unused.
