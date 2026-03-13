---
phase: 06-api-consistency-error-messages
plan: "01"
subsystem: validation-and-compare-infrastructure
tags: [validation, error-messages, api-consistency, deprecation, defaults]
dependency_graph:
  requires: []
  provides:
    - deprecate_arg() helper in R/validation.R
    - resolve_horizon() helper in R/validation.R
    - dimension assertions in set_*_dimnames() in R/utils.R
    - column validation in new_bsvar_post_tbl() in R/utils.R
    - validate_model_compatibility() in R/compare.R
  affects:
    - R/validation.R
    - R/utils.R
    - R/compare.R
    - All compare_* functions (defaults and validation)
tech_stack:
  added: []
  patterns:
    - deprecate_arg() for smooth argument renaming with warnings
    - resolve_horizon() for NULL-to-20L default resolution
    - Dimension assertions at function entry points
    - validate_model_compatibility() before rbind in compare_* functions
key_files:
  created: []
  modified:
    - R/validation.R
    - R/utils.R
    - R/compare.R
decisions:
  - resolve_horizon(NULL) returns 20L (business-cycle convention: covers full cycle dynamics)
  - deprecate_arg() gives new_val precedence when both old and new are provided
  - validate_model_compatibility() placed after lapply() and before do.call(rbind) in compare_* functions
  - compare_acceptance_diagnostics excluded from validate_model_compatibility (no variable column)
  - Dimension assertions use deparse-free class reporting for non-array inputs
metrics:
  duration: "3 min"
  completed: "2026-03-13"
  tasks_completed: 3
  files_modified: 3
---

# Phase 6 Plan 01: Validation Infrastructure and Compare Defaults Summary

**One-liner:** Validation helpers (deprecate_arg, resolve_horizon), structural dimension/column guards, model compatibility checks, and updated probability=0.90/horizon=NULL defaults across validation.R, utils.R, and compare.R.

## What Was Built

### Task 1: R/validation.R
- Updated `validate_horizon()` and `validate_probability()` error messages to include "Received: {value}" for all error cases. Used `deparse()` for potentially non-scalar values (NULL, vectors) and raw value for guaranteed-scalar checks.
- Added `deprecate_arg(new_val, old_val, old_name, new_name, fn_name)`: issues a `warning()` when `old_val` is not NULL; returns `old_val` when `new_val` is NULL, otherwise returns `new_val` (new takes precedence).
- Added `resolve_horizon(horizon, default = 20L, arg_name = "horizon")`: returns `as.integer(default)` when `horizon` is NULL; otherwise delegates to `validate_horizon()`. Default of 20 follows econometric convention for covering business cycle dynamics.

### Task 2: R/utils.R
- Added 4-dimensional array assertion at the start of `set_response_dimnames()`.
- Added 3-dimensional array assertion at the start of `set_time_dimnames()`.
- Added 4-dimensional array assertion at the start of `set_hd_dimnames()`.
- Added required-column validation in `new_bsvar_post_tbl()`: checks that `model` and `object_type` columns exist before setting the S3 class.
- Updated `probability` defaults from `0.68` to `0.90` in `as_tidy_response_array()`, `as_tidy_time_array()`, and `as_tidy_hd_array()`.

### Task 3: R/compare.R
- Added `validate_model_compatibility()` as a local function: checks that all models share identical variable names; if a `horizon` column is present, also checks that all models share identical horizon ranges. Errors include actual values for both Model 1 and the offending model.
- Inserted `validate_model_compatibility()` call in 10 compare_* functions: compare_irf, compare_cdm, compare_fevd, compare_forecast, compare_restrictions, compare_hd_event, compare_peak_response, compare_duration_response, compare_half_life_response, compare_time_to_threshold. (compare_acceptance_diagnostics excluded — its output has no `variable` column.)
- Updated `probability` defaults from `0.68` to `0.90` in all 10 compare_* function signatures.
- Updated `horizon` defaults from `10` to `NULL` in 8 functions (compare_irf, compare_cdm, compare_fevd, compare_forecast, compare_peak_response, compare_duration_response, compare_half_life_response, compare_time_to_threshold); pass through `resolve_horizon(horizon)` when calling downstream tidy_*/response-summary functions.
- Added `variables`/`shocks` parameters with `variable`/`shock` deprecation shims in compare_peak_response, compare_duration_response, compare_half_life_response, compare_time_to_threshold. The shims call `deprecate_arg()` at function entry.

## Commits

| Task | Commit | Message |
|------|--------|---------|
| Task 1 | da2ddc5 | feat(06-01): add deprecate_arg, resolve_horizon, and Received values to validation.R |
| Task 2 | d23f503 | feat(06-01): add dimension assertions, column validation, and update probability defaults in utils.R |
| Task 3 | 52a191f | feat(06-01): add model compatibility validation and update defaults in compare.R |

## Verification Results

```
probability = 0.68 occurrences in validation.R, utils.R, compare.R: 0, 0, 0
horizon = 10 occurrences in compare.R: 0
deprecate_arg definitions in validation.R: 1
resolve_horizon definitions in validation.R: 1
dimension assertions in utils.R: 3
column validation in utils.R: 1
validate_model_compatibility references in compare.R: 11 (1 definition + 10 call sites)
Received: in validation.R error messages: 12
```

## Deviations from Plan

None - plan executed exactly as written.

## Self-Check: PASSED

All three source files exist. All three commits confirmed present in git log.
