# Phase 3: Output Correctness Verification - Research

**Researched:** 2026-03-12
**Domain:** R package numerical verification testing (bsvarPost tinytest suite)
**Confidence:** HIGH

<user_constraints>

## User Constraints (from CONTEXT.md)

### Locked Decisions

#### Tolerance strategy
- Uniform tight tolerance of 1e-8 to 1e-10 for all numerical comparisons
- Applies to floating-point values (IRF magnitudes, CDM cumulative sums, quantile-based credible interval bounds)
- Applies to posterior probabilities (count-based ratios) -- tight tolerance even though these could in principle match exactly
- Applies to response summary results uniformly -- both integer-valued results (horizon indices, durations) and floating-point magnitudes use the same tight tolerance
- No looser tolerance tiers -- one standard across all function families

#### Verification scope
- All 6 function families listed in success criteria get full manual cross-check tests: cdm(), tidy_* credible intervals, hypothesis probabilities, response summaries, restriction_audit, representative draws
- compare_* functions also get their own correctness verification -- verify merging/differencing logic, not just the underlying tidy_* inputs
- 1-2 posterior types sufficient: PosteriorBSVAR (standard bsvars) and PosteriorBSVARSIGN (sign-restricted bsvarSIGNs) cover both ecosystems. No need to test all 6 types since computation paths are shared
- Verification tests live in inst/tinytest/ alongside existing test suite -- they run with R CMD check and contribute to coverage

#### Reference baselines
- Inline computation for expected values: tests extract raw posterior draws, then manually compute expected values using base R operations (cumsum, quantile, mean, comparison operators, etc.). Self-documenting and transparent
- Cross-validate against external packages where feasible: use vars/svars package output on the same data as a second reference point for IRFs and other comparable quantities. Adds confidence beyond self-contained checks
- Larger fixture: S=20-50 draws for more meaningful statistical verification (quantiles, probabilities). Not the S=5 fixture from examples
- Reproducibility via set.seed(): every verification test starts with set.seed() before estimation to ensure identical posterior draws across runs, making inline expected value computation deterministic

### Claude's Discretion
- Exact fixture size within the S=20-50 range
- Which specific external packages to cross-validate against and for which functions
- How to structure the test files (one per function family vs grouped)
- Whether to use a shared fixture posterior across tests or separate estimation per test

### Deferred Ideas (OUT OF SCOPE)
None -- discussion stayed within phase scope.

</user_constraints>

## Summary

This phase adds numerical correctness verification tests to bsvarPost's tinytest suite. The core task is to verify that 6 function families plus compare_* wrappers produce mathematically correct results by manually computing expected values from raw posterior draws using base R, then comparing with tight tolerance (1e-10). All computation logic is already implemented; this phase only adds verification tests.

The existing codebase already has some correctness tests (test_cdm.R verifies cumulative sums, test_hypothesis.R verifies posterior probabilities, test_response_summary.R verifies peak/duration), but they use small fixtures (S=2 or S=5) and don't systematically cover all function families with the same verification depth. Phase 3 establishes comprehensive cross-checks at S=30 draws with inline manual computation, plus tests for compare_* merging correctness.

**Primary recommendation:** Use S=30 draws, one shared PosteriorBSVAR fixture and one shared PosteriorBSVARSIGN fixture per test file, structure as one test file per function family (7 files), and skip external package cross-validation since `vars`/`svars` are not installed and would add Suggests dependencies.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| tinytest | 1.4.1 | Test framework | Already the project's chosen test framework |
| bsvars | current | Upstream estimation + compute_impulse_responses | Required dependency, source of posterior objects |
| bsvarSIGNs | current | Sign-restricted models | Required dependency for PosteriorBSVARSIGN |

### Testing Functions Used
| Function | Signature | Purpose |
|----------|-----------|---------|
| `expect_equal(current, target, tolerance)` | `tolerance` defaults to `sqrt(.Machine$double.eps)` = ~1.49e-8 | Numerical comparison with tolerance |
| `expect_true(expr)` | Boolean check | Structural property checks |
| `expect_identical(current, target)` | Exact match | Integer/character exact comparisons |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| External package cross-validation (vars/svars) | Pure inline computation only | vars/svars are NOT installed in this environment and adding them to Suggests would expand dependency footprint. Inline manual computation is sufficient and self-documenting. |

**Recommendation on external packages:** Skip cross-validation against vars/svars. Neither is installed, neither is in DESCRIPTION Suggests, and adding them solely for verification tests would bloat dependencies for CRAN submission. The inline manual computation approach is more transparent anyway -- the test IS the proof of correctness because you can read the base R operations directly.

