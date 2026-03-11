# Plot restriction-audit summaries

Plot restriction-audit summaries

## Usage

``` r
plot_restriction_audit(
  object,
  restrictions = NULL,
  zero_tol = 1e-08,
  probability = 0.68,
  models = NULL,
  label_style = c("raw", "pretty"),
  labels = NULL,
  restriction_types = NULL,
  ...
)
```

## Arguments

- object:

  A restriction-audit table or an object accepted by
  [`restriction_audit()`](https://davidzenz.github.io/bsvarPost/reference/restriction_audit.md).

- restrictions:

  Optional restriction helper list passed through to
  [`restriction_audit()`](https://davidzenz.github.io/bsvarPost/reference/restriction_audit.md)
  when `object` is not already an audit table.

- zero_tol:

  Numerical tolerance for zero restrictions.

- probability:

  Equal-tailed interval probability used in summaries.

- models:

  Optional model filter.

- label_style:

  Restriction label style: `"raw"` or `"pretty"`.

- labels:

  Optional named character vector overriding restriction labels by raw
  restriction string.

- restriction_types:

  Optional restriction-type filter.

- ...:

  Additional arguments passed to
  [`restriction_audit()`](https://davidzenz.github.io/bsvarPost/reference/restriction_audit.md).
