# Changelog

## bsvarPost 1.1.0

- Support bsvarSIGNs 3.0 log-weight native helpers while retaining
  compatibility with 2.0. Narrow upstream namespace imports to avoid
  forecast-class name collisions with bsvars 4.0.

### Correct posterior aggregation and inference

- Grouped historical decompositions and event distributions now
  aggregate within each posterior draw before computing medians and
  credible intervals. Combining multiple shocks, including an `Other`
  category, requires draw-level input. Ungrouped summary-table plots
  remain supported.
- The baseline uses all shock contributions before display filtering.
  Totals are computed from draw-level sums; marginal component medians
  need not add up to the median total.
- Event and cumulative plots use the same event-based contributor
  ranking. Array event summaries select and aggregate the window before
  constructing a long table.
- Model comparisons reject duplicate explicit names and generate
  collision-free missing names. Tuple grouping keeps dotted and
  delimiter-containing labels distinct.
- Forecast horizons are numeric, so periods beyond nine plot in temporal
  order. Nonnumeric original labels are retained as `horizon_label`.
- Pairwise draw-level hypotheses now align RHS labels with each draw.
  Structural restrictions accept model variable labels, and one-period
  narrative diagnostics request a valid upstream computation horizon.
- Hypothesis results render correctly through automatic plotting, report
  bundles and publication helpers. Unsupported draw-level hypothesis
  plots fail immediately; report bundles retain their table with a
  `NULL` plot.
- Simultaneous bands use an empirical order statistic covering at least
  the requested fraction of stored draws. `achieved_coverage` reports
  empirical coverage, which can exceed the requested probability when
  draws tie. This does not guarantee exact coverage of the underlying
  posterior distribution. Floating-point boundaries are adjusted outward
  when necessary to retain the promised empirical coverage.

### Provenance, validation and compatibility