## Architecture Patterns

### Recommended Test File Structure
```
inst/tinytest/
  test_verify_cdm.R                    # CDM cumulative sum correctness
  test_verify_tidy_intervals.R         # tidy_irf/tidy_cdm/tidy_fevd credible intervals
  test_verify_hypothesis.R             # hypothesis_irf/hypothesis_cdm posterior probabilities
  test_verify_response_summary.R       # peak, duration, half_life, time_to_threshold
  test_verify_restriction_audit.R      # restriction_audit probabilities
  test_verify_representative.R         # representative draw selection criteria
  test_verify_compare.R                # compare_* merging/differencing logic
```

### Pattern 1: Shared Fixture with Inline Verification
**What:** Each test file creates one or two posterior fixtures at the top, then runs multiple verification checks against them.
**When to use:** Always -- estimation is the expensive part; reuse within a file.
**Why S=30:** With 30 draws, quantile computation at probability=0.68 (probs = 0.16, 0.84) involves meaningful interpolation. Posterior probability estimates (count/total) have resolution of ~3.3%. Large enough to exercise all code paths while keeping test execution under a few seconds.

```r
# Source: Verified from existing test patterns in inst/tinytest/
Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")

# --- Shared fixture ---
data(us_fiscal_lsuw, package = "bsvars")
set.seed(2026)
spec_b <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
post_b <- bsvars::estimate(spec_b, S = 30, thin = 1, show_progress = FALSE)

# --- Manual verification ---
irf_raw <- bsvars::compute_impulse_responses(post_b, horizon = 8)
# irf_raw dimensions: [3 variables x 3 shocks x 9 horizons x 30 draws]

# Manually compute CDM via cumsum along horizon axis
cdm_manual <- irf_raw
for (h in 2:dim(irf_raw)[3]) {
  cdm_manual[, , h, ] <- cdm_manual[, , h - 1, ] + irf_raw[, , h, ]
}

cdm_result <- bsvarPost::cdm(post_b, horizon = 8)

# Strip class for comparison
strip_attrs <- function(x) { attributes(x) <- NULL; x }
expect_equal(strip_attrs(cdm_result), strip_attrs(cdm_manual), tolerance = 1e-10)
```

### Pattern 2: Quantile Credible Interval Verification
**What:** Extract draw-level values from tidy output, compute quantiles manually with base R, compare.
**Critical detail:** bsvarPost uses `stats::quantile()` with default type=7, and probability bands use `summary_probs(probability)` which computes `alpha = (1 - probability) / 2` giving probs `c(alpha, 1 - alpha)`.

```r
# For a specific variable/shock/horizon combination:
# 1. Get draw-level values from tidy_irf(draws = TRUE)
# 2. Manually compute: mean, median, sd, quantile(probs)
# 3. Compare with tidy_irf(draws = FALSE) summary columns

tidy_draws <- tidy_irf(post_b, horizon = 8, probability = 0.68, draws = TRUE)
tidy_summary <- tidy_irf(post_b, horizon = 8, probability = 0.68, draws = FALSE)

# Pick one cell: variable 1, shock 1, horizon 0
cell_draws <- tidy_draws[tidy_draws$variable == "ttr" &
                          tidy_draws$shock == "ttr" &
                          tidy_draws$horizon == 0, ]
cell_summary <- tidy_summary[tidy_summary$variable == "ttr" &
                              tidy_summary$shock == "ttr" &
                              tidy_summary$horizon == 0, ]

# Manual computation
expected_mean   <- mean(cell_draws$value)
expected_median <- stats::median(cell_draws$value)
expected_sd     <- stats::sd(cell_draws$value)
expected_lower  <- stats::quantile(cell_draws$value, probs = 0.16, names = FALSE)
expected_upper  <- stats::quantile(cell_draws$value, probs = 0.84, names = FALSE)

expect_equal(cell_summary$mean,   expected_mean,   tolerance = 1e-10)
expect_equal(cell_summary$median, expected_median,  tolerance = 1e-10)
expect_equal(cell_summary$sd,     expected_sd,      tolerance = 1e-10)
expect_equal(cell_summary$lower,  expected_lower,   tolerance = 1e-10)
expect_equal(cell_summary$upper,  expected_upper,   tolerance = 1e-10)
```

