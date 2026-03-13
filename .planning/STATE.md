# Project State

## Project Reference

See: .planning/PROJECT.md (updated 2026-03-11)

**Core value:** Every function produces correct, robust output that researchers can trust in publications — correct impulse responses, valid posterior probabilities, and reliable visualizations.
**Current focus:** Phase 7 in progress — Plan 04 complete (Hypothesis Testing vignette)

## Current Position

Phase: 7 of 8 (Vignettes & Multi-Platform) — IN PROGRESS
Plan: 05 (next)
Status: Plan 04 complete — Hypothesis Testing vignette created (216 lines, fiscal narrative, hypothesis_irf/joint/simultaneous/magnitude_audit); Plan 05 (WinBuilder/CRAN submission) next
Last activity: 2026-03-13 — Completed Plan 07-04: Hypothesis Testing vignette (posterior probability statements, joint hypotheses, simultaneous bands, magnitude auditing)

Progress: [████████░░] 75% (6 of 8 phases complete)

## Performance Metrics

**Velocity:**
- Total plans completed: 16
- Average duration: 4 minutes
- Total execution time: ~1.1 hours

**By Phase:**

| Phase | Plans | Duration | Avg/Plan |
|-------|-------|----------|----------|
| 01-ggplot2-deprecation-fix | 1 | 9 min | 9 min |
| 02-input-validation-foundation | 3 | 6 min | 2 min |
| 03-output-correctness-verification | 4 | 11 min | 3 min |
| 04-documentation-completion | 5 | 28 min | 6 min |
| 05-test-coverage-expansion | 1 | 2 min | 2 min |

**Recent Trend:**
- Last 5 plans: 3 min average

| Plan | Duration | Tasks | Files |
|------|----------|-------|-------|
| Phase 05 P01 | 2 min | 2 tasks | 2 files |
| Phase 04 P05 | 17 min | 1 task | 67 files |
| Phase 03 P04 | 2 min | 1 task | 1 file |
| Phase 03 P02 | 3 min | 2 tasks | 2 files |
| Phase 03 P01 | 3 min | 2 tasks | 2 files |
| Phase 03 P03 | 5 min | 2 tasks | 2 files |
| Phase 05-test-coverage-expansion P02 | 15 | 2 tasks | 3 files |
| Phase 05 P03 | 3 | 2 tasks | 3 files |
| Phase 05 P04 | 4 | 2 tasks | 4 files |
| Phase 05 P05 | 15 | 1 tasks | 1 files |
| Phase 05-test-coverage-expansion P06 | 3 | 1 tasks | 1 files |
| Phase 05-test-coverage-expansion P07 | 4 | 1 tasks | 1 files |
| Phase 06-api-consistency P01 | 3 min | 3 tasks | 3 files |
| Phase 06-api-consistency P02 | 11 min | 2 tasks | 13 files |
| Phase 06-api-consistency P03 | 12 min | 2 tasks | 37 files |
| Phase 07-vignettes-multi-platform P01 | 2 | 2 tasks | 11 files |
| Phase 07 P02 | 2 | 1 tasks | 1 files |
| Phase 07-vignettes-multi-platform P03 | 4 | 1 tasks | 1 files |
| Phase 07-vignettes-multi-platform P04 | 5 | 1 tasks | 1 files |

## Accumulated Context

### Decisions

Decisions are logged in PROJECT.md Key Decisions table.
Recent decisions affecting current work:

