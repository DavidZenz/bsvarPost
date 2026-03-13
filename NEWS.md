# bsvarPost 1.0.0

Initial CRAN release.

## Breaking changes and deprecations

* The `variable` and `shock` (singular) arguments are deprecated in favour of
  `variables` and `shocks` (plural) throughout the package. The singular forms
  still work and produce a warning; they will be removed in a future version.

## Core posterior extraction

* `tidy_irf()` extracts impulse responses from `PosteriorBSVAR`,
  `PosteriorBSVARSV`, `PosteriorBSVARMIX`, `PosteriorBSVARMSH`,
  `PosteriorBSVART`, and `PosteriorBSVARSIGN` objects into tidy tibbles with
  credible-interval columns.
* `tidy_cdm()` extracts cumulative dynamic multipliers for all supported
  posterior types.
* `tidy_fevd()` extracts forecast error variance decompositions (reported on
  the 0–100 percentage scale used by 'bsvars').
* `tidy_shocks()` extracts structural shocks.
* `tidy_hd()` extracts historical decompositions.
* `tidy_forecast()` extracts out-of-sample forecasts.
* `cdm()` estimates cumulative dynamic multipliers directly from any supported
  posterior object, bridging 'bsvars' and 'bsvarSIGNs' in a single call.

## Hypothesis testing and inference

* `hypothesis_irf()` and `hypothesis_cdm()` compute posterior probabilities for
  user-specified inequality constraints on impulse responses and cumulative
  dynamic multipliers.
* `joint_hypothesis_irf()` and `joint_hypothesis_cdm()` extend hypothesis
  testing to joint constraints across multiple variable–shock–horizon
  combinations.
* `simultaneous_irf()` and `simultaneous_cdm()` compute simultaneous credible
  bands with exact joint coverage.

## Representative model selection

* `representative_irf()` and `representative_cdm()` identify the posterior
  draw closest to the pointwise median across all impulse-response or CDM
  paths.
* `most_likely_admissible_irf()` and `most_likely_admissible_cdm()` select the
  draw with the highest kernel score among sign-restriction-admissible draws.

## Response summaries

* `peak_response()` locates the horizon of maximum absolute impulse response
  and its posterior distribution.
* `duration_response()` summarises the number of horizons for which a response
  remains above a threshold.
* `half_life_response()` computes the posterior distribution of the half-life
  of a response decay.
* `time_to_threshold()` computes the posterior distribution of the first
  horizon at which a response crosses a user-specified threshold.

## Model comparison

* `compare_irf()`, `compare_cdm()`, `compare_fevd()` compare tidy extractions
  across two models side-by-side.
* `compare_peak_response()`, `compare_duration_response()`,
  `compare_half_life_response()`, `compare_time_to_threshold()` compare
  response-shape summaries across models.
* `compare_restrictions()` compares restriction-audit results across models.
* `compare_hd_event()` compares event-window historical decomposition summaries
  across models.
* `compare_acceptance_diagnostics()` compares sign-restriction acceptance
  diagnostics across models.

## Restriction and acceptance auditing

* `restriction_audit()` evaluates whether posterior draws satisfy a set of
  structural sign or narrative restrictions.
* `magnitude_audit()` checks whether impulse responses satisfy magnitude-based
  restrictions with explicit `variable` and `shock` arguments.
* `acceptance_diagnostics()` reports draw-level admissibility statistics for
  `bsvarSIGNs` posteriors, with `summary()` and `print()` methods.

## Event-study helpers

* `tidy_hd_event()` summarises historical decomposition contributions within a
  user-specified event window.
* `shock_ranking()` ranks shocks by their contribution to a target variable
  within an event window.

## Plotting and reporting

* `autoplot()` support for all tidy extractors (`PosteriorIR`,
  `PosteriorCDM`, `PosteriorFEVD`, `PosteriorSHOCKS`, `PosteriorHD`,
  `PosteriorFORECAST`), all comparison outputs, simultaneous bands, and joint
  hypothesis objects.
* `theme_bsvarpost()` provides a minimal publication-ready ggplot2 theme.
* `style_bsvar_plot()` applies consistent axis, legend, and colour styling to
  any bsvarPost ggplot2 output.
* `publish_bsvar_plot()` applies family-aware publication templates across
  comparison, representative, diagnostics, event-study, and joint-inference
  outputs.
* `as_gt()`, `as_flextable()`, and `as_kable()` convert tidy bsvarPost tables
  to formatted gt, flextable, and knitr::kable outputs for publication
  documents.
* `write_bsvar_csv()` writes any tidy bsvarPost table to CSV.
* `report_bundle()` produces a paired plot-and-table bundle suitable for
  publication workflows, with support for representative-response,
  acceptance-diagnostics, simultaneous-band, joint-hypothesis, and event-study
  objects.
* `report_table()` generates compact or default publication-oriented table
  layouts with family-specific labels and subtitles.