### Pattern 3: Posterior Probability Verification
**What:** Extract raw 4D array draws, apply comparison manually, compute mean of indicator.
**Critical detail:** hypothesis functions use `evaluate_draw_predicate()` which computes gap = lhs - rhs, then applies relation to gap. The posterior probability is `mean(indicator)`.

```r
# Raw IRF draws for variable=1, shock=1, horizon=2 (0-indexed, so index 3)
raw_values <- irf_raw[1, 1, 3, ]  # all 30 draws
manual_prob <- mean(raw_values > 0)

result <- hypothesis_irf(post_b, variable = 1, shock = 1, horizon = 2,
                         relation = ">", value = 0)
expect_equal(result$posterior_prob, manual_prob, tolerance = 1e-10)
```

### Pattern 4: Response Summary Verification (Peak/Duration/Half-life)
**What:** Loop over draws, compute summary statistic per draw, then summarize across draws.

```r
# Peak response: for each draw, find which.max along horizon axis
manual_peak_values <- vapply(seq_len(30), function(s) {
  path <- irf_raw[1, 1, , s]
  path[which.max(path)]
}, numeric(1))
manual_peak_horizons <- vapply(seq_len(30), function(s) {
  path <- irf_raw[1, 1, , s]
  horizons <- 0:8
  horizons[which.max(path)]
}, numeric(1))

pk <- peak_response(post_b, type = "irf", horizon = 8, variable = 1, shock = 1)
expect_equal(pk$mean_value,    mean(manual_peak_values),            tolerance = 1e-10)
expect_equal(pk$median_value,  stats::median(manual_peak_values),   tolerance = 1e-10)
expect_equal(pk$mean_horizon,  mean(manual_peak_horizons),          tolerance = 1e-10)
expect_equal(pk$median_horizon, stats::median(manual_peak_horizons), tolerance = 1e-10)
```

### Pattern 5: Compare Function Verification
**What:** Verify that compare_* output equals rbind of individual tidy_* outputs with correct model labels.

```r
# Estimate two models with different seeds
set.seed(2026)
post_a <- bsvars::estimate(spec_b, S = 30, thin = 1, show_progress = FALSE)
set.seed(2027)
post_b2 <- bsvars::estimate(spec_b, S = 30, thin = 1, show_progress = FALSE)

# compare_irf should equal rbind of tidy_irf for each model
comp <- compare_irf(m1 = post_a, m2 = post_b2, horizon = 4, probability = 0.68)
tidy_a <- tidy_irf(post_a, horizon = 4, probability = 0.68, model = "m1")
tidy_b <- tidy_irf(post_b2, horizon = 4, probability = 0.68, model = "m2")
manual_comp <- rbind(tidy_a, tidy_b)

# Compare the actual numerical values
expect_equal(nrow(comp), nrow(manual_comp))
expect_equal(sort(unique(comp$model)), c("m1", "m2"))
comp_m1 <- comp[comp$model == "m1", ]
expect_equal(comp_m1$median, tidy_a$median, tolerance = 1e-10)
```

### Pattern 6: Restriction Audit Verification
**What:** Extract raw IRF draws, manually check sign conditions, compare posterior_prob.

```r
# For irf_restriction(variable=1, shock=1, horizon=0, sign=1):
# Posterior prob = fraction of draws where irf[1,1,1,s] > 0
raw_h0 <- irf_raw[1, 1, 1, ]
manual_sign_prob <- mean(raw_h0 > 0)

audit <- restriction_audit(post_b, restrictions = list(
  irf_restriction(variable = 1, shock = 1, horizon = 0, sign = 1)
))
expect_equal(audit$posterior_prob, manual_sign_prob, tolerance = 1e-10)
```

### Pattern 7: Representative Draw Verification
**What:** Manually compute distances to median target, verify selected index.

```r
# Median-target: compute L2 distance from each draw to pointwise median
draws_4d <- irf_raw  # [N, N, H+1, S]
mat <- matrix(as.numeric(draws_4d), nrow = prod(dim(draws_4d)[1:3]), ncol = dim(draws_4d)[4])
target <- apply(mat, 1, stats::median)
distances <- colSums((mat - target)^2)
expected_idx <- which.min(distances)

rep_result <- representative_irf(post_b, horizon = 8, method = "median_target")
expect_equal(rep_result$draw_index, expected_idx)
```