- tinytest over testthat: Lightweight framework fits CRAN philosophy (Status: Good)
- S3 over S4/R6: Consistent with bsvars ecosystem (Status: Good)
- Fix aes_string() before submission: Avoid CRAN NOTE, future-proof (Status: Pending)
- Version 1.0.0 for CRAN: Signals stable API (Status: Pending)
- [Phase 01-ggplot2-deprecation-fix]: Modern ggplot2 syntax verified: zero deprecated functions, .data[[var]] tidy-eval in use
- [Phase 01-ggplot2-deprecation-fix]: R CMD check warnings fixed: documentation mismatch and missing imports resolved
- [Phase 02-input-validation-foundation]: Validation helpers are internal (not exported) - prevents API surface bloat
- [Phase 02-input-validation-foundation]: validate_horizon returns as.integer() for type safety downstream
- [Phase 02-input-validation-foundation]: .default methods list both expected and received class for debugging clarity
- [Phase 02-input-validation-foundation]: NAMESPACE regeneration deferred to Plan 02-03 combined step
- [Phase 04-documentation-completion]: @return placed on generics only, never on @rdname S3 methods
- [Phase 04-documentation-completion]: Standard fixture: S=5 draws, horizon=3, us_fiscal_lsuw dataset (~2ms)
- [Phase 04-documentation-completion]: bsvarSIGNs fixture uses suppressMessages() + \donttest{} wrapper
- [Phase 04-documentation-completion]: Optional-package examples (gt, flextable, tsibble, APRScenario) use \dontrun{}
- [Phase 04-documentation-completion]: Plot examples assign to variable (p <- ...) to avoid device opening during R CMD check
- [Phase 04-02]: @return descriptions match actual column names from implementation
- [Phase 04-02]: acceptance_diagnostics uses bsvarSIGNs optimism fixture with suppressMessages()
- [Phase 04-documentation-completion]: Standard two-model fixture pattern for compare_* functions
- [Phase 04-01]: Documented actual shock_ranking return columns (ranking, rank_score, rank) rather than plan's incorrect specification
- [Phase 04-01]: Plan listed 7 tidy_* generics but R/tidy.R contains 6 - documented all 6 existing functions
- [Phase 04-04]: Reporting family uses shared Rd page pattern - single comprehensive @return and @examples on NULL anchor block
- [Phase 04-04]: write_bsvar_csv example uses tempfile() and unlink() pattern for safe demonstration
- [Phase 04-05]: autoplot() in @examples must use ggplot2::autoplot() namespace prefix (ggplot2 is Imports, not Depends)
- [Phase 04-05]: bsvarSIGNs sign_irf must be NxN matrix (not NxH); dimension mismatch causes verify_traditional() error
- [Phase 04-05]: HD event window start/end use character time labels from tidy_hd output, not integer indices
- [Phase 04-05]: magnitude_audit requires explicit variable and shock arguments (no defaults)
- [Phase 03-04]: S=30 draws with seeds 2026/2027 for compare verification fixtures
- [Phase 03-04]: Compare verification tests all summary columns (median, mean, lower, upper) not just one statistic
- [Phase 03-01]: FEVD row sums verified at 100 (not 1.0) because bsvars reports FEVD as percentages on 0-100 scale
- [Phase 03-01]: Credible interval verification uses diagonal variable/shock pairs at horizons 0, 4, 8 (9 cells per function)
- [Phase 03-02]: S=30 draws sufficient for verification of mathematical correctness at 1e-10 tolerance
- [Phase 03-02]: Horizon off-by-one explicitly tested: horizon 2 maps to array index 3 (horizon 0 = index 1)
- [Phase 03-02]: half_life and time_to_threshold NA handling verified via reached_prob + conditional stat checks
- [Phase 03-03]: IRF arrays from compute_impulse_responses have no dimnames; use infer_model_variable_names() for index resolution
- [Phase 03-03]: Representative draw L2 distance uses draw_matrix() flattening: matrix(as.numeric(draws), nrow=prod(d[1:3]), ncol=d[4])
- [Phase 05-01]: PosteriorBSVARSV dispatch tests use S=5 draws, p=1, us_fiscal_lsuw - consistent with project-wide test fixture pattern
- [Phase 05-01]: Dispatch tests verify structural return shape (class, nrow, columns) not numerical values - Phase 3 already verified correctness for PosteriorBSVAR
- [Phase 05-01]: Variable name assertions use rownames(post_sv$last_draw$data_matrices$Y) as expected_names source
- [Phase 05-02]: shock_ranking uses time label strings (not integer horizons) as start/end args - requires tidy_hd() to extract valid time strings
- [Phase 05-02]: compare_restrictions is PosteriorBSVARSIGN-specific - tested only in test_dispatch_sign.R with SIGN fixture
- [Phase 05-02]: most_likely_admissible_cdm and most_likely_admissible_irf select the same draw_index (kernel score maximizer)
- [Phase 05]: PosteriorBSVARSV fixture: specify_bsvar_sv$new with set.seed(1), S=5, thin=1, horizon=2 — consistent with Phase 3 lightweight fixture pattern
- [Phase 05]: Dispatch coverage: test_dispatch_representative and test_dispatch_response_summary use PosteriorBSVARSV plus PosteriorIR/PosteriorCDM intermediates
- [Phase 05-04]: Optional package tests use exit_file() at file top -- correct tinytest idiom for file-level conditional execution under _R_CHECK_FORCE_SUGGESTS_=false
- [Phase 05-04]: Integration tests check class/structure at each pipeline stage (not numerical values) -- integration coverage, not replication of Phase 3 correctness verification
- [Phase 05-04]: test_reporting.R already covers as_gt/as_flextable on bsvar_post_tbl; optional smoke tests focus on report_bundle and data.frame dispatch paths to avoid duplication
- [Phase 05-05]: Coverage gate passed at 86.9% (threshold 80%) -- no additional gap-filling tests required
- [Phase 05-05]: openssl R package required patched Makevars.in on macOS arm64 to link bcrypt .o files directly (flat namespace issue with static archive)
- [Phase 05-06]: MIX/MSH/T posterior types are code-path aliases; structural spot-check dispatch assertions sufficient for dispatch coverage (Phase 3 verified numerical correctness)
- [Phase 05-06]: representative_irf returns RepresentativeIR list (draw_index as slot) not bsvar_post_tbl -- assertions follow actual behavior from test_dispatch_representative.R
- [Phase 05-07]: bsvars requires 2+ variables; 1-variable model not valid — used minimal 2-variable model for edge case testing
- [Phase 05-07]: bsvars::estimate requires S >= 2; used S=2 as minimum-draw boundary test instead of plan's S=1
- [Phase 05-07]: resolve_selection with character(0) returns integer(0) silently — documented as acceptable behavior
- [Phase 06-01]: resolve_horizon(NULL) returns 20L — business-cycle convention covering full dynamics
- [Phase 06-01]: deprecate_arg() gives new_val precedence when both old and new args are provided
- [Phase 06-01]: compare_acceptance_diagnostics excluded from validate_model_compatibility — output has no variable column
- [Phase 06-01]: Dimension assertions use class reporting for non-array inputs, dimension count for wrong-dimension arrays
- [Phase 06-02]: All probability defaults changed from 0.68 to 0.90 across 13 R source files
- [Phase 06-02]: All horizon defaults changed from 10 to NULL with resolve_horizon() wrapper in model-dispatch functions
- [Phase 06-02]: hypothesis_irf/hypothesis_cdm: variables/shocks added as new params, horizon remains required (constraint specifier not selection param)
- [Phase 06-02]: Internal summarise_*_draws helpers renamed to plural without deprecation shim (internal functions)
- [Phase 06-03]: new_bsvar_post_tbl() column validation requires only 'model' column — object_type is stored as attribute, not column, in restriction_audit, joint-inference, hd-event, diagnostics callers
- [Phase 06-03]: test_api_consistency.R tests 28 assertions across deprecate_arg, resolve_horizon, dimension guards, column validation, validate_model_compatibility, return types, and deprecation warnings
- [Phase 06-03]: Infrastructure R CMD check warnings (vignette compilation, .git, ..Rcheck) are pre-existing worktree issues, not Phase 6 regressions
- [Phase 07-vignettes-multi-platform]: Fixture seeds 123/456 for primary/alternative posteriors; S=200 for vignette fixtures
- [Phase 07-vignettes-multi-platform]: CI R-devel on ubuntu only per r-lib/actions community standard; Windows/R-devel via WinBuilder in Plan 05
- [Phase 07-vignettes-multi-platform]: setup-pandoc placed before setup-r in CI — required for vignette Rmd rendering on Windows/macOS
- [Phase 07-vignettes-multi-platform]: Getting Started vignette: 200-line narrative scope (extraction, comparison, plotting) replaces 600-line reference catalog
- [Phase 07-vignettes-multi-platform]: Variable indices for fiscal narrative: variables=3 (gdp), shocks=2 (gs) for government spending -> GDP analysis
- [Phase 07-vignettes-multi-platform]: HD event window uses decimal quarterly strings ('1948.25' to '1948.75') not integer indices — actual string labels from bsvars HD output
- [Phase 07-vignettes-multi-platform]: joint_hypothesis_irf and magnitude_audit use singular variable/shock params — no plural API variants exist for these functions

### Pending Todos

None yet.

### Blockers/Concerns

**Critical:**
- ~~R1 (aes_string deprecation): Blocks R CMD check passing; must be fixed in Phase 1 before any other work~~ **RESOLVED** - Verified modern syntax in use, zero deprecated functions

**Foundation:**
- Native symbol bridge to bsvarSIGNs (R/v2-utils.R): Technical debt for post-v1.0 follow-up; acceptable for v1.0 but fragile

**Quality:**
- ~~Test coverage gaps: Hypothesis engine edge cases, representative draw selection, restriction auditing (addressed in Phase 5)~~ **RESOLVED** - Phase 5 complete: 86.9% line coverage, all 66 exports covered, 875 tests pass
- ~~Documentation gaps: S3 method argument mismatches noted in DEVELOPMENT.md (addressed in Phase 4)~~ **RESOLVED** - Phase 4 complete (5 plans), R CMD check clean

## Session Continuity

Last session: 2026-03-13
Stopped at: Completed 07-04-PLAN.md (Hypothesis Testing vignette)
Resume file: .planning/phases/07-vignettes-multi-platform/07-04-SUMMARY.md
