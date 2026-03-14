# Changelog

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
  compute simultaneous credible bands with exact joint coverage.

### Representative model selection

- [`representative_irf()`](https://davidzenz.github.io/bsvarPost/reference/representative_irf.md)
  and
  [`representative_cdm()`](https://davidzenz.github.io/bsvarPost/reference/representative_cdm.md)
  identify the posterior draw closest to the pointwise median across all
  impulse-response or CDM paths.
- [`most_likely_admissible_irf()`](https://davidzenz.github.io/bsvarPost/reference/representative_irf.md)
  and
  [`most_likely_admissible_cdm()`](https://davidzenz.github.io/bsvarPost/reference/representative_cdm.md)
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
- [`as_gt()`](https://davidzenz.github.io/bsvarPost/reference/reporting.md),
  [`as_flextable()`](https://davidzenz.github.io/bsvarPost/reference/reporting.md),
  and
  [`as_kable()`](https://davidzenz.github.io/bsvarPost/reference/reporting.md)
  convert tidy bsvarPost tables to formatted gt, flextable, and
  knitr::kable outputs for publication documents.
- [`write_bsvar_csv()`](https://davidzenz.github.io/bsvarPost/reference/reporting.md)
  writes any tidy bsvarPost table to CSV.
- [`report_bundle()`](https://davidzenz.github.io/bsvarPost/reference/reporting.md)
  produces a paired plot-and-table bundle suitable for publication
  workflows, with support for representative-response,
  acceptance-diagnostics, simultaneous-band, joint-hypothesis, and
  event-study objects.
- [`report_table()`](https://davidzenz.github.io/bsvarPost/reference/reporting.md)
  generates compact or default publication-oriented table layouts with
  family-specific labels and subtitles.
