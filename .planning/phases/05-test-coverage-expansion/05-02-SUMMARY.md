---
phase: 05-test-coverage-expansion
plan: 02
subsystem: testing
tags: [tinytest, S3-dispatch, PosteriorBSVARSV, PosteriorBSVARSIGN, compare, coverage]

# Dependency graph
requires:
  - phase: 05-test-coverage-expansion
    provides: test coverage expansion plan and research
provides:
  - S3 dispatch coverage for all 9 testable compare_* functions with PosteriorBSVARSV
  - S3 dispatch coverage for 10 key functions with PosteriorBSVARSIGN
  - Tests for compare_forecast, most_likely_admissible_cdm, and apr_gen_mats (previously zero-reference)
affects:
  - 05-test-coverage-expansion (subsequent plans building on coverage baseline)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "check_compare_tbl helper pattern: shared inline function to verify bsvar_post_tbl structure, nrow > 0, model column, compare attr"
    - "Graceful APRScenario gate: requireNamespace check with both error-path and success-path tests"
    - "most_likely_admissible_cdm error-on-non-SIGN test: expect_error with pattern matching before testing the valid path"

key-files:
  created:
    - inst/tinytest/test_dispatch_compare.R
    - inst/tinytest/test_dispatch_sign.R
    - inst/tinytest/test_zero_coverage.R
  modified: []

key-decisions:
  - "shock_ranking uses time labels (not integer horizons) as start/end args - requires tidy_hd() to extract valid time strings"
  - "compare_restrictions is PosteriorBSVARSIGN-specific - tested only in test_dispatch_sign.R, not test_dispatch_compare.R"
  - "most_likely_admissible_cdm same draw_index as most_likely_admissible_irf - both select by kernel score, verified equal"
  - "APRScenario tests gracefully handle absent package using requireNamespace gate + error message check"

patterns-established:
  - "Inline helper functions (check_compare_tbl) for repeated assertions reduce test verbosity"
  - "suppressMessages() wraps bsvars::estimate() for PosteriorBSVARSIGN to suppress informational output"
  - "Two-posterior fixture (post_sign + post_sign2) for compare_* tests with identical spec, different seeds"

# Metrics
duration: 15min
completed: 2026-03-12
---

# Phase 5 Plan 02: Compare Dispatch and Zero-Coverage Tests Summary

**99 tests across 3 new files covering all 9 testable compare_* functions for PosteriorBSVARSV, 10 key generics for PosteriorBSVARSIGN, and the 3 previously untested exported functions (compare_forecast, most_likely_admissible_cdm, apr_gen_mats)**

## Performance

- **Duration:** 15 min
- **Started:** 2026-03-12T19:42:50Z
- **Completed:** 2026-03-12T19:57:00Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments
- Created test_dispatch_compare.R with 50 tests covering all 9 testable compare_* functions for PosteriorBSVARSV with full structure validation (bsvar_post_tbl, compare attr, model column, type-specific columns)
- Created test_zero_coverage.R with 19 tests eliminating zero-reference status for compare_forecast, most_likely_admissible_cdm (including SIGN fixture and error-on-non-SIGN), and apr_gen_mats (requireNamespace gate both paths)
- Created test_dispatch_sign.R with 30 tests verifying PosteriorBSVARSIGN dispatch across tidy, hypothesis, representative, compare, acceptance_diagnostics, restriction_audit, and shock_ranking generic families

## Task Commits

Each task was committed atomically:

1. **Task 1: Create compare_* dispatch tests and zero-reference function tests** - `61d5dba` (feat)
2. **Task 2: Create PosteriorBSVARSIGN-specific dispatch tests** - `bae9ac8` (feat)

**Plan metadata:** (docs commit follows)

## Files Created/Modified
- `inst/tinytest/test_dispatch_compare.R` - 50 tests: S3 dispatch for all 9 testable compare_* functions with PosteriorBSVARSV
- `inst/tinytest/test_zero_coverage.R` - 19 tests: compare_forecast columns, most_likely_admissible_cdm (SIGN fixture + error path), apr_gen_mats requireNamespace gate
- `inst/tinytest/test_dispatch_sign.R` - 30 tests: PosteriorBSVARSIGN dispatch for tidy_irf/cdm/fevd, hypothesis_irf, representative_irf, compare_irf, compare_restrictions, acceptance_diagnostics, restriction_audit, shock_ranking

## Decisions Made
- shock_ranking uses time label strings (not integer horizons) as start/end args - discovered by checking the function signature in R/hd-event.R; must call tidy_hd() first to extract valid time labels
- compare_restrictions is PosteriorBSVARSIGN-specific (calls restriction_audit internally); not testable with generic PosteriorBSVAR without explicit restrictions list, so dispatched only in test_dispatch_sign.R
- most_likely_admissible_cdm and most_likely_admissible_irf select the same draw (kernel score maximizer), confirmed by testing draw_index equality
- APRScenario tests use requireNamespace gate at runtime so the test runs correctly in both package-present and package-absent environments

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None.

## User Setup Required
None - no external service configuration required.

## Self-Check: PASSED

All files exist and both task commits verified in git log.

## Next Phase Readiness
- compare_forecast, most_likely_admissible_cdm, and apr_gen_mats no longer have zero test references
- PosteriorBSVARSV dispatch confirmed for 9 compare_* functions
- PosteriorBSVARSIGN dispatch confirmed for 10 key functions
- Ready for Phase 5 Plan 03 or subsequent coverage expansion

---
*Phase: 05-test-coverage-expansion*
*Completed: 2026-03-12*
