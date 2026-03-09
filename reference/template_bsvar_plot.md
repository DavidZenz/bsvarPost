# Apply an output-family template to a bsvarPost plot

Apply an output-family template to a bsvarPost plot

## Usage

``` r
template_bsvar_plot(
  plot,
  family = c("irf", "cdm", "forecast", "hd_event", "shock_ranking", "hypothesis",
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

  One of `"irf"`, `"cdm"`, `"forecast"`, `"hd_event"`,
  `"shock_ranking"`, `"hypothesis"`, `"restriction_audit"`,
  `"simultaneous"`, `"joint_hypothesis"`, `"acceptance_diagnostics"`,
  `"representative"`, or `"comparison"`.

- preset:

  One of `"default"`, `"paper"`, or `"slides"`.

- base_size:

  Base font size for the applied theme.

- base_family:

  Base font family for the applied theme.
