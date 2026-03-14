# Plot restriction-audit summaries

Plot restriction-audit summaries

## Usage

``` r
plot_restriction_audit(
  object,
  restrictions = NULL,
  zero_tol = 1e-08,
  probability = 0.9,
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

## Value

A `ggplot` object.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

r <- list(irf_restriction("gdp", "gdp", 0, sign = 1))
audit <- restriction_audit(post, restrictions = r)
p <- plot_restriction_audit(audit)
```
