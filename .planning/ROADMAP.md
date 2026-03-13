# Roadmap: bsvarPost v1.0.0 CRAN Submission

## Overview

Transform bsvarPost from feature-complete v0.2.0 to CRAN-ready v1.0.0 through systematic hardening, documentation completion, and validation. The journey begins with critical blockers (deprecated ggplot2 functions), builds a foundation of input validation and correctness verification, completes documentation and testing, hardens the user experience with consistent error messages, polishes vignettes and multi-platform support, and culminates in comprehensive CRAN submission validation. Every phase delivers verifiable improvements that bring the package closer to publication-ready quality.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: ggplot2 Deprecation Fix** - Replace all aes_string() with tidy-eval syntax (completed 2026-03-11)
- [x] **Phase 2: Input Validation Foundation** - Add validation helpers and default S3 methods (completed 2026-03-12)
- [x] **Phase 3: Output Correctness Verification** - Verify computational correctness with tight tolerances (completed 2026-03-12)
- [x] **Phase 4: Documentation Completion** - Complete roxygen docs with runnable examples (completed 2026-03-12)
- [x] **Phase 5: Test Coverage Expansion** - Expand tinytest suite to 80%+ coverage (completed 2026-03-12)
- [x] **Phase 6: API Consistency & Error Messages** - Standardize errors and API across function families (completed 2026-03-13)
- [ ] **Phase 7: Vignettes & Multi-Platform** - Polish vignettes and validate across platforms
- [ ] **Phase 8: CRAN Submission** - Final validation and package submission

## Phase Details

### Phase 1: ggplot2 Deprecation Fix
**Goal**: Eliminate all deprecated ggplot2 functions to pass R CMD check without warnings
**Depends on**: Nothing (first phase)
**Requirements**: R1
**Success Criteria** (what must be TRUE):
  1. Zero aes_string() calls exist in the codebase
  2. All plotting functions render identical output before and after migration
  3. R CMD check produces no deprecation warnings for ggplot2 functions
  4. All autoplot methods and specialized plot functions execute without errors
**Plans**: 1 plan

Plans:
- [x] 01-01-PLAN.md — Verify modern ggplot2 tidy-eval patterns and R CMD check passes

### Phase 2: Input Validation Foundation
**Goal**: Establish robust input validation infrastructure preventing bad data propagation
**Depends on**: Phase 1
**Requirements**: R2
**Success Criteria** (what must be TRUE):
  1. validate_posterior_object() helper exists and validates all 6 posterior types
  2. validate_horizon() and validate_probability() helpers exist with informative errors
  3. All S3 generics have .default methods that produce clear error messages
  4. Edge cases (1 variable, 1 shock, horizon=0, empty selections) produce informative errors
  5. Wrong input types (data.frame where posterior expected) fail with actionable messages
**Plans**: 3 plans

Plans:
- [x] 02-01-PLAN.md — Create validation helpers and add .default methods to tidy_* generics
- [x] 02-02-PLAN.md — Add .default methods to remaining S3 generics (hypothesis, representative, response summary, cdm, joint inference)
- [x] 02-03-PLAN.md — Create comprehensive test suite for validation and edge cases

### Phase 3: Output Correctness Verification
**Goal**: Verify computational accuracy of all core functions with manual cross-checks
**Depends on**: Phase 1
**Requirements**: R3
**Success Criteria** (what must be TRUE):
  1. cdm() cumulative sums verified against manual computation with tight tolerance
  2. tidy_irf/tidy_cdm/tidy_fevd credible intervals match manual quantile computation
  3. hypothesis_irf/hypothesis_cdm posterior probabilities match manual draw counting
  4. Response summaries (peak, duration, half_life) match manual extraction
  5. restriction_audit() probabilities verified against manual restriction checking
  6. Representative draw selection produces draws satisfying stated criteria
**Plans**: 4 plans

Plans:
- [x] 03-01-PLAN.md — Verify CDM cumulative sums and tidy_* credible intervals
- [x] 03-02-PLAN.md — Verify hypothesis posterior probabilities and response summaries
- [x] 03-03-PLAN.md — Verify restriction audit probabilities and representative draw selection
- [x] 03-04-PLAN.md — Verify compare_* merging logic correctness

