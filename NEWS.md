# bsvarPost 0.2.0

- Added representative-model selection helpers for IRFs and CDMs:
  `representative_irf()`, `representative_cdm()`, `median_target_*()`,
  and `most_likely_admissible_*()`.
- Added posterior hypothesis helpers: `hypothesis_irf()` and
  `hypothesis_cdm()`.
- Added audit helpers: `restriction_audit()` and `magnitude_audit()`.
- Added `tidy_hd_event()` and `shock_ranking()` for event-window historical decomposition summaries.
- Added `peak_response()` and `duration_response()` for posterior response-shape summaries.
- Added `compare_restrictions()` for cross-model restriction-audit comparisons.
- Added `compare_hd_event()` for cross-model event-window historical decomposition comparisons.
- Added `compare_peak_response()` and `compare_duration_response()` for cross-model response-shape comparisons.
- Added `half_life_response()` and `time_to_threshold()` for response-decay and threshold-timing summaries.
- Added `compare_half_life_response()` and `compare_time_to_threshold()` for cross-model timing-summary comparisons.
- Added `plot_hd_event()` and `plot_shock_ranking()` as dedicated event-study plotting helpers.
- Added `theme_bsvarpost()` and `style_bsvar_plot()` for reusable publication-oriented plot styling.
- Added `template_bsvar_plot()` and `annotate_bsvar_plot()` for output-family templates and publication annotations.
- Added `acceptance_diagnostics()` for stored-draw admissibility diagnostics in `bsvarSIGNs`.
- Added `summary()` and print support for `acceptance_diagnostics()` outputs.
- Added `compare_acceptance_diagnostics()` and `plot_acceptance_diagnostics()` for cross-model diagnostics workflows.
- Added `simultaneous_irf()`, `simultaneous_cdm()`, `joint_hypothesis_irf()`, and `joint_hypothesis_cdm()` for first-pass joint inference support.
- Added `plot_simultaneous()` and `plot_joint_hypothesis()` for direct visualisation of simultaneous bands and joint posterior probability statements.
- Added `plot_hypothesis()` and `plot_restriction_audit()` as dedicated plotting helpers for posterior statements and restriction audits.
- Added a second vignette, `Post-Estimation Workflows in bsvarPost`, to separate workflow/methodology documentation from getting-started material.
- Added restriction constructor helpers for IRF, structural, and narrative
  audits.

# bsvarPost 0.1.0

- Initial release.
- Added cross-package `cdm()` support for posterior objects from `bsvars` and
  `bsvarSIGNs`.
- Added `PosteriorCDM` summary and plotting methods.
- Added tidy extractors for impulse responses, cumulative dynamic multipliers,
  variance decompositions, shocks, historical decompositions, and forecasts.
- Added comparison helpers for IRFs, CDMs, FEVDs, and forecasts.
- Added `ggplot2` autoplot support for tidy and comparison outputs.
- Added bridge helpers for APRScenario-style forecast tables.
- Added optional `tsibble` conversion for tidy outputs.