### Anti-Patterns to Avoid
- **Testing output structure only, not numerical values:** Existing tests check `inherits(result, "bsvar_post_tbl")` and column names. Verification tests must check actual numbers.
- **Using the function's own output as the expected value:** The point is independent manual computation. Never do `expected <- tidy_irf(...)$mean; expect_equal(tidy_irf(...)$mean, expected)`.
- **Testing with S=2 draws:** Quantiles/probabilities degenerate with too few draws. S=30 gives meaningful interpolation.
- **Forgetting set.seed():** Without deterministic seeds, inline expected values won't match because draws differ between runs.
- **Comparing arrays with class attributes:** Use `strip_attrs()` or `unclass()` when comparing raw arrays, since cdm() adds "PosteriorCDM" class.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Quantile computation | Custom quantile function | `stats::quantile(..., type = 7)` | Must match exactly what bsvarPost uses internally |
| Summary statistics | Custom mean/sd | `mean()`, `stats::sd()`, `stats::median()` | These are the exact functions used in `summarise_vec()` |
| Probability bands | Custom interval computation | `summary_probs(probability)` pattern: `alpha = (1 - prob) / 2; c(alpha, 1 - alpha)` | Must replicate exact probability computation |
| CDM cumulation | Custom cumsum | Sequential addition: `cdm[,,h,] <- cdm[,,h-1,] + irf[,,h,]` | This is the exact algorithm in `compute_cdm_draws()` |

**Key insight:** Verification tests must use the SAME base R functions as the source code. The point is to verify the combination/orchestration is correct, not to introduce alternative implementations. Use `stats::quantile()` with default `type = 7` because that is what R uses by default and what `summarise_vec()` calls.

## Common Pitfalls

### Pitfall 1: Array Indexing Off-by-One (Horizon 0 vs Index 1)
**What goes wrong:** IRF arrays are indexed `[variable, shock, horizon_position, draw]` where horizon_position 1 corresponds to horizon 0. Confusing horizon values with array indices produces wrong expected values.
**Why it happens:** Dimnames use `"0", "1", "2", ...` but R arrays are 1-indexed.
**How to avoid:** When extracting `irf_raw[1, 1, h+1, s]` for horizon `h`, always add 1. Or use dimnames: `irf_raw[1, 1, "2", s]` for horizon 2.
**Warning signs:** Expected values that are systematically shifted by one horizon step.

### Pitfall 2: PosteriorBSVARSIGN sign_irf Dimension
**What goes wrong:** `sign_irf` for bsvarSIGNs models can be NxN (2D) or NxNxH (3D). Code in `extract_default_restrictions()` handles this with `if (length(dim(sign_irf)) == 2L) sign_irf <- array(sign_irf, dim = c(dim(sign_irf), 1L))`.
**Why it happens:** When sign restrictions are only at horizon 0, sign_irf is a matrix not a 3D array.
**How to avoid:** Always use a 2D NxN sign_irf matrix for test fixtures (horizon-0 restrictions only) as existing tests do.
**Warning signs:** Dimension mismatch errors in restriction_audit tests.

### Pitfall 3: Attribute Stripping for Array Comparison
**What goes wrong:** `expect_equal(cdm_result, cdm_manual)` fails because cdm_result has class "PosteriorCDM" and dimnames while cdm_manual is a plain array.
**Why it happens:** `cdm()` adds class attributes and dimnames.
**How to avoid:** Use `strip_attrs()` or compare element-by-element: `expect_equal(as.numeric(cdm_result), as.numeric(cdm_manual), tolerance = 1e-10)`.
**Warning signs:** Test failures mentioning class or attribute differences.

### Pitfall 4: Variable Names vs Integer Indices
**What goes wrong:** The us_fiscal_lsuw dataset has variable names "ttr", "gs", "gdp". When tests use integer indices (`variable = 1`), the function resolves them internally. But when comparing with raw array indexing, you must use the same convention.
**Why it happens:** `subset_response_draws()` resolves character names to integer indices via `resolve_selection()`.
**How to avoid:** Use integer indices consistently in both function calls and manual array subscripting. Or use character names in both.
**Warning signs:** Tests pass for one variable but fail for others; label mismatch errors.

### Pitfall 5: KMP_DUPLICATE_LIB_OK on macOS
**What goes wrong:** Tests crash with OpenMP duplicate library errors on macOS.
**Why it happens:** bsvars uses RcppArmadillo which links OpenMP; multiple loads conflict.
**How to avoid:** Every test file must start with `Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")`.
**Warning signs:** Mysterious segfaults or library loading errors on macOS.