### Phase 4: Documentation Completion
**Goal**: Complete roxygen documentation for all exports with fast, runnable examples
**Depends on**: Phase 2 (needs validation helpers for examples)
**Requirements**: R5
**Success Criteria** (what must be TRUE):
  1. All 60+ exported functions have complete @title, @description, @param, @return
  2. All exported functions have runnable @examples executing in under 5 seconds total
  3. S3 method @rdname alignment fixed for all documented problem functions
  4. Small fixture posterior objects (S=5-10) available for fast examples
  5. R CMD check reports zero documentation warnings
  6. All examples execute successfully without errors
**Plans**: 5 plans

Plans:
- [x] 04-01-PLAN.md — Add @return and @examples to tidy_* and cdm extraction functions (10 Rd pages)
- [x] 04-02-PLAN.md — Add @return and @examples to hypothesis, joint-inference, representative, response-summary, and diagnostics (13 Rd pages)
- [x] 04-03-PLAN.md — Add @return and @examples to compare, audit, APRScenario, and tsibble functions (20 Rd pages)
- [x] 04-04-PLAN.md — Add @return and @examples to plot, style, and reporting functions (15 Rd pages)
- [x] 04-05-PLAN.md — Regenerate NAMESPACE/Rd files, run R CMD check, verify all examples

### Phase 5: Test Coverage Expansion
**Goal**: Achieve 80%+ test coverage with comprehensive edge case and dispatch testing
**Depends on**: Phase 2 (validation infrastructure), Phase 3 (correctness baseline)
**Requirements**: R6
**Success Criteria** (what must be TRUE):
  1. Every exported function has at least one dedicated test
  2. S3 dispatch tested for all 6 posterior types across core generics (tidy_*, compare_*, hypothesis_*, representative_*)
  3. Edge cases tested (1 variable, 1 shock, horizon=0, empty selections, single draw)
  4. All conditional dependency branches tested with suggested packages both present and absent
  5. Integration pipelines tested end-to-end (posterior -> tidy -> compare -> plot)
  6. All tests pass with _R_CHECK_FORCE_SUGGESTS_=false
  7. Error validation tests confirm expected error messages from Phase 2
**Plans**: 7 plans

Plans:
- [x] 05-01-PLAN.md — S3 dispatch tests for tidy and hypothesis families (PosteriorBSVARSV)
- [x] 05-02-PLAN.md — Compare dispatch, zero-reference functions, and PosteriorBSVARSIGN dispatch
- [x] 05-03-PLAN.md — Representative and response-summary dispatch plus utils/plot-style coverage
- [x] 05-04-PLAN.md — Optional package smoke tests and integration pipeline tests
- [x] 05-05-PLAN.md — covr verification gate, gap filling, FORCE_SUGGESTS validation
- [x] 05-06-PLAN.md — Gap closure: MIX/MSH/T posterior type dispatch spot-checks
- [x] 05-07-PLAN.md — Gap closure: Behavioral edge cases (1-variable, S=1, empty selections)

### Phase 6: API Consistency & Error Messages
**Goal**: Standardize error messages and API design across all function families
**Depends on**: Phase 2 (validation foundation)
**Requirements**: R4
**Success Criteria** (what must be TRUE):
  1. All error messages follow consistent format (what/why/how-to-fix)
  2. Parameter names consistent across tidy_*, compare_*, hypothesis_* function families
  3. Return types documented and consistent within function families
  4. Default values consistent for shared parameters (probability, horizon, draws)
  5. Dimension assertions present in set_*_dimnames() functions
  6. Tibble structure validation present in new_bsvar_post_tbl()
  7. Model compatibility checks present in compare_*() functions
**Plans**: 3 plans

Plans:
- [x] 06-01-PLAN.md — Add validation helpers, structural validators, and update compare.R defaults
- [x] 06-02-PLAN.md — Update defaults in remaining R files and add singular->plural deprecation shims
- [x] 06-03-PLAN.md — Update tests for new defaults, create API consistency tests, R CMD check

