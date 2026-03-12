---
phase: 03-output-correctness-verification
plan: 04
subsystem: testing
tags: [tinytest, compare, rbind, numerical-verification, tolerance-1e-10]

# Dependency graph
requires:
  - phase: 02-input-validation-foundation
    provides: validated compare_* functions in R/compare.R
provides:
  - Compare function merging logic correctness verification (59 tests)
  - Proof that compare_irf, compare_cdm, compare_fevd, compare_restrictions, compare_peak_response, compare_duration_response produce identical output to rbind of individual calls
affects: [05-testing-robustness, 06-hypothesis-engine]

# Tech tracking
tech-stack:
  added: []
  patterns: [compare-vs-rbind verification pattern, two-model S=30 fixture with different seeds]

key-files:
  created:
    - inst/tinytest/test_verify_compare.R
  modified: []

key-decisions:
  - "S=30 draws with seed 2026/2027 provides sufficient posterior variation for numerical comparison"
  - "Tests verify all summary columns (median, mean, lower, upper) not just one statistic"

patterns-established:
  - "Compare verification: call compare_* then call individual functions with model= argument, subset by model column, check numerical equality at 1e-10"

# Metrics
duration: 2min
completed: 2026-03-12
---

# Phase 03 Plan 04: Compare Function Merging Verification Summary

**59 tinytest assertions verify all compare_* wrappers produce output numerically identical to rbind of individual tidy/audit/response calls at 1e-10 tolerance**

## Performance

- **Duration:** 2 min
- **Started:** 2026-03-12T13:51:45Z
- **Completed:** 2026-03-12T13:53:16Z
- **Tasks:** 1
- **Files modified:** 1

## Accomplishments
- Verified compare_irf matches rbind(tidy_irf(m1), tidy_irf(m2)) for all summary columns
- Verified compare_cdm, compare_fevd follow same pattern with identical numerical results
- Verified compare_restrictions matches rbind(restriction_audit(m1), restriction_audit(m2))
- Verified compare_peak_response and compare_duration_response match individual calls
- Confirmed model labels derived from named arguments (baseline/alternative test)
- Confirmed compare attribute is TRUE on all compare_* outputs
- All 59 tests pass, zero failures

## Task Commits

Each task was committed atomically:

1. **Task 1: Create compare function merging verification tests** - `6314e95` (test)

## Files Created/Modified
- `inst/tinytest/test_verify_compare.R` - 151-line test file with 7 test groups (compare_irf, compare_cdm, compare_fevd, compare_restrictions, compare_peak_response, compare_duration_response, model naming)

## Decisions Made
- Used S=30 with seeds 2026/2027 for two distinct posteriors providing sufficient variation
- Tested all summary statistics (median, mean, lower, upper) for each compare function, not just one column
- Included both tidy-family (irf, cdm, fevd) and response-summary (peak, duration) and audit (restrictions) compare wrappers

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- All four Phase 03 verification plans can now proceed independently (03-01, 03-02, 03-03 are separate wave-1 plans)
- Compare function correctness proven at 1e-10 tolerance for publication-grade research output

---
*Phase: 03-output-correctness-verification*
*Completed: 2026-03-12*
