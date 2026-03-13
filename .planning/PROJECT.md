# bsvarPost

## What This Is

An R package providing post-estimation tools for Bayesian Structural Vector Autoregressions fitted with the `bsvars` and `bsvarSIGNs` packages. It adds cumulative dynamic multipliers, tidy extraction helpers, model comparison utilities, hypothesis testing, and a ggplot2 plotting layer on top of existing posterior objects. Aimed at applied macroeconometricians and researchers who need publication-ready analysis workflows.

## Core Value

Every function produces correct, robust output that researchers can trust in publications — correct impulse responses, valid posterior probabilities, and reliable visualizations.

## Requirements

### Validated

<!-- Shipped and confirmed valuable. Inferred from existing codebase. -->

- ✓ Cumulative dynamic multiplier computation (`cdm()`) — existing
- ✓ Tidy extraction for IRFs, CDMs, FEVDs, forecasts, HDs, structural shocks — existing
- ✓ Multi-model comparison functions (`compare_*()`) — existing
- ✓ Hypothesis testing on IRFs and CDMs with posterior probabilities — existing
- ✓ Joint hypothesis testing — existing
- ✓ Representative draw selection (median-target, most-likely-admissible) — existing
- ✓ Restriction auditing and shock ranking — existing
- ✓ Acceptance diagnostics for sign-restricted models — existing
- ✓ Response summaries (peak, duration, half-life, timing) — existing
- ✓ ggplot2 autoplot integration and specialized plotting functions — existing
- ✓ Publication-ready plot styling (`theme_bsvarpost()`, `style_bsvar_plot()`) — existing
- ✓ Reporting layer (kable, gt, flextable export) — existing
- ✓ tsibble and APRScenario bridge functions — existing
- ✓ S3 dispatch across all bsvars/bsvarSIGNs posterior types — existing
- ✓ R CMD check --as-cran passes clean — existing
- ✓ CI/CD with GitHub Actions — existing

### Active

<!-- Current scope. Building toward v1.0.0 CRAN submission. -->

- [ ] All exported functions hardened against edge case inputs (1 variable, 1 shock, extreme horizons, empty selections)
- [ ] Output correctness verified for all computational functions (IRFs, CDMs, hypothesis probabilities, summaries)
- [ ] Informative error messages on all invalid inputs (bad types, out-of-range indices, missing arguments)
- [ ] Consistent API across similar functions (argument names, return types, defaults)
- [ ] Replace deprecated `aes_string()` with tidy-eval `aes()` in all plotting code
- [ ] Expanded test coverage for all modules, including edge cases
- [ ] Vignettes polished and complete
- [ ] Remaining roxygen documentation gaps filled (examples, @return, @param for all exports)
- [ ] Version bumped to 1.0.0
- [ ] CRAN submission package prepared and submitted

### Out of Scope

- Mobile or web interface — this is a pure R package
- Real-time or streaming computation — batch posterior analysis only
- New estimation methods — estimation lives in upstream bsvars/bsvarSIGNs
- OAuth, authentication, or external API integrations — pure computation package
- C++ code in this package — computation delegated to upstream packages

## Context

- `bsvarPost` extends two established R packages: `bsvars` (Bayesian SVARs) and `bsvarSIGNs` (sign-restricted BSVARs)
- The package is at v0.2.0 with 27 R source files, 24 test files, and 63 man pages
- Architecture follows S3 method dispatch with a layered pipeline: posterior objects → computation → tidy extraction → comparison/summary → plotting/reporting
- The `bsvar_post_tbl` tibble subclass is the standard output container
- Current codebase map is available in `.planning/codebase/` with detailed analysis
- Key concern areas from codebase audit: native symbol bridge to bsvarSIGNs, deprecated aes_string(), test coverage gaps in hypothesis engine and representative draw selection

## Constraints

- **Tech stack**: Pure R package — no compiled code in this package; C++ lives upstream
- **Upstream dependency**: Must work with current bsvars and bsvarSIGNs versions; no control over their API
- **CRAN policy**: Must pass R CMD check --as-cran with zero errors, zero warnings, ideally zero notes
- **Documentation**: All exported functions must have complete roxygen docs with runnable examples
- **Testing**: tinytest framework (not testthat) — tests in `inst/tinytest/`
- **Compatibility**: R >= 4.1.0

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| tinytest over testthat | Lightweight, no dependencies, fits CRAN philosophy | — Pending |
| S3 over S4/R6 | Consistent with bsvars/bsvarSIGNs ecosystem, simpler dispatch | ✓ Good |
| tibble subclass (bsvar_post_tbl) as standard output | Tidy data principles, ggplot2 integration, user familiarity | ✓ Good |
| Version 1.0.0 for CRAN | Signals stable API, first public release | — Pending |
| Fix aes_string() before submission | Avoids CRAN NOTE about deprecated functions, future-proofs | — Pending |

---
*Last updated: 2026-03-11 after initialization*
