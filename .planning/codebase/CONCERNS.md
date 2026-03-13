# Codebase Concerns

**Analysis Date:** 2026-03-11

## Tech Debt

**Native Symbol Bridge to bsvarSIGNs:**
- Issue: Post-estimation layer couples directly to unexposed native internals from `bsvarSIGNs` package
- Files: `R/v2-utils.R`
- Impact: Representative-model scoring for `most_likely_admissible_*()`, narrative restriction auditing, and zero-restriction weighting rely on direct native symbol resolution via `getNativeSymbolInfo()`. If upstream package changes native interface, these functions silently break or error unpredictably.
- Current mitigation: Runtime symbol caching and resolution with fallback error handling
- Fix approach:
  1. Advocate for stable R-level API in `bsvarSIGNs` for these internals
  2. Provide clear error messages when native symbols cannot be resolved
  3. Add version-compatibility checks for known interface changes
  4. Alternatively, reimplement these core algorithms in R if stability is critical

**Deprecated ggplot2 aes_string() Usage:**
- Issue: Plotting layer uses `aes_string()` which is deprecated in ggplot2
- Files: Plotting-related functions in `R/` (specific files not yet audited for all occurrences)
- Impact: Future ggplot2 versions will remove this function; code will fail with breaking changes
- Fix approach: Replace `aes_string()` with tidy-eval `aes()` calls; audit all plotting files systematically

**Limited Test Coverage:**
- Issue: Test suite is sparse and minimal
- Files: `inst/tinytest/` contains only ~5 test files; `tests/tinytest.R` delegates to package test system
- Impact: Changes to core computation or edge cases may not be caught before release
- Coverage gaps: Most response-summary functions, hypothesis engine internals, representative-draw selection, restriction auditing logic
- Fix approach: Expand tinytest suite with unit tests for:
  1. Edge cases in `response_max_horizon()` and `response_fetch_horizon()`
  2. Representative-draw selection with empty subsets
  3. Hypothesis predicate evaluation for boundary conditions
  4. Restriction auditing with malformed inputs

## Known Bugs

**Potential Edge Case in Zero Restriction Validation:**
- Symptoms: Code path suggests zeros may not be handled uniformly across restriction types
- Files: `R/v2-utils.R` (lines 161-167)
- Trigger: Using zero restrictions at horizons >= 1 in narrative-style settings
- Workaround: Specify zero restrictions only at horizon 0; avoid narrative restrictions with impact-zero constraints
- Recommended: Add explicit validation test case

**Inconsistent Dimension Handling in Representative Draw Selection:**
- Issue: `set_response_dimnames()` in `R/utils.R` makes assumptions about shock naming from variable names
- Files: `R/utils.R` (lines 64-79)
- Problem: When number of shocks differs from number of variables (common in larger systems), shock dimnames fallback to `paste0("shock", ...)` even when model has explicit shock labels
- Fix: Separate variable names from shock names; pass both independently through the call stack

## Security Considerations

**No detected security risks specific to package implementation.** Package operates on posterior objects from upstream estimation packages and does not:
- Accept user file paths or dynamic code evaluation
- Interface with external APIs or network services
- Use unsafe file operations or string concatenation for paths

Note: Upstream packages `bsvars` and `bsvarSIGNs` should be audited for credential/data handling.

## Performance Bottlenecks

**Inefficient Matrix Construction in Hypothesis Engine:**
- Problem: `draw_matrix()` in `R/v2-utils.R` reshapes 4D arrays to 2D by stacking all dimensions. For large posterior samples (e.g., S > 5000 draws, large system), this creates temporary matrices exceeding memory capacity
- Files: `R/v2-utils.R` (line 101)
- Cause: Full materialization of `prod(d[1:3]) x d[4]` matrix before statistical summary
- Improvement path:
  1. Compute quantiles/summaries on-the-fly without materializing full matrix
  2. Use row-by-row or chunk-based processing for large draws
  3. Provide `chunk_size` parameter for memory-constrained environments

**Repeated Array Subsetting in Selection Functions:**
- Problem: `subset_response_draws()` and related selection logic make multiple passes over draw arrays
- Files: `R/v2-utils.R` (lines 77-90)
- Cause: Separate indexing operations for variables, shocks, and horizons rather than combined mask
- Improvement: Pre-compute combined boolean mask; apply once

