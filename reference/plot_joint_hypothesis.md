# Plot joint posterior probability statements

Plot joint posterior probability statements

## Usage

``` r
plot_joint_hypothesis(
  object,
  type = c("irf", "cdm"),
  variable = NULL,
  shock = NULL,
  horizon = NULL,
  relation = c("<", "<=", ">", ">=", "=="),
  value = 0,
  compare_to = NULL,
  absolute = FALSE,
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)
```

## Arguments

- object:

  A joint-hypothesis table or an object accepted by
  [`joint_hypothesis_irf()`](https://davidzenz.github.io/bsvarPost/reference/joint_hypothesis_irf.md)
  /
  [`joint_hypothesis_cdm()`](https://davidzenz.github.io/bsvarPost/reference/joint_hypothesis_cdm.md).

- type:

  One of `"irf"` or `"cdm"` when `object` is not already a joint
  hypothesis table.

- variable:

  Response variable selection on the left-hand side.

- shock:

  Shock selection on the left-hand side.

- horizon:

  Horizon selection on the left-hand side.

- relation:

  Comparison operator.

- value:

  Scalar comparison value for threshold statements.

- compare_to:

  Optional right-hand-side response specification with elements
  `variable`, `shock`, and `horizon`.

- absolute:

  If `TRUE`, compare absolute responses.

- scale_by:

  Optional scaling mode for CDMs.

- scale_var:

  Optional scaling variable specification.

- ...:

  Additional arguments passed to computation methods.

## Value

A `ggplot` object.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

jh <- joint_hypothesis_irf(post, variable = "gdp", shock = "gdp",
                           horizon = 0:2, relation = ">", value = 0)
p <- plot_joint_hypothesis(jh)
```
