# Testing Patterns

**Analysis Date:** 2026-03-11

## Test Framework

**Runner:**
- `tinytest` (Suggested dependency in DESCRIPTION)
- Config: `tests/tinytest.R` entry point
- Framework explicitly checked at runtime: `if (!requireNamespace("tinytest", quietly = TRUE)) { quit(save = "no", status = 0) }`

**Assertion Library:**
- `tinytest::expect_*()` assertions (e.g., `expect_true()`, `expect_equal()`, `expect_error()`)

**Run Commands:**
```bash
# Run all tests (from package root)
Rscript --vanilla -e 'tinytest::test_package("bsvarPost")'

# Or via R CMD check
R CMD check bsvarPost_*.tar.gz

# Watch mode / iterative testing
# (Not available with tinytest; run specific test files manually)
```

## Test File Organization

**Location:**
- `inst/tinytest/` directory (24 test files detected)
- One test file per major module: `test_tidy_compare_plot.R`, `test_cdm.R`, `test_hypothesis.R`, `test_audit.R`, `test_reporting.R`, etc.
- Tests for optional dependencies stored in same directory with conditional branching

**Naming:**
- `test_*.R` prefix matching module names in `R/`
- Examples: `R/tidy.R` → `inst/tinytest/test_tidy_compare_plot.R`, `R/cdm.R` → `inst/tinytest/test_cdm.R`, `R/audit.R` → `inst/tinytest/test_audit.R`

**Directory Structure:**
```
inst/tinytest/
├── test_acceptance_diagnostics.R
├── test_aprscenario_bridge.R
├── test_audit.R
├── test_cdm.R
├── test_compare_hd_event.R
├── test_compare_plot_diagnostics.R
├── test_compare_response_summary.R
├── test_compare_restrictions.R
├── test_hd_event.R
├── test_hypothesis.R
├── test_joint_inference.R
├── test_plot_compare.R
├── test_plot_event.R
├── test_plot_joint_inference.R
├── test_plot_publication.R
├── test_plot_statements.R
├── test_plot_style.R
├── test_plot_template_annotation.R
├── test_representative.R
├── test_response_summary.R
├── test_reporting.R
├── test_tidy_compare_plot.R
├── test_timing_summary.R
└── test_tsibble_bridge.R
```

## Test Structure

**Suite Organization:**
```r
# Example from test_cdm.R
Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")

strip_attrs <- function(x) {
  attributes(x) <- NULL
  x
}

data(us_fiscal_lsuw, package = "bsvars")
set.seed(1)
spec_b <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
post_b <- bsvars::estimate(spec_b, S = 2, thin = 1, show_progress = FALSE)

# Test 1: Computation verification
irf_b <- bsvars::compute_impulse_responses(post_b, horizon = 2)
cdm_b <- cdm(post_b, horizon = 2)
manual_b <- irf_b
manual_b[, , 2, ] <- manual_b[, , 1, ] + irf_b[, , 2, ]
manual_b[, , 3, ] <- manual_b[, , 2, ] + irf_b[, , 3, ]
expect_equal(strip_attrs(cdm_b), strip_attrs(manual_b), tolerance = 1e-12)

# Test 2: Scaling functionality
data(optimism, package = "bsvarSIGNs")
set.seed(1)
spec_s <- suppressMessages(bsvarSIGNs::specify_bsvarSIGN$new(optimism, p = 1))
post_s <- bsvars::estimate(spec_s, S = 2, thin = 1, show_progress = FALSE)
cdm_s <- cdm(post_s, horizon = 2, scale_by = "shock_sd")
# ... manual calculation ...
expect_equal(strip_attrs(cdm_s), strip_attrs(manual_s), tolerance = 1e-12)
```

**Patterns:**

1. **Setup Pattern:**
   - Load data: `data(us_fiscal_lsuw, package = "bsvars")`
   - Set seed for reproducibility: `set.seed(1)`
   - Fit model: `post <- bsvars::estimate(spec, S = 5, thin = 1, show_progress = FALSE)`
   - Keep S (number of draws) small (2-6) for test speed

2. **Teardown Pattern:**
   - No explicit teardown; reliance on garbage collection after test
   - Temporary file cleanup: `tempfile(fileext = ".csv")` auto-deleted after test ends

3. **Assertion Pattern:**
   - `expect_true(condition)` for boolean checks: `expect_true(is.data.frame(full_tbl))`
   - `expect_equal(actual, expected, tolerance = 1e-12)` for numeric precision (tight tolerances for cdm/irf computation)
   - `expect_true(inherits(object, "class"))` for type checking: `expect_true(inherits(p, "ggplot"))`
   - `expect_error(expr, pattern)` for error verification

## Mocking

**Framework:** No explicit mocking library (e.g., `mockery`, `mock`); instead uses:
- **Stub data generation:** Create minimal arrays with known structure
- **Manual computation:** Compute expected values in test and compare

**Patterns:**
```r
# Example from test_plot_statements.R: Creating stub IRF array
make_statement_irf <- function() {
  arr <- array(0, dim = c(1, 1, 3, 4), dimnames = list("y", "shock", c("0", "1", "2"), c("1", "2", "3", "4")))
  arr[1, 1, , 1] <- c(1, 1, 1)
  arr[1, 1, , 2] <- c(1, 2, 2)
  arr[1, 1, , 3] <- c(-1, 2, 3)
  arr[1, 1, , 4] <- c(2, 2, 2)
  class(arr) <- c("PosteriorIR", class(arr))
  arr
}

irf_obj <- make_statement_irf()
hyp_tbl <- hypothesis_irf(irf_obj, variable = "y", shock = "shock", horizon = 0:2, relation = ">", value = 0)
```

