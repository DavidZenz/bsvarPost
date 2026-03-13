---
phase: 06-api-consistency-error-messages
plan: 02
subsystem: api-defaults-and-deprecation
tags: [probability-defaults, horizon-defaults, deprecation-shims, singular-to-plural]
dependency_graph:
  requires: [06-01]
  provides: [consistent-probability-defaults, consistent-horizon-defaults, deprecation-shims-singular-plural]
  affects: [R/tidy.R, R/cdm.R, R/hypothesis.R, R/audit.R, R/representative.R, R/hd-event.R, R/v2-utils.R, R/aprscenario.R, R/plot-event.R, R/plot-joint-inference.R, R/plot-statements.R, R/response-summary.R, R/joint-inference.R]
tech_stack:
  added: []
  patterns: [deprecate_arg(), resolve_horizon(), plural-param-convention]
key_files:
  created: []
  modified:
    - R/tidy.R
    - R/cdm.R
    - R/hypothesis.R
    - R/audit.R
    - R/representative.R
    - R/hd-event.R
    - R/v2-utils.R
    - R/aprscenario.R
    - R/plot-event.R
    - R/plot-joint-inference.R
    - R/plot-statements.R
    - R/response-summary.R
    - R/joint-inference.R
decisions:
  - "hypothesis_irf/hypothesis_cdm plural migration: variables/shocks added as new params, variable/shock kept as deprecated — horizon remains required (constraint specifier not a selection param)"
  - "summarise_*_draws internal helpers renamed to plural variables/shocks params (no deprecation shim needed for internal functions)"
  - "hardcoded 0.68 in compute_representative_draw target_summary and summarise_gap_matrix also updated to 0.90"
metrics:
  duration: 11 minutes
  completed: 2026-03-13
  tasks: 2
  files: 13
---

# Phase 6 Plan 02: Default Consistency and Deprecation Shims Summary

Complete the mechanical default changes (probability 0.68->0.90, horizon 10->NULL with resolve_horizon()) across 13 R files, and add singular->plural deprecation shims to response-summary, joint-inference, and hypothesis functions.

## Tasks Completed

### Task 1: Update probability and horizon defaults across all R source files

- **Commit:** c55b230
- **Files:** R/tidy.R, R/cdm.R, R/hypothesis.R, R/audit.R, R/representative.R, R/hd-event.R, R/v2-utils.R, R/aprscenario.R, R/plot-event.R, R/plot-joint-inference.R, R/plot-statements.R, R/response-summary.R, R/joint-inference.R

Changes made:
- Replaced all `probability = 0.68` defaults with `probability = 0.90` (zero instances remain)
- Replaced all `horizon = 10` defaults with `horizon = NULL` (zero instances remain)
- Added `resolve_horizon(horizon)` calls wherever horizon is passed to bsvars compute functions: tidy_irf_model, tidy_cdm_model, tidy_fevd_model, tidy_forecast_model, cdm_from_model, get_irf_draws (v2-utils), representative_irf_model, representative_cdm_model, simultaneous_irf_model, simultaneous_cdm_model, peak/duration/half_life/time_to_threshold _model functions
- Fixed hardcoded 0.68 in `compute_representative_draw` target_summary call
- Fixed hardcoded 0.68 in `summarise_gap_matrix` internal helper

**Verification:** `grep -rn "probability = 0.68" R/` returns zero matches. `grep -rn "horizon = 10[^0-9]" R/` returns zero matches.

### Task 2: Add deprecation shims for singular variable/shock in response-summary.R and joint-inference.R

- **Commit:** 2c9f4aa
- **Files:** R/response-summary.R, R/joint-inference.R, R/hypothesis.R

Changes made:
- **response-summary.R:** All 4 function families (peak_response, duration_response, half_life_response, time_to_threshold) updated:
  - PosteriorIR methods: added `variables = NULL, shocks = NULL` before deprecated `variable = NULL, shock = NULL`
  - PosteriorCDM methods: same pattern
  - _model helpers: same pattern with deprecate_arg() calls
  - Internal summarise_*_draws helpers: renamed params from `variable`/`shock` to `variables`/`shocks` (no shim needed for internals)
  - Roxygen @param on generics updated with deprecation notices
- **joint-inference.R:** simultaneous_irf and simultaneous_cdm updated:
  - PosteriorIR/PosteriorCDM methods: added plural params with deprecation shims
  - _model helpers: same pattern
  - `simultaneous_band_impl` internal helper: renamed to plural
  - Roxygen @param on generics updated
- **hypothesis.R:** hypothesis_irf and hypothesis_cdm updated:
  - PosteriorIR/PosteriorCDM methods: `variables`/`shocks` added, `variable`/`shock` kept as deprecated; `horizon` remains required (it is a constraint specifier, not a selection param)
  - _model helpers: same pattern
  - Roxygen @param on generics updated

**Verification:** `grep -c "deprecate_arg" R/response-summary.R R/joint-inference.R R/hypothesis.R` returns 24, 8, 8 respectively.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing coverage] `summarise_gap_matrix` hardcoded 0.68**
- **Found during:** Task 1 verification grep
- **Issue:** Internal helper `summarise_gap_matrix` in v2-utils.R had `probability = 0.68` default — missed in initial pass
- **Fix:** Updated to `probability = 0.90`
- **Files modified:** R/v2-utils.R
- **Commit:** c55b230

**2. [Rule 2 - Missing coverage] `hypothesis.R` not in plan's Task 2 scope but identified in plan description**
- **Found during:** Plan reading — plan mentions hypothesis_irf/hypothesis_cdm in the task description
- **Issue:** Plan Task 2 lists hypothesis.R in the action text but not in the `<files>` tag
- **Fix:** Applied deprecation shims to hypothesis_irf/hypothesis_cdm per the plan action text
- **Files modified:** R/hypothesis.R
- **Commit:** 2c9f4aa

## Self-Check: PASSED

- SUMMARY.md: FOUND
- Commit c55b230 (Task 1 - defaults): FOUND
- Commit 2c9f4aa (Task 2 - shims): FOUND