### Pitfall 6: Using thin = 1 for Reproducible Draws
**What goes wrong:** If `thin` is not explicitly set to 1, the default thinning may discard draws unpredictably, making the mapping between posterior draw indices and raw computation non-deterministic.
**Why it happens:** MCMC thinning selects every k-th draw, changing which draws appear in the posterior.
**How to avoid:** Always pass `thin = 1` when calling `bsvars::estimate()` in tests.
**Warning signs:** Expected values don't match even with set.seed().

### Pitfall 7: bsvarSIGNs suppressMessages
**What goes wrong:** Model specification prints messages about identification setup. These clutter test output and may cause issues with output capture.
**Why it happens:** `specify_bsvarSIGN$new()` prints informational messages.
**How to avoid:** Wrap specification in `suppressMessages()` as existing tests do.
**Warning signs:** Unexpected console output during testing.

### Pitfall 8: Half-life NA Handling
**What goes wrong:** `compute_half_life()` returns `NA_real_` when the half-life is never reached. With S=30, some draws may never reach the half-life threshold, producing NA values in the results.
**Why it happens:** Short horizons or responses that don't decay quickly enough.
**How to avoid:** Use a long enough horizon (8+) and account for possible NAs in manual verification. Match the `summarise_optional_timing()` pattern which filters NAs before computing statistics.
**Warning signs:** Manual mean/median doesn't match because NAs are handled differently.

## Code Examples

### Example 1: Complete CDM Verification Test
```r
# Source: Verified against existing test_cdm.R pattern and R/utils.R compute_cdm_draws()
Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")

strip_attrs <- function(x) { attributes(x) <- NULL; x }

data(us_fiscal_lsuw, package = "bsvars")
set.seed(2026)
spec_b <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
post_b <- bsvars::estimate(spec_b, S = 30, thin = 1, show_progress = FALSE)

# Get raw IRFs from upstream
irf_raw <- bsvars::compute_impulse_responses(post_b, horizon = 8)
# dims: [3, 3, 9, 30]

# Manual CDM: cumulative sum along horizon axis
cdm_manual <- irf_raw
for (h in 2:dim(irf_raw)[3]) {
  cdm_manual[, , h, ] <- cdm_manual[, , h - 1, ] + irf_raw[, , h, ]
}

# bsvarPost CDM
cdm_result <- cdm(post_b, horizon = 8)

# Verify all elements match
expect_equal(strip_attrs(cdm_result), strip_attrs(cdm_manual), tolerance = 1e-10)
```

### Example 2: Complete Tidy Credible Interval Verification
```r
# Source: Verified against R/utils.R as_tidy_response_array() and summarise_vec()
tidy_draws <- tidy_irf(post_b, horizon = 8, probability = 0.68, draws = TRUE)
tidy_summary <- tidy_irf(post_b, horizon = 8, probability = 0.68, draws = FALSE)

# Verify multiple cells
for (v in c("ttr", "gs", "gdp")) {
  for (sh in c("ttr", "gs", "gdp")) {
    for (h in c(0, 4, 8)) {
      draws_cell <- tidy_draws$value[tidy_draws$variable == v &
                                      tidy_draws$shock == sh &
                                      tidy_draws$horizon == h]
      sum_cell <- tidy_summary[tidy_summary$variable == v &
                                tidy_summary$shock == sh &
                                tidy_summary$horizon == h, ]

      expect_equal(sum_cell$mean,   mean(draws_cell),                                        tolerance = 1e-10)
      expect_equal(sum_cell$median, stats::median(draws_cell),                               tolerance = 1e-10)
      expect_equal(sum_cell$sd,     stats::sd(draws_cell),                                   tolerance = 1e-10)
      expect_equal(sum_cell$lower,  stats::quantile(draws_cell, probs = 0.16, names = FALSE), tolerance = 1e-10)
      expect_equal(sum_cell$upper,  stats::quantile(draws_cell, probs = 0.84, names = FALSE), tolerance = 1e-10)
    }
  }
}
```

### Example 3: Hypothesis Posterior Probability Verification
```r
# Source: Verified against R/v2-utils.R evaluate_draw_predicate() and R/hypothesis.R
irf_raw <- bsvars::compute_impulse_responses(post_b, horizon = 8)

# Threshold test: P(IRF[ttr,ttr,h=2] > 0)
raw_values <- irf_raw[1, 1, 3, ]  # horizon 2 = index 3
manual_prob <- mean(raw_values > 0)
result <- hypothesis_irf(post_b, variable = 1, shock = 1, horizon = 2,
                         relation = ">", value = 0)
expect_equal(result$posterior_prob, manual_prob, tolerance = 1e-10)

# Pairwise test: P(IRF[ttr,ttr,h=2] > IRF[ttr,ttr,h=0])
lhs <- irf_raw[1, 1, 3, ]  # horizon 2
rhs <- irf_raw[1, 1, 1, ]  # horizon 0
manual_pair_prob <- mean(lhs > rhs)
pair_result <- hypothesis_irf(post_b, variable = 1, shock = 1, horizon = 2,
                              relation = ">",
                              compare_to = list(variable = 1, shock = 1, horizon = 0))
expect_equal(pair_result$posterior_prob, manual_pair_prob, tolerance = 1e-10)
```