**What to Mock:**
- External model objects from `bsvars::estimate()` - create minimal fitted models with small S (2-5 draws)
- Data arrays - manually construct arrays with known values to verify computation logic

**What NOT to Mock:**
- Core computation functions like `bsvars::compute_impulse_responses()` - verify integration with upstream
- ggplot2 layer rendering - test that plots are created, not pixel-perfect rendering
- Tibble construction - use real `tibble::tibble()` to verify data frame structure

## Fixtures and Factories

**Test Data:**
```r
# Example: Creating test specification and posterior from test_hypothesis.R
data(us_fiscal_lsuw)
set.seed(1)
spec_bsvar <- specify_bsvar$new(us_fiscal_lsuw, p = 1)
post_bsvar <- estimate(spec_bsvar, S = 5, thin = 1, show_progress = FALSE)

# Test with sign restrictions: test_audit.R
data(optimism)
sign_irf <- matrix(c(0, 1, rep(NA, 23)), 5, 5)
set.seed(1)
spec_sign <- specify_bsvarSIGN$new(optimism * 100, p = 4, sign_irf = sign_irf)
post_sign <- estimate(spec_sign, S = 5, thin = 1, show_progress = FALSE)
```

**Location:**
- No separate fixture files; all test data created inline
- Data loaded via `data(dataset_name, package = "package")` from `bsvars` and `bsvarSIGNs`
- Random seed set before model estimation to ensure reproducibility

**Factories:**
- `make_statement_irf()` in `test_plot_statements.R` - creates stub `PosteriorIR` array with known values
- `strip_attrs()` in `test_cdm.R` - removes attributes for clean comparison

## Coverage

**Requirements:** No explicit coverage target enforced or reported in CI

**View Coverage:**
```bash
# No built-in coverage command detected
# To add coverage reporting would require:
# R CMD build . && R CMD check --run-dontrun bsvarPost_*.tar.gz
```

## Test Types

**Unit Tests:**
- **Scope:** Individual functions (e.g., `tidy_irf()`, `cdm()`, `hypothesis_irf()`)
- **Approach:** Verify computation correctness by comparing to manual calculations
- **Example:** `test_cdm.R` manually constructs cumulative values and compares to `cdm()` output
- Files: `test_cdm.R`, `test_hypothesis.R`, `test_audit.R`, `test_response_summary.R`

**Integration Tests:**
- **Scope:** Multi-function workflows (e.g., model estimation → tidy extraction → comparison → plotting)
- **Approach:** Fit a real (small) model and verify end-to-end pipelines work
- **Example:** `test_tidy_compare_plot.R` tests `tidy_irf()` → `compare_irf()` → `ggplot2::autoplot()`
- Files: `test_tidy_compare_plot.R`, `test_plot_statements.R`, `test_reporting.R`

**E2E Tests:**
- **Framework:** Not used; tinytest does not distinguish E2E from integration
- **Approach:** Tests run as part of R CMD check; no separate pipeline

## Common Patterns

**Async Testing:**
- Not applicable (R is single-threaded for test execution)
- Tests run sequentially; no parallel async patterns

**Error Testing:**
```r
# Example from test_plot_statements.R
expect_error(
  plot_hypothesis(audit_tbl),
  "requires a hypothesis or magnitude-audit table",
  info = "plot_hypothesis: rejects audit tables."
)

expect_error(
  plot_restriction_audit(hyp_tbl),
  "requires a restriction-audit table",
  info = "plot_restriction_audit: rejects hypothesis tables."
)
```

**Optional Dependency Testing:**
```r
# Example from test_reporting.R
if (requireNamespace("gt", quietly = TRUE)) {
  gt_tbl <- as_gt(tbl, caption = "IRF comparison", digits = 2)
  expect_true(inherits(gt_tbl, "gt_tbl"))
}

# Example from test_tsibble_bridge.R
if (requireNamespace("tsibble", quietly = TRUE)) {
  # Test tsibble integration
}
```

**Type/Class Verification:**
```r
# From test_tidy_compare_plot.R
expect_equal(attr(irf_tbl, "object_type"), "irf")
expect_true(all(c("model", "object_type", "variable", "shock", "horizon", "median", "lower", "upper") %in% names(irf_tbl)))
expect_equal(sort(unique(irf_tbl$variable)), sort(expected_names))
```

**Precision Validation:**
```r
# From test_cdm.R: Tight tolerance for cumulative computations
expect_equal(strip_attrs(cdm_b), strip_attrs(manual_b), tolerance = 1e-12)

# From test_hypothesis.R: Probabilistic comparison
expect_equal(sign_res$posterior_prob, mean(sign_irf_draws[2, 1, 1, ] > 0))
```

## Development Checklist (from DEVELOPMENT.md)

Pre-push test protocol:

1. Regenerate documentation:
   ```bash
   Rscript --vanilla -e 'roxygen2::roxygenise(".")'
   ```

2. Build and check locally:
   ```bash
   R CMD build .
   _R_CHECK_FORCE_SUGGESTS_=false R CMD check --as-cran bsvarPost_*.tar.gz
   ```

3. Run focused tests for changed modules:
   ```bash
   # No direct way to run single test file with tinytest
   # Instead run full check or manually source test file
   ```

4. Verify staged diff and push only after GitHub Actions `R-CMD-check` is green

## Known Testing Constraints

**From DEVELOPMENT.md:**

- Optional-dependency tests must support both branches (installed and not installed)
- `tsibble::as_tsibble()` does not accept `regular = NULL` - only pass when explicitly supplied
- `aes_string()` is deprecated in ggplot2 - replace with tidy-eval `aes()` (technical debt)
- S3 roxygen blocks must share correct `@rdname` to avoid Rd mismatches
- CI environment may install suggested packages even if local machine doesn't

---

*Testing analysis: 2026-03-11*
