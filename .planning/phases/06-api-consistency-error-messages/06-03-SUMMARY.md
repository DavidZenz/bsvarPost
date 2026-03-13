---
phase: 06-api-consistency-error-messages
plan: "03"
subsystem: testing
tags: [tinytest, api-consistency, deprecation, validation, defaults, documentation]
dependency_graph:
  requires:
    - phase: 06-01
      provides: deprecate_arg, resolve_horizon, dimension assertions, column validation, validate_model_compatibility
    - phase: 06-02
      provides: probability=0.90/horizon=NULL defaults, singular->plural deprecation shims
  provides:
    - 28-test test_api_consistency.R covering all Phase 6 validators and deprecation shims
    - Updated plural params in test_joint_inference.R and test_plot_joint_inference.R
    - Regenerated man/ pages with updated defaults and deprecation notices
  affects:
    - Future phases using test infrastructure
    - R CMD check (documentation must remain in sync)
tech_stack:
  added: []
  patterns:
    - "Tests call internal helpers via bsvarPost::: triple-colon syntax"
    - "Deprecation tests use expect_warning(pattern='deprecated') for singular params"
    - "Column validation tests require only 'model' column in new_bsvar_post_tbl"
key_files:
  created:
    - inst/tinytest/test_api_consistency.R
    - man/deprecate_arg.Rd
    - man/resolve_horizon.Rd
  modified:
    - inst/tinytest/test_joint_inference.R
    - inst/tinytest/test_plot_joint_inference.R
    - R/utils.R
    - man/ (34 updated .Rd files)
key_decisions:
  - "new_bsvar_post_tbl column validation requires only 'model' column, not 'object_type' — object_type is stored as attribute, not column, in many callers (restriction_audit, joint-inference, etc.)"
  - "test_api_consistency.R tests all Phase 6 additions: deprecate_arg, resolve_horizon, dimension assertions, column validation, validate_model_compatibility, return types, deprecation warnings"
  - "Singular params in test_joint_inference.R updated to plural for simultaneous_irf/cdm; joint_hypothesis_irf/cdm kept singular (those functions not yet migrated to plural)"
  - "Infrastructure check warnings (vignettes, .git, ..Rcheck) are pre-existing worktree issues, not Phase 6 regressions"
metrics:
  duration: "12 min"
  completed: "2026-03-13"
  tasks_completed: 2
  files_modified: 37
---

# Phase 6 Plan 03: Test Updates, API Consistency Tests, and Documentation Summary

**28-test test_api_consistency.R covering deprecate_arg/resolve_horizon helpers, dimension guards, column validation, model compatibility checks, return type consistency, and deprecation warnings; plus man/ regeneration for 35 updated .Rd files.**

## Performance

- **Duration:** 12 min
- **Started:** 2026-03-13T05:19:45Z
- **Completed:** 2026-03-13T05:32:10Z
- **Tasks:** 2
- **Files modified:** 37

## Accomplishments

- Created `test_api_consistency.R` with 28 tests verifying all Phase 6 validator/deprecation additions
- Updated `test_joint_inference.R` and `test_plot_joint_inference.R` to use plural `variables`/`shocks` params for `simultaneous_irf`/`simultaneous_cdm` (functions that have deprecation shims)
- Fixed a bug in `new_bsvar_post_tbl()` column validation: required columns was `c("model", "object_type")` but `object_type` is stored as an attribute, not a column, in many callers - corrected to require only `c("model")`
- Regenerated 35 man/*.Rd files picking up updated probability=0.90/horizon=NULL defaults and new deprecation notices for variable/shock params
- All 941 tests pass with zero failures (913 pre-existing + 28 new)

## Task Commits

1. **Task 1: Update existing tests and create API consistency test file** - `88400c5` (test)
2. **Task 2: Regenerate documentation and run R CMD check** - `fd5ef31` (docs)

## Files Created/Modified

- `inst/tinytest/test_api_consistency.R` - New: 28 tests for Phase 6 validators, deprecation, return types
- `inst/tinytest/test_joint_inference.R` - Updated: simultaneous_cdm/irf calls use plural params
- `inst/tinytest/test_plot_joint_inference.R` - Updated: simultaneous_irf call uses plural params
- `R/utils.R` - Fixed: new_bsvar_post_tbl() column validation requires only 'model' not 'object_type'
- `man/deprecate_arg.Rd` - New: auto-generated from @keywords internal in validation.R
- `man/resolve_horizon.Rd` - New: auto-generated from @keywords internal in validation.R
- `man/*.Rd` (34 others) - Updated: probability=0.90, horizon=NULL, deprecation notices

## Decisions Made

- `new_bsvar_post_tbl()` column validation requires only `model` column: `object_type` is passed as argument and stored as an attribute, not as a data frame column, in many callers including `restriction_audit`, `joint-inference.R`, `hd-event.R`, `diagnostics.R`. The Phase 06-01 implementation that required both `model` and `object_type` was too strict.
- `test_api_consistency.R` tests call internal helpers via `bsvarPost:::` triple-colon syntax, consistent with existing `test_validation.R` pattern.
- Infrastructure R CMD check warnings (vignette compilation, .git visibility, ..Rcheck directory) are pre-existing worktree setup issues - all documentation and code checks return clean.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed new_bsvar_post_tbl() over-strict column validation**
- **Found during:** Task 1 (running full test suite after installing updated package)
- **Issue:** Phase 06-01 added column validation requiring both `model` AND `object_type` columns. However, `object_type` is stored as an attribute (set via the `object_type` argument), not as a data frame column, in many callers: `restriction_audit` (audit.R), `simultaneous_band_impl` (joint-inference.R), `joint_hypothesis_impl` (joint-inference.R), `audit_narrative_restriction` (audit.R), `hd_event_from_model` (hd-event.R), `acceptance_diagnostics` (diagnostics.R), `representative_irf`/`cdm` (representative.R). The validation caused `restriction_audit` to throw "missing required columns: object_type".
- **Fix:** Changed `required_cols <- c("model", "object_type")` to `required_cols <- c("model")` in `new_bsvar_post_tbl()`. Updated `test_api_consistency.R` test to use only `model` column in the valid-case fixture.
- **Files modified:** R/utils.R, inst/tinytest/test_api_consistency.R
- **Verification:** All 941 tests pass; test_api_consistency.R's column validation test still triggers error on data.frame missing 'model'
- **Committed in:** 88400c5 (Task 1 commit)

---

**Total deviations:** 1 auto-fixed (Rule 1 - Bug)
**Impact on plan:** Fix necessary for correctness — the over-strict validation broke restriction_audit and 6 other functions. No scope creep.

## Issues Encountered

- The installed bsvarPost package was the old version (before Phase 6 changes), so internal functions like `deprecate_arg` were not accessible via `bsvarPost:::` until `R CMD INSTALL` was run. This is expected in the worktree workflow — the package must be installed to run tests against the installed version.

## Next Phase Readiness

- Phase 6 Plans 01-02-03 complete: all validation/deprecation infrastructure implemented, tested, and documented
- Phase 6 is ready to proceed to Plan 04 if additional plans exist, or close out the phase
- All 941 tests pass; R CMD check documentation and code checks clean

---
*Phase: 06-api-consistency-error-messages*
*Completed: 2026-03-13*

## Self-Check: PASSED

- inst/tinytest/test_api_consistency.R: FOUND
- R/utils.R: FOUND
- .planning/phases/06-api-consistency-error-messages/06-03-SUMMARY.md: FOUND
- Commit 88400c5 (test - Task 1): FOUND
- Commit fd5ef31 (docs - Task 2): FOUND
