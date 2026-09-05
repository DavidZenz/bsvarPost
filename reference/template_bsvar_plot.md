# Apply graphical conventions for a posterior quantity

Apply graphical conventions for a posterior quantity

## Usage

``` r
template_bsvar_plot(
  plot,
  family = c("irf", "cdm", "forecast", "hd", "hd_event", "shock_ranking", "hypothesis",
    "restriction_audit", "simultaneous", "joint_hypothesis", "acceptance_diagnostics",
    "representative", "comparison"),
  preset = c("default", "paper", "slides"),
  base_size = 11,
  base_family = ""
)
```

## Arguments

- plot:

  A `ggplot` object.

- family:

  Posterior quantity represented by the plot. One of `"irf"`, `"cdm"`,
  `"forecast"`, `"hd"`, `"hd_event"`, `"shock_ranking"`, `"hypothesis"`,
  `"restriction_audit"`, `"simultaneous"`, `"joint_hypothesis"`,
  `"acceptance_diagnostics"`, `"representative"`, or `"comparison"`.

- preset:

  One of `"default"`, `"paper"`, or `"slides"`.

- base_size:

  Base font size for the applied theme.

- base_family:

  Base font family for the applied theme.

## Value

A `ggplot` object with graphical conventions appropriate to the selected
posterior quantity.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

irf_tbl <- tidy_irf(post, horizon = 3)
p <- template_bsvar_plot(ggplot2::autoplot(irf_tbl), family = "irf")
```
