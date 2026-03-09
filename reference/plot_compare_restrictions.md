# Plot comparison summaries for restriction-audit tables

Plot comparison summaries for restriction-audit tables

## Usage

``` r
plot_compare_restrictions(
  object,
  models = NULL,
  restriction_types = NULL,
  top_n = NULL
)
```

## Arguments

- object:

  A comparison table returned by
  [`compare_restrictions()`](https://davidzenz.github.io/bsvarPost/reference/compare_restrictions.md).

- models:

  Optional model filter.

- restriction_types:

  Optional restriction-type filter.

- top_n:

  Optional number of highest-probability restrictions to keep within
  each model.