### Example 4: Duration Response Verification
```r
# Source: Verified against R/response-summary.R compute_duration()
irf_raw <- bsvars::compute_impulse_responses(post_b, horizon = 8)

# Consecutive duration: how many horizons from start where IRF[1,1,,s] > 0
manual_consec <- vapply(seq_len(30), function(s) {
  path <- irf_raw[1, 1, , s]
  satisfied <- path > 0
  if (!satisfied[1]) return(0)
  fail <- which(!satisfied)[1]
  if (is.na(fail)) length(satisfied) else fail - 1L
}, numeric(1))

dur <- duration_response(post_b, type = "irf", horizon = 8,
                         variable = 1, shock = 1,
                         relation = ">", value = 0, mode = "consecutive")
expect_equal(dur$mean_duration, mean(manual_consec), tolerance = 1e-10)
expect_equal(dur$median_duration, stats::median(manual_consec), tolerance = 1e-10)
```

### Example 5: Compare Function Merging Verification
```r
# Source: Verified against R/compare.R compare_irf()
set.seed(2026)
post_a <- bsvars::estimate(spec_b, S = 30, thin = 1, show_progress = FALSE)
set.seed(2027)
post_b2 <- bsvars::estimate(spec_b, S = 30, thin = 1, show_progress = FALSE)

comp <- compare_irf(m1 = post_a, m2 = post_b2, horizon = 4, probability = 0.68)
tidy_a <- tidy_irf(post_a, horizon = 4, probability = 0.68, model = "m1")
tidy_b <- tidy_irf(post_b2, horizon = 4, probability = 0.68, model = "m2")

# Verify model labels
expect_equal(sort(unique(comp$model)), c("m1", "m2"))

# Verify numerical values match individual tidy calls
comp_m1 <- comp[comp$model == "m1", ]
comp_m2 <- comp[comp$model == "m2", ]
expect_equal(comp_m1$median, tidy_a$median, tolerance = 1e-10)
expect_equal(comp_m2$median, tidy_b$median, tolerance = 1e-10)
expect_equal(nrow(comp), nrow(tidy_a) + nrow(tidy_b))
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Testing structure only (class, column names) | Numerical correctness verification | This phase | Confidence in publication-quality results |
| S=2 or S=5 draws for tests | S=30 for meaningful statistical verification | This phase | Quantiles and probabilities become non-degenerate |
| No compare_* verification | Explicit merging logic verification | This phase | Ensures multi-model comparison is correct |

## Discretion Recommendations

### Fixture Size: S=30
**Rationale:** S=30 provides resolution of ~3.3% for posterior probabilities (1/30), meaningful quantile interpolation at prob=0.68 (indices 4.8 and 25.2 interpolate between actual draws), and keeps test execution fast (each estimation < 1 second for p=1, N=3). S=20 would work but gives coarser probability resolution (5%). S=50 adds marginal benefit but doubles estimation time.

### External Package Cross-Validation: SKIP
**Rationale:** `vars` and `svars` are not installed in the development environment. Adding them to Suggests solely for test cross-validation would expand the dependency footprint without proportional benefit. The inline manual computation approach is actually more rigorous -- it verifies the algorithm itself, not just agreement with another implementation that could have its own bugs. If cross-validation is desired later, it can be added as a separate enhancement.

### Test File Structure: One File Per Function Family (7 files)
**Rationale:** Keeps each file focused and runnable independently. Matches existing test file naming convention (`test_verify_*.R`). Makes it easy to identify which function family failed. Files:
1. `test_verify_cdm.R` -- CDM cumulative sums
2. `test_verify_tidy_intervals.R` -- tidy_irf/tidy_cdm/tidy_fevd credible intervals
3. `test_verify_hypothesis.R` -- hypothesis_irf/hypothesis_cdm posterior probabilities
4. `test_verify_response_summary.R` -- peak, duration, half_life, time_to_threshold
5. `test_verify_restriction_audit.R` -- restriction_audit sign/zero probabilities
6. `test_verify_representative.R` -- representative draw selection
7. `test_verify_compare.R` -- compare_* merging logic

### Shared vs Separate Fixtures: Shared Within Each File
**Rationale:** Each test file creates its own fixture(s) at the top. Sharing across files would require a shared setup mechanism that tinytest doesn't naturally support (no `setup.R` equivalent). Within a file, the bsvars fixture is created once and reused for all tests. The bsvarSIGNs fixture is only created in files that need it (restriction_audit, representative draws for most_likely_admissible). This keeps each file self-contained and independently runnable.

## Internal Function Reference

Key internal functions that verification tests may need to access via `:::`:

| Function | Location | Purpose | Access Pattern |
|----------|----------|---------|---------------|
| `get_irf_draws()` | R/v2-utils.R | Get named IRF array from posterior | `bsvarPost:::get_irf_draws(post, horizon)` |
| `get_cdm_draws()` | R/v2-utils.R | Get CDM array from posterior | `bsvarPost:::get_cdm_draws(post, horizon)` |
| `subset_response_draws()` | R/v2-utils.R | Subset 4D array by variable/shock/horizon | `bsvarPost:::subset_response_draws(draws, ...)` |
| `selection_target()` | R/v2-utils.R | Compute pointwise median/mean target | `bsvarPost:::selection_target(draws, "median")` |
| `distance_to_target()` | R/v2-utils.R | L2 distances from draws to target | `bsvarPost:::distance_to_target(draws, target, ...)` |
| `compute_posterior_kernel()` | R/v2-utils.R | Kernel scores for most_likely_admissible | `bsvarPost:::compute_posterior_kernel(post)` |
| `summarise_vec()` | R/utils.R | mean/median/sd/lower/upper from vector | Used internally, replicate with base R |
| `summary_probs()` | R/utils.R | Convert probability to quantile probs | `alpha = (1-p)/2; c(alpha, 1-alpha)` |

**Preference:** Use `:::` sparingly. Prefer calling the public API and manually computing expected values from raw arrays. Only use `:::` when needed to get intermediate objects (like raw CDM draws via `get_cdm_draws()`) that aren't easily obtained from the public API.

## Data and Fixture Details

### PosteriorBSVAR Fixture
- **Data:** `us_fiscal_lsuw` from bsvars package (306x3 quarterly time series: ttr, gs, gdp)
- **Spec:** `bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)` -- VAR(1), lower-triangular identification
- **Estimation:** `bsvars::estimate(spec, S = 30, thin = 1, show_progress = FALSE)`
- **IRF dimensions:** `[3 vars x 3 shocks x (horizon+1) horizons x 30 draws]`
- **Variable names:** "ttr", "gs", "gdp" (from Y rownames)

### PosteriorBSVARSIGN Fixture
- **Data:** `optimism` from bsvarSIGNs package (224x5: productivity, stock_prices, consumption, real_interest_rate, hours_worked)
- **Spec:** Use 2 variables for speed: `optimism[, 1:2]`, `p = 1`, `sign_irf = matrix(c(1, rep(NA, 3)), 2, 2)`
- **Estimation:** `bsvars::estimate(spec_s, S = 30, show_progress = FALSE)` (no `thin` needed)
- **Additional posterior elements:** `$posterior$Q` (rotation matrices), `$posterior$B` (structural matrix), `$posterior$shocks`
- **sign_irf:** 2x2 matrix, single sign restriction at [1,1] = 1 (productivity response to shock 1 is positive)

## Function Family Verification Checklist

### 1. cdm()
- [ ] Cumulative sums match `irf[,,h-1,] + irf[,,h,]` iteration
- [ ] Scaling by shock_sd divides correctly
- [ ] PosteriorBSVAR and PosteriorBSVARSIGN both verified

### 2. tidy_irf / tidy_cdm / tidy_fevd Credible Intervals
- [ ] mean matches `mean(draws)`
- [ ] median matches `stats::median(draws)`
- [ ] sd matches `stats::sd(draws)`
- [ ] lower matches `stats::quantile(draws, probs = (1-prob)/2)`
- [ ] upper matches `stats::quantile(draws, probs = 1 - (1-prob)/2)`
- [ ] Verify across multiple variable/shock/horizon cells
- [ ] tidy_cdm intervals verified against CDM draws
- [ ] tidy_fevd intervals verified against FEVD draws

### 3. hypothesis_irf / hypothesis_cdm
- [ ] Threshold posterior prob matches `mean(draws > value)`
- [ ] All 5 relations tested: >, >=, <, <=, ==
- [ ] Pairwise comparison matches `mean(lhs_draws > rhs_draws)`
- [ ] absolute = TRUE correctly applies abs()
- [ ] CDM hypothesis verified separately

### 4. Response Summaries (peak, duration, half_life, time_to_threshold)
- [ ] peak_response: value and horizon match `which.max()` applied per draw
- [ ] peak_response: absolute = TRUE uses `which.max(abs(path))`
- [ ] duration_response: consecutive mode matches first-failure counting
- [ ] duration_response: total mode matches `sum(satisfied)`
- [ ] half_life_response: matches first horizon below fraction * peak (with NA handling)
- [ ] time_to_threshold: matches first horizon satisfying condition (with NA handling)

### 5. restriction_audit
- [ ] Sign restriction prob matches `mean(irf[v,s,h+1,] > 0)` (or < 0)
- [ ] Zero restriction prob matches `mean(abs(irf[v,s,h+1,]) <= zero_tol)`
- [ ] Structural restriction prob matches `mean(B[v,s,] > 0)` (or < 0)
- [ ] Default restriction extraction from PosteriorBSVARSIGN verified

### 6. Representative Draws
- [ ] median_target: selected draw is `which.min(L2_distances)`
- [ ] L2 distance computed as `colSums((mat - target)^2)` where mat is draw_matrix
- [ ] most_likely_admissible: selected draw has highest kernel score (PosteriorBSVARSIGN only)
- [ ] When tied kernel scores, smallest L2 distance breaks tie

### 7. compare_* Functions
- [ ] compare_irf output equals rbind of individual tidy_irf calls
- [ ] compare_cdm output equals rbind of individual tidy_cdm calls
- [ ] compare_restrictions output equals rbind of individual restriction_audit calls
- [ ] compare_peak_response output equals rbind of individual peak_response calls
- [ ] Model labels correctly assigned from named arguments
- [ ] compare attribute set to TRUE

## Open Questions

1. **Estimation runtime at S=30**
   - What we know: S=5 runs in ~100ms for the us_fiscal_lsuw VAR(1). S=30 should be ~500ms.
   - What's unclear: Exact runtime on CI runners.
   - Recommendation: S=30 is fine. If tests are slow on CI, reduce to S=20 later.

2. **FEVD numerical stability**
   - What we know: FEVDs should sum to 1.0 across shocks at each horizon. This is a property that could be verified.
   - What's unclear: Whether upstream compute_variance_decompositions always produces exact row sums of 1.0 or if there's floating-point drift.
   - Recommendation: Add a test verifying FEVD row sums = 1.0 with tolerance 1e-10. This is a "free" extra verification.

3. **Narrative restriction audit testing**
   - What we know: Narrative restrictions require bsvarSIGNs models with sign_narrative specifications. The existing test_audit.R uses a synthetic example.
   - What's unclear: Whether a realistic fixture with narrative restrictions can be set up compactly.
   - Recommendation: Keep the synthetic approach from existing tests for narrative restrictions. The core sign/zero restriction audit is the primary verification target.

## Sources

### Primary (HIGH confidence)
- Direct codebase inspection: R/cdm.R, R/tidy.R, R/hypothesis.R, R/response-summary.R, R/audit.R, R/representative.R, R/compare.R, R/utils.R, R/v2-utils.R
- Existing test files: inst/tinytest/test_cdm.R, test_hypothesis.R, test_response_summary.R, test_representative.R, test_audit.R, test_tidy_compare_plot.R, test_compare_response_summary.R, test_compare_restrictions.R, test_timing_summary.R
- Interactive R verification: posterior object structure, IRF dimensions, quantile behavior, tinytest API

### Secondary (MEDIUM confidence)
- tinytest v1.4.1 API: `expect_equal()` tolerance parameter defaults to `sqrt(.Machine$double.eps)` = ~1.49e-8

### Tertiary (LOW confidence)
- None

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH -- tinytest and bsvars/bsvarSIGNs verified directly in R session
- Architecture: HIGH -- patterns derived from reading actual source code and existing test patterns
- Pitfalls: HIGH -- identified from direct codebase inspection and prior phase experiences
- Code examples: HIGH -- patterns verified against actual source code implementations

**Research date:** 2026-03-12
**Valid until:** 2026-04-12 (stable R package, no fast-moving dependencies)
