# Changelog

## bsvarPost 0.2.0

- Added representative-model selection helpers for IRFs and CDMs:
  [`representative_irf()`](https://davidzenz.github.io/bsvarPost/reference/representative_irf.md),
  [`representative_cdm()`](https://davidzenz.github.io/bsvarPost/reference/representative_cdm.md),
  `median_target_*()`, and `most_likely_admissible_*()`.
- Added posterior hypothesis helpers:
  [`hypothesis_irf()`](https://davidzenz.github.io/bsvarPost/reference/hypothesis_irf.md)
  and
  [`hypothesis_cdm()`](https://davidzenz.github.io/bsvarPost/reference/hypothesis_cdm.md).
- Added audit helpers:
  [`restriction_audit()`](https://davidzenz.github.io/bsvarPost/reference/restriction_audit.md)
  and
  [`magnitude_audit()`](https://davidzenz.github.io/bsvarPost/reference/magnitude_audit.md).
- Added
  [`tidy_hd_event()`](https://davidzenz.github.io/bsvarPost/reference/tidy_hd_event.md)
  and
  [`shock_ranking()`](https://davidzenz.github.io/bsvarPost/reference/shock_ranking.md)
  for event-window historical decomposition summaries.
- Added
  [`peak_response()`](https://davidzenz.github.io/bsvarPost/reference/peak_response.md)
  and
  [`duration_response()`](https://davidzenz.github.io/bsvarPost/reference/duration_response.md)
  for posterior response-shape summaries.
- Added
  [`compare_restrictions()`](https://davidzenz.github.io/bsvarPost/reference/compare_restrictions.md)
  for cross-model restriction-audit comparisons.
- Added
  [`compare_hd_event()`](https://davidzenz.github.io/bsvarPost/reference/compare_hd_event.md)
  for cross-model event-window historical decomposition comparisons.
- Added
  [`compare_peak_response()`](https://davidzenz.github.io/bsvarPost/reference/compare_peak_response.md)
  and
  [`compare_duration_response()`](https://davidzenz.github.io/bsvarPost/reference/compare_duration_response.md)
  for cross-model response-shape comparisons.
- Added
  [`half_life_response()`](https://davidzenz.github.io/bsvarPost/reference/half_life_response.md)
  and
  [`time_to_threshold()`](https://davidzenz.github.io/bsvarPost/reference/time_to_threshold.md)
  for response-decay and threshold-timing summaries.
- Added
  [`compare_half_life_response()`](https://davidzenz.github.io/bsvarPost/reference/compare_half_life_response.md)
  and
  [`compare_time_to_threshold()`](https://davidzenz.github.io/bsvarPost/reference/compare_time_to_threshold.md)
  for cross-model timing-summary comparisons.
- Added
  [`plot_hd_event()`](https://davidzenz.github.io/bsvarPost/reference/plot_hd_event.md)
  and
  [`plot_shock_ranking()`](https://davidzenz.github.io/bsvarPost/reference/plot_shock_ranking.md)
  as dedicated event-study plotting helpers.
- Added
  [`theme_bsvarpost()`](https://davidzenz.github.io/bsvarPost/reference/theme_bsvarpost.md)
  and
  [`style_bsvar_plot()`](https://davidzenz.github.io/bsvarPost/reference/style_bsvar_plot.md)
  for reusable publication-oriented plot styling.
- Added
  [`template_bsvar_plot()`](https://davidzenz.github.io/bsvarPost/reference/template_bsvar_plot.md)
  and
  [`annotate_bsvar_plot()`](https://davidzenz.github.io/bsvarPost/reference/annotate_bsvar_plot.md)
  for output-family templates and publication annotations.
- Added
  [`acceptance_diagnostics()`](https://davidzenz.github.io/bsvarPost/reference/acceptance_diagnostics.md)
  for stored-draw admissibility diagnostics in `bsvarSIGNs`.
- Added [`summary()`](https://rdrr.io/r/base/summary.html) and print
  support for
  [`acceptance_diagnostics()`](https://davidzenz.github.io/bsvarPost/reference/acceptance_diagnostics.md)
  outputs.
- Added
  [`compare_acceptance_diagnostics()`](https://davidzenz.github.io/bsvarPost/reference/compare_acceptance_diagnostics.md)
  and
  [`plot_acceptance_diagnostics()`](https://davidzenz.github.io/bsvarPost/reference/plot_acceptance_diagnostics.md)
  for cross-model diagnostics workflows.
- Added
  [`simultaneous_irf()`](https://davidzenz.github.io/bsvarPost/reference/simultaneous_irf.md),
  [`simultaneous_cdm()`](https://davidzenz.github.io/bsvarPost/reference/simultaneous_cdm.md),
  [`joint_hypothesis_irf()`](https://davidzenz.github.io/bsvarPost/reference/joint_hypothesis_irf.md),
  and
  [`joint_hypothesis_cdm()`](https://davidzenz.github.io/bsvarPost/reference/joint_hypothesis_cdm.md)
  for first-pass joint inference support.
- Added
  [`plot_simultaneous()`](https://davidzenz.github.io/bsvarPost/reference/plot_simultaneous.md)
  and
  [`plot_joint_hypothesis()`](https://davidzenz.github.io/bsvarPost/reference/plot_joint_hypothesis.md)
  for direct visualisation of simultaneous bands and joint posterior
  probability statements.
- Added
  [`plot_hypothesis()`](https://davidzenz.github.io/bsvarPost/reference/plot_hypothesis.md)
  and
  [`plot_restriction_audit()`](https://davidzenz.github.io/bsvarPost/reference/plot_restriction_audit.md)
  as dedicated plotting helpers for posterior statements and restriction
  audits.
- Updated README and vignette comparison examples to use genuinely
  different model specifications instead of self-comparisons.
- Added
  [`plot_compare_response()`](https://davidzenz.github.io/bsvarPost/reference/plot_compare_response.md)
  and
  [`plot_compare_restrictions()`](https://davidzenz.github.io/bsvarPost/reference/plot_compare_restrictions.md)
  for dedicated visualisation of comparison-table outputs.
- Added
  [`as_kable()`](https://davidzenz.github.io/bsvarPost/reference/reporting.md),
  [`as_gt()`](https://davidzenz.github.io/bsvarPost/reference/reporting.md),
  [`as_flextable()`](https://davidzenz.github.io/bsvarPost/reference/reporting.md),
  and
  [`write_bsvar_csv()`](https://davidzenz.github.io/bsvarPost/reference/reporting.md)
  as first-pass reporting and export helpers for tidy `bsvarPost`
  tables.
- Added
  [`report_bundle()`](https://davidzenz.github.io/bsvarPost/reference/reporting.md)
  as a first-pass plot-and-table bundle for publication workflows.
- Added
  [`report_table()`](https://davidzenz.github.io/bsvarPost/reference/reporting.md)
  and compact/default reporting presets for publication-oriented table
  layouts.
- Extended
  [`report_bundle()`](https://davidzenz.github.io/bsvarPost/reference/reporting.md)
  to support representative-response and acceptance-diagnostics
  workflows.
- Extended
  [`report_bundle()`](https://davidzenz.github.io/bsvarPost/reference/reporting.md)
  to support simultaneous-band and joint-hypothesis outputs.
- Extended
  [`report_bundle()`](https://davidzenz.github.io/bsvarPost/reference/reporting.md)
  to support event-study tables and object-family default captions.
- Added
  [`publish_bsvar_plot()`](https://davidzenz.github.io/bsvarPost/reference/publish_bsvar_plot.md)
  for family-aware publication templates across comparison,
  representative, diagnostics, event-study, and joint-inference outputs.
- Added publication-facing report-table labels and short family-specific
  subtitles for representative, diagnostics, event-study,
  simultaneous-band, and joint-hypothesis plots.
- Expanded the vignettes with clearer interpretation notes, non-trivial
  comparison examples, and lightweight rendered table/plot showcases.
- Added pkgdown site scaffolding, including site configuration, homepage
  content, reference grouping, and a GitHub Pages deployment workflow.
- Added a second vignette, `Post-Estimation Workflows in bsvarPost`, to
  separate workflow/methodology documentation from getting-started
  material.
- Added restriction constructor helpers for IRF, structural, and
  narrative audits.

## bsvarPost 0.1.0

- Initial release.
- Added cross-package
  [`cdm()`](https://davidzenz.github.io/bsvarPost/reference/cdm.md)
  support for posterior objects from `bsvars` and `bsvarSIGNs`.
- Added `PosteriorCDM` summary and plotting methods.
- Added tidy extractors for impulse responses, cumulative dynamic
  multipliers, variance decompositions, shocks, historical
  decompositions, and forecasts.
- Added comparison helpers for IRFs, CDMs, FEVDs, and forecasts.
- Added `ggplot2` autoplot support for tidy and comparison outputs.
- Added bridge helpers for APRScenario-style forecast tables.
- Added optional `tsibble` conversion for tidy outputs.