**Native Symbol Resolution Overhead:**
- Problem: `bsvarsigns_native()` caches but still incurs function-call overhead for every narrative auditing operation
- Files: `R/v2-utils.R` (lines 1-11)
- Cause: Wrapping pattern adds layers of indirection
- Improvement: Batch narrative audits into single native call if possible

## Fragile Areas

**Representative Draw Selection Logic:**
- Files: `R/representative.R`
- Why fragile:
  1. `most_likely_admissible` method is restricted to `PosteriorBSVARSIGN` only (enforced at line 44-45, 114-115)
  2. Selection method dispatches on object class; if upstream package changes class hierarchy, method resolution fails
  3. No fallback if `compute_representative_draw()` returns `NULL` or empty selection
  4. Distance metric and standardization combinations not validated for incompatibility
- Safe modification:
  1. Add explicit type coercion before method dispatch
  2. Add comprehensive input validation in `representative_irf_impl()` and `representative_cdm_impl()`
  3. Wrap native kernel scoring in try-catch to provide user-friendly error
- Test coverage gaps:
  1. No tests for `most_likely_admissible` with small posterior samples (e.g., S < 10)
  2. No tests for selection with all draws filtered out by variable/shock/horizon constraints

**Hypothesis Evaluation Predicate Engine:**
- Files: `R/hypothesis.R`, `R/v2-utils.R` (predicate evaluation)
- Why fragile:
  1. Complex predicate construction in `evaluate_draw_predicate()` (not shown) with many branching conditions
  2. Pairwise comparisons via `compare_to` parameter can create cross-dimensional dependencies
  3. Recycling logic in `append_hypothesis_rhs()` (lines 56-58) assumes lengths match in specific ways; can fail silently if edge cases bypass checks
- Safe modification:
  1. Validate all dimension reconciliation before computation
  2. Add explicit error messages for recycling failures
  3. Document comparison semantics clearly
- Test coverage gaps:
  1. Pairwise comparisons across different variable/shock/horizon sets
  2. Boundary horizons (e.g., horizon = 0, max horizon)
  3. NA handling in relate predicates (e.g., `relation = "=="` with draws containing NAs)

**Restriction Auditing Workflow:**
- Files: `R/audit.R`, `R/v2-utils.R`
- Why fragile:
  1. `extract_default_restrictions()` reconstructs restrictions from identification object; assumes structure matches known upstream format
  2. Three restriction types (IRF sign, structural, narrative) handled in sequence; missing branches for new types would silently drop them
  3. Narrative matrix construction uses magic numbers `c(S=1, A=2, B=3)` mapping to native type codes (line 62); if upstream changes type enum, breaks silently
- Safe modification:
  1. Add enum-like lookup mapping for narrative types
  2. Validate extracted restrictions match upstream semantics
  3. Provide diagnostics for dropped/unrecognized restrictions
- Test coverage gaps:
  1. Mixed restriction types (sign + structural + narrative) in single audit
  2. Malformed restriction specifications
  3. Edge case: single-period narratives

**S3 Method Dispatch with Documented Argument Issues:**
- Files: Multiple files (e.g., `R/response-summary.R`, `R/hypothesis.R`, `R/representative.R`)
- Issue: S3 roxygen documentation requires careful alignment across generic and methods. DEVELOPMENT.md notes this already affected multiple functions. Easy to regress.
- Safe modification: After any S3 method change, always rerun roxygen and inspect generated `\usage` sections in Rd files
- CI safeguard: GitHub Actions should validate Rd consistency

## Scaling Limits

**Posterior Sample Size Scaling:**
- Current capacity: Tested with S ~ 100-500 draws; likely functional to S ~ 5000
- Limit: Breaks when `prod(dim[1:3]) x S` matrix in hypothesis engine exceeds available RAM (typically ~1-2 GB for standard systems)
- Scaling path:
  1. Implement chunked quantile computation
  2. Add `summarize_on_the_fly()` for memory-constrained backends
  3. Provide streaming API for large-S workflows

**Model Dimension Scaling (Variables x Shocks x Horizons):**
- Current capacity: Typical 5 variables x 5 shocks x 12-60 horizons
- Limit: Dimname inference and subsetting become inefficient beyond ~20 variables or ~100 horizons
- Scaling path:
  1. Use sparse index representation for large systems
  2. Lazy-load dimname mappings
  3. Provide selector DSL for complex variable/shock/horizon filters

## Dependencies at Risk