- Posterior tables expose analysis type, interval probability and
  method, normalisation, known units, current upstream software versions
  and draw count as ordinary columns. Unknown values are typed `NA`. See
  [`help("posterior_provenance")`](https://davidzenz.github.io/bsvarPost/reference/posterior_provenance.md)
  for column definitions.
- `draw_id` preserves original posterior labels alongside positional
  `draw`. Representative summaries add `selected_draw_id` alongside
  `draw_index`.
- Default reports and CSV exports include provenance columns. Existing
  estimate columns, function names and object-type attributes are
  retained. Code relying on an exact column list should select columns
  explicitly or use compact reports. APRScenario adapters retain their
  external column schema.
- Restriction constructors and native-bridge operations validate scalar
  parameters, effective-sample bounds and posterior dimensions. Native
  calls verify registered argument counts and report actionable
  compatibility errors.
- R 4.1 remains supported. Minimum dependencies are bsvars 3.2,
  bsvarSIGNs 2.0, ggplot2 3.4.0 and vctrs 0.5.0.
- CI exercises minimum R, absent/present optional integrations and
  runtime coverage. Static release QA no longer treats function-name
  mentions in tests as proof of coverage.

## bsvarPost 1.0.0

Initial CRAN release.

### Breaking changes and deprecations

- The `variable` and `shock` (singular) arguments are deprecated in
  favour of `variables` and `shocks` (plural) throughout the package.
  The singular forms still work and produce a warning; they will be
  removed in a future version.

### Core posterior extraction

- [`tidy_irf()`](https://davidzenz.github.io/bsvarPost/reference/tidy_irf.md)
  extracts impulse responses from `PosteriorBSVAR`, `PosteriorBSVARSV`,
  `PosteriorBSVARMIX`, `PosteriorBSVARMSH`, `PosteriorBSVART`, and
  `PosteriorBSVARSIGN` objects into tidy tibbles with credible-interval
  columns.
- [`tidy_cdm()`](https://davidzenz.github.io/bsvarPost/reference/tidy_cdm.md)
  extracts cumulative dynamic multipliers for all supported posterior
  types.
- [`tidy_fevd()`](https://davidzenz.github.io/bsvarPost/reference/tidy_fevd.md)
  extracts forecast error variance decompositions (reported on the 0–100
  percentage scale used by ‘bsvars’).
- [`tidy_shocks()`](https://davidzenz.github.io/bsvarPost/reference/tidy_shocks.md)
  extracts structural shocks.
- [`tidy_hd()`](https://davidzenz.github.io/bsvarPost/reference/tidy_hd.md)
  extracts historical decompositions.
- [`tidy_forecast()`](https://davidzenz.github.io/bsvarPost/reference/tidy_forecast.md)
  extracts out-of-sample forecasts.
- [`cdm()`](https://davidzenz.github.io/bsvarPost/reference/cdm.md)
  estimates cumulative dynamic multipliers directly from any supported
  posterior object, bridging ‘bsvars’ and ‘bsvarSIGNs’ in a single call.

### Hypothesis testing and inference

- [`hypothesis_irf()`](https://davidzenz.github.io/bsvarPost/reference/hypothesis_irf.md)
  and
  [`hypothesis_cdm()`](https://davidzenz.github.io/bsvarPost/reference/hypothesis_cdm.md)
  compute posterior probabilities for user-specified inequality
  constraints on impulse responses and cumulative dynamic multipliers.
- [`joint_hypothesis_irf()`](https://davidzenz.github.io/bsvarPost/reference/joint_hypothesis_irf.md)
  and
  [`joint_hypothesis_cdm()`](https://davidzenz.github.io/bsvarPost/reference/joint_hypothesis_cdm.md)
  extend hypothesis testing to joint constraints across multiple
  variable–shock–horizon combinations.
- [`simultaneous_irf()`](https://davidzenz.github.io/bsvarPost/reference/simultaneous_irf.md)
  and
  [`simultaneous_cdm()`](https://davidzenz.github.io/bsvarPost/reference/simultaneous_cdm.md)
  compute simultaneous credible bands over selected response paths.

### Representative model selection

- [`representative_irf()`](https://davidzenz.github.io/bsvarPost/reference/representative_irf.md)
  and
  [`representative_cdm()`](https://davidzenz.github.io/bsvarPost/reference/representative_cdm.md)
  identify the posterior draw closest to the pointwise median across all
  impulse-response or CDM paths.
- [`most_likely_admissible_irf()`](https://davidzenz.github.io/bsvarPost/reference/most_likely_admissible_irf.md)
  and
  [`most_likely_admissible_cdm()`](https://davidzenz.github.io/bsvarPost/reference/most_likely_admissible_cdm.md)
  select the draw with the highest kernel score among
  sign-restriction-admissible draws.

### Response summaries

- [`peak_response()`](https://davidzenz.github.io/bsvarPost/reference/peak_response.md)
  locates the horizon of maximum absolute impulse response and its
  posterior distribution.
- [`duration_response()`](https://davidzenz.github.io/bsvarPost/reference/duration_response.md)
  summarises the number of horizons for which a response remains above a
  threshold.
- [`half_life_response()`](https://davidzenz.github.io/bsvarPost/reference/half_life_response.md)
  computes the posterior distribution of the half-life of a response
  decay.
- [`time_to_threshold()`](https://davidzenz.github.io/bsvarPost/reference/time_to_threshold.md)
  computes the posterior distribution of the first horizon at which a
  response crosses a user-specified threshold.

### Model comparison

- [`compare_irf()`](https://davidzenz.github.io/bsvarPost/reference/compare_irf.md),
  [`compare_cdm()`](https://davidzenz.github.io/bsvarPost/reference/compare_cdm.md),
  [`compare_fevd()`](https://davidzenz.github.io/bsvarPost/reference/compare_fevd.md)
  compare tidy extractions across two models side-by-side.
- [`compare_peak_response()`](https://davidzenz.github.io/bsvarPost/reference/compare_peak_response.md),
  [`compare_duration_response()`](https://davidzenz.github.io/bsvarPost/reference/compare_duration_response.md),
  [`compare_half_life_response()`](https://davidzenz.github.io/bsvarPost/reference/compare_half_life_response.md),
  [`compare_time_to_threshold()`](https://davidzenz.github.io/bsvarPost/reference/compare_time_to_threshold.md)
  compare response-shape summaries across models.
- [`compare_restrictions()`](https://davidzenz.github.io/bsvarPost/reference/compare_restrictions.md)
  compares restriction-audit results across models.
- [`compare_hd_event()`](https://davidzenz.github.io/bsvarPost/reference/compare_hd_event.md)
  compares event-window historical decomposition summaries across
  models.
- [`compare_acceptance_diagnostics()`](https://davidzenz.github.io/bsvarPost/reference/compare_acceptance_diagnostics.md)
  compares sign-restriction acceptance diagnostics across models.

### Restriction and acceptance auditing

- [`restriction_audit()`](https://davidzenz.github.io/bsvarPost/reference/restriction_audit.md)
  evaluates whether posterior draws satisfy a set of structural sign or
  narrative restrictions.
- [`magnitude_audit()`](https://davidzenz.github.io/bsvarPost/reference/magnitude_audit.md)
  checks whether impulse responses satisfy magnitude-based restrictions
  with explicit `variable` and `shock` arguments.
- [`acceptance_diagnostics()`](https://davidzenz.github.io/bsvarPost/reference/acceptance_diagnostics.md)
  reports draw-level admissibility statistics for `bsvarSIGNs`
  posteriors, with [`summary()`](https://rdrr.io/r/base/summary.html)
  and [`print()`](https://rdrr.io/r/base/print.html) methods.

### Event-study helpers

- [`tidy_hd_event()`](https://davidzenz.github.io/bsvarPost/reference/tidy_hd_event.md)
  summarises historical decomposition contributions within a
  user-specified event window.
- [`shock_ranking()`](https://davidzenz.github.io/bsvarPost/reference/shock_ranking.md)
  ranks shocks by their contribution to a target variable within an
  event window.

### Plotting and reporting

- `autoplot()` support for all tidy extractors (`PosteriorIR`,
  `PosteriorCDM`, `PosteriorFEVD`, `PosteriorSHOCKS`, `PosteriorHD`,
  `PosteriorFORECAST`), all comparison outputs, simultaneous bands, and
  joint hypothesis objects.
- [`theme_bsvarpost()`](https://davidzenz.github.io/bsvarPost/reference/theme_bsvarpost.md)
  provides a minimal publication-ready ggplot2 theme.
- [`style_bsvar_plot()`](https://davidzenz.github.io/bsvarPost/reference/style_bsvar_plot.md)
  applies consistent axis, legend, and colour styling to any bsvarPost
  ggplot2 output.
- [`publish_bsvar_plot()`](https://davidzenz.github.io/bsvarPost/reference/publish_bsvar_plot.md)
  applies family-aware publication templates across comparison,
  representative, diagnostics, event-study, and joint-inference outputs.
- [`as_gt()`](https://davidzenz.github.io/bsvarPost/reference/as_gt.md),
  [`as_flextable()`](https://davidzenz.github.io/bsvarPost/reference/as_flextable.md),
  and
  [`as_kable()`](https://davidzenz.github.io/bsvarPost/reference/as_kable.md)
  convert tidy bsvarPost tables to formatted gt, flextable, and
  knitr::kable outputs for publication documents.
- [`write_bsvar_csv()`](https://davidzenz.github.io/bsvarPost/reference/write_bsvar_csv.md)
  writes any tidy bsvarPost table to CSV.
- [`report_bundle()`](https://davidzenz.github.io/bsvarPost/reference/report_bundle.md)
  produces a paired plot-and-table bundle suitable for publication
  workflows, with support for representative-response,
  acceptance-diagnostics, simultaneous-band, joint-hypothesis, and
  event-study objects.
- [`report_table()`](https://davidzenz.github.io/bsvarPost/reference/report_table.md)
  generates compact or default publication-oriented table layouts with
  family-specific labels and subtitles.