### Phase 7: Vignettes & Multi-Platform
**Goal**: Polish vignettes to CRAN quality and validate across all target platforms
**Depends on**: Phase 4 (complete documentation), Phase 5 (tested functionality)
**Requirements**: R7, R9
**Success Criteria** (what must be TRUE):
  1. All vignettes build without errors in under 5 minutes total
  2. Vignettes render correctly without suggested packages installed
  3. Suggested package usage guarded with requireNamespace() in all vignettes
  4. Vignettes cover core workflows (extraction, comparison, hypothesis testing, plotting)
  5. CI matrix passes on 5 OS/R combinations following r-lib/actions community standard (macos/release, windows/release, ubuntu/devel, ubuntu/release, ubuntu/oldrel-1); R-devel runs on ubuntu in CI
  6. devtools::check_win_devel() submitted to WinBuilder for windows/R-devel validation (results arrive by email)
  7. Zero errors, zero warnings, minimal notes across all CI + WinBuilder checks
**Plans**: 5 plans

Plans:
- [ ] 07-01-PLAN.md — Generate .rds fixtures, regenerate figures, expand CI to 5-platform matrix
- [ ] 07-02-PLAN.md — Rewrite Getting Started vignette with fiscal policy narrative
- [ ] 07-03-PLAN.md — Rewrite Post-Estimation Workflows vignette with fiscal narrative
- [ ] 07-04-PLAN.md — Create Hypothesis Testing vignette
- [ ] 07-05-PLAN.md — R CMD check validation, vignette build verification, and WinBuilder submission

### Phase 8: CRAN Submission
**Goal**: Complete final validation and submit package to CRAN
**Depends on**: Phase 7 (multi-platform validation complete)
**Requirements**: R8, R10
**Success Criteria** (what must be TRUE):
  1. NEWS.md exists with complete v1.0.0 changelog
  2. cran-comments.md documents platform check results
  3. inst/WORDLIST covers all domain-specific terms (BSVAR, VAR, Bayesian, posterior, MCMC, Cholesky)
  4. DESCRIPTION version is 1.0.0 with proper formatting
  5. goodpractice::gp() reports no critical issues
  6. spelling::spell_check_package() passes cleanly
  7. All documentation URLs validated and accessible
  8. Final R CMD check --as-cran produces 0 errors, 0 warnings, 0 notes
  9. Package tarball submitted to CRAN via devtools::release()
**Plans**: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4 -> 5 -> 6 -> 7 -> 8

**Dependencies:**
- Phase 1 blocks all others (must pass R CMD check)
- Phase 2 foundation enables Phase 4 (examples need validation) and Phase 6 (error standardization)
- Phase 3 can run parallel to Phase 2-4 (independent correctness verification)
- Phase 5 requires Phase 2 (validation) and Phase 3 (correctness baseline)
- Phase 6 builds on Phase 2 (validation helpers)
- Phase 7 requires Phase 4 (docs) and Phase 5 (tested functionality)
- Phase 8 requires Phase 7 (all prior work complete)

**Parallel opportunities:**
- Phase 2 and Phase 3 can run concurrently after Phase 1
- Phase 4 can begin after Phase 2 foundation is ready
- Phase 6 work can overlap with Phase 5 testing

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. ggplot2 Deprecation Fix | 1/1 | Complete    | 2026-03-11 |
| 2. Input Validation Foundation | 3/3 | Complete    | 2026-03-12 |
| 3. Output Correctness Verification | 4/4 | Complete | 2026-03-12 |
| 4. Documentation Completion | 5/5 | Complete | 2026-03-12 |
| 5. Test Coverage Expansion | 7/7 | Complete | 2026-03-12 |
| 6. API Consistency & Error Messages | 3/3 | Complete | 2026-03-13 |
| 7. Vignettes & Multi-Platform | 0/5 | Not started | - |
| 8. CRAN Submission | 0/TBD | Not started | - |