**Upstream API Stability - bsvars and bsvarSIGNs:**
- Risk: Package depends on class inheritance, object structure, and native symbols from upstream packages that are not contractually versioned
- Impact: Class changes (e.g., `PosteriorBSVAR` hierarchy), object field renames, or native interface changes will break silently or with cryptic errors
- Current state: No version constraints beyond `bsvars` and `bsvarSIGNs` in DESCRIPTION; relies on GitHub dev versions
- Migration plan:
  1. Add explicit version constraints once upstream reaches stability (v1.0+)
  2. Implement wrapper functions that adapt to upstream version differences
  3. Add CI matrix testing against multiple upstream versions

**ggplot2 API Deprecation:**
- Risk: `aes_string()` and other deprecated functions will be removed in future ggplot2 versions (likely 4.0+)
- Impact: Plotting functions will error on new ggplot2
- Fix: Replace `aes_string()` with tidy-eval `aes()` in all plotting layers

**Suggested Packages Conditional Logic:**
- Risk: Optional packages like `tsibble`, `APRScenario`, `flextable`, `gt` may change APIs or become unmaintained
- Impact: Bridge functions (e.g., `as_tsibble_post()`, `as_apr_cond_forc()`) require defensive coding
- Current mitigation: DEVELOPMENT.md notes conditional tests (requireNamespace checks)
- Fix: Maintain adapter layer; version-gate breaking changes

## Missing Critical Features

**API Stability for v1.0 Release:**
- Blocks: CRAN submission without clear API guarantees
- Problem: Package is currently at v0.2.0; feature additions continue and breaking changes are possible
- Needed: Freeze core API (`cdm()`, `tidy_*()`, `hypothesis_*()`, `representative_*()`, `restriction_audit()`, main plotting functions) and document stability tier

**Comprehensive Documentation for Non-Obvious Semantics:**
- Problem: Several parameters and features have subtle interpretation requirements:
  1. `scale_by = "shock_sd"` scaling semantics not fully documented in docstrings
  2. `median_target_*()` vs `most_likely_admissible_*()` differences unclear
  3. `reach_prob` in timing summaries needs interpretation guide
  4. Restriction audit posterior probability interpretation when restrictions are violated across multiple dimensions
- Blocks: Users may misinterpret results
- Fix: Expand vignettes with worked examples for each ambiguous feature

## Test Coverage Gaps

**Hypothesis Engine Edge Cases:**
- What's not tested: Boundary conditions in `hypothesis_irf()` and `hypothesis_cdm()`
  - Empty horizon ranges
  - Singular variable/shock selections
  - Pairwise comparisons with unequal vector lengths
  - Comparison operators with NA-containing responses
- Files: `R/hypothesis.R`, `R/v2-utils.R`
- Risk: Silently incorrect posterior probability statements or unhandled errors
- Priority: High - hypothesis engine is user-facing API for core inference

**Representative Draw Selection with Constrained Posteriors:**
- What's not tested: `most_likely_admissible()` behavior with highly restrictive admissibility constraints
  - When very few draws satisfy constraints
  - When selected draw has extreme scores
  - Comparison of selection methods on same posterior
- Files: `R/representative.R`
- Risk: Misleading representative draws or crashes when admissible set is small
- Priority: High - representative draws are publication-facing

**Restriction Auditing Across Restriction Types:**
- What's not tested: Mixed restriction scenarios
  - IRF sign + structural sign in same audit
  - Narrative restrictions conflicting with sign restrictions
  - Zero restrictions at multiple horizons
- Files: `R/audit.R`, `R/v2-utils.R`
- Risk: Inconsistent posterior probability accounting or missed restrictions
- Priority: Medium - audit workflows currently focus on single restriction type

**Tidy Table Conversions with Large Posteriors:**
- What's not tested: `tidy_irf()`, `tidy_cdm()`, etc. with S > 1000 draws
  - Memory efficiency
  - Performance degradation
  - Correct quantile computation at extreme S values
- Files: `R/tidy.R`
- Risk: Slow or OOM failures on large posteriors
- Priority: Low-Medium - affects advanced users only

**Scaling and Plotting Edge Cases:**
- What's not tested: Plot generation with extreme parameter combinations
  - Very long horizons (>100)
  - Single-element selections (1 variable, 1 shock)
  - NA-heavy results from hypothetical comparisons
- Files: Plotting functions across `R/plot-*.R`
- Risk: Rendering errors or unreadable plots
- Priority: Low - edge cases unlikely in typical applied workflows

---

*Concerns audit: 2026-03-11*
