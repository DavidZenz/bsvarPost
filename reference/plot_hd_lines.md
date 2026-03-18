# Plot full-sample historical decomposition components

These helpers provide dedicated historical decomposition visualisations
for full-sample contribution paths and event-window composition
summaries.

## Usage

``` r
plot_hd_lines(
  object,
  probability = 0.9,
  variables = NULL,
  shocks = NULL,
  models = NULL,
  facet_scales = "free_y",
  include_observed = FALSE,
  include_baseline = FALSE,
  shock_groups = NULL,
  top_n = NULL,
  collapse_other = TRUE,
  by = c("variable", "shock"),
  model = "model1",
  ...
)
```

## Arguments

- object:

  A posterior model object, `PosteriorHD`, or a tidy
  historical-decomposition table.

- probability:

  Equal-tailed interval probability used when `object` is not already a
  tidy table.

- variables:

  Optional variable filter.

- shocks:

  Optional shock filter applied before grouping.

- models:

  Optional model filter.

- facet_scales:

  Facet scales passed to `ggplot2`.

- include_observed:

  If `TRUE`, include the observed series for plot types that compare
  decomposition totals against the realised path.

- include_baseline:

  If `TRUE`, include the non-shock baseline component when building a
  full decomposition.

- shock_groups:

  Optional named character vector mapping shock names to display groups.

- top_n:

  Optional number of largest contributors to retain within each
  model-variable panel.

- collapse_other:

  If `TRUE`, contributors outside `top_n` (or unmapped shocks under
  `shock_groups`) are collapsed into `"Other"`.

- by:

  One of `"variable"` or `"shock"` for line-based displays.

- model:

  Model label used when converting posterior objects to tidy plotting
  tables.

- ...:

  Additional arguments passed to
  [`tidy_hd()`](https://davidzenz.github.io/bsvarPost/reference/tidy_hd.md)
  or
  [`tidy_hd_event()`](https://davidzenz.github.io/bsvarPost/reference/tidy_hd_event.md)
  when conversion is required.

## Value

A `ggplot` object.

## Examples

``` r
# \donttest{
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

hd_tbl <- tidy_hd(post)
p_lines <- plot_hd_lines(hd_tbl, variables = "gdp")
p_overlay <- plot_hd_overlay(post, variables = "gdp")
p_stacked <- plot_hd_stacked(post, variables = "gdp")
p_total <- plot_hd_total(post, variables = "gdp", shocks = "gs")

hd_times <- unique(as.character(tidy_hd(post, draws = TRUE)$time))
p_share <- plot_hd_event_share(post, start = hd_times[1], end = hd_times[2])
p_cum <- plot_hd_event_cumulative(post, start = hd_times[1], end = hd_times[2])
p_dist <- plot_hd_event_distribution(post, start = hd_times[1], end = hd_times[2])
# }
```
