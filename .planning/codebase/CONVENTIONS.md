# Coding Conventions

**Analysis Date:** 2026-03-11

## Naming Patterns

**Files:**
- Snake case for R files: `response-summary.R`, `plot-publication.R`, `v2-utils.R`
- Thematic grouping: core extraction (`tidy.R`), comparisons (`compare.R`), diagnostics (`diagnostics.R`), plotting layers (`plot-*.R`)
- Test files match module names: `test_reporting.R` → `R/reporting.R`

**Functions:**
- Snake case: `tidy_irf()`, `compare_irf()`, `peak_response()`, `hypothesis_irf()`
- Prefixes indicate function families: `tidy_*`, `compare_*`, `plot_*`, `hypothesis_*`, `magnitude_audit()`, `restriction_audit()`
- S3 methods use dot notation: `tidy_irf.PosteriorIR()`, `tidy_irf.PosteriorBSVAR()`, `peak_response.PosteriorCDM()`
- Internal helper functions (not exported) also use snake case: `summarise_vec()`, `collect_models()`, `ensure_model_names()`, `resolve_scale_factors()`

**Variables:**
- Snake case: `scale_by`, `scale_var`, `probability`, `object_type`, `model_name`
- Short descriptors for loop indices: `i`, `j`, `t`, `h` (for common econometric dimensions like variables, shocks, time, horizons)
- Plural form for collections: `models`, `draws`, `rows`, `dims`
- Meta/attribute variables: `dns` (dimnames), `idx` (index), `nms` (names)

**Types:**
- PascalCase for custom S3 classes: `PosteriorIR`, `PosteriorCDM`, `PosteriorBSVAR`, `bsvar_post_tbl`, `bsvar_report_bundle`
- Method dispatch classes aligned with upstream `bsvars` and `bsvarSIGNs` package classes

## Code Style

**Formatting:**
- 2-space indentation (observed throughout codebase)
- Line length typically kept under 100 characters
- Use spaces around operators: `x <- 1`, `x + y`, `f(x, y)`
- Function calls use space after function name: `ggplot2::aes(x = ...)` not `ggplot2::aes(...)`

**Linting:**
- No explicit linting configuration detected (no `.eslintrc`, `.editorconfig`, etc.)
- Clean local check and CI validation required before push (see `DEVELOPMENT.md`)

## Import Organization

**Order:**
1. Base R functions (e.g., `new.env()`, `is.null()`, `seq_along()`)
2. Package imports via `@importFrom` in roxygen headers
3. Qualified calls using `::` for clarity, especially for ggplot2 layers: `ggplot2::ggplot()`, `ggplot2::geom_ribbon()`

**Path Aliases:**
- None detected; all external package functions use `PackageName::function()` explicit notation
- `bsvars::compute_impulse_responses()`, `tibble::tibble()`, `rlang::.data`

**Imports in `R/bsvarPost-package.R`:**
```r
@importFrom tibble tibble as_tibble
@importFrom ggplot2 autoplot ggplot aes geom_line geom_ribbon geom_hline
@importFrom ggplot2 facet_grid facet_wrap labs theme_minimal scale_x_continuous
@importFrom ggplot2 vars
@importFrom methods is
@importFrom rlang .data
@importFrom utils globalVariables
@import bsvars
@import bsvarSIGNs
```

**Global Variables Declaration:**
All non-standard-evaluation variables declared in `globalVariables()` in package file:
```r
utils::globalVariables(c(
  "variable", "shock", "horizon", "median", "lower", "upper",
  "metric", "value", "model", "flag", "posterior_prob",
  "restriction", "rank_score"
))
```

## Error Handling

**Patterns:**
- Explicit `stop(..., call. = FALSE)` for user-facing errors (no automatic call context)
- Examples from codebase:
  - `stop("'scale_var' must be NULL, character, or numeric.", call. = FALSE)` in `utils.R:168`
  - `stop("Selection indices are out of bounds.", call. = FALSE)` in `v2-utils.R`
  - `stop("`plot_acceptance_diagnostics()` requires an acceptance-diagnostics table or a 'PosteriorBSVARSIGN' object.", call. = FALSE)` in `plot-diagnostics.R:20`

- `tryCatch()` for graceful fallback extraction: `tryCatch(model$last_draw$data_matrices$Y, error = function(e) NULL)` in `utils.R:45`
- Validation before processing: Check `is.null()`, `anyNA()`, dimension mismatches
- Input validation with informative messages when selection fails: `stop("Unknown selection label(s): ", paste(...), call. = FALSE)` in `v2-utils.R`

## Logging

**Framework:** Base R `message()` and `cat()` (no dedicated logging package)

**Patterns:**
- Progress indicators from upstream functions controlled via `show_progress = FALSE` (e.g., `bsvars::compute_historical_decompositions(object, show_progress = FALSE)` in `tidy.R:133`)
- Warnings suppressed with `suppressMessages()` when instantiating sign-restricted specifications to avoid unnecessary noise
- No custom logging wrapper; relies on standard error/warning/message channels

## Comments

**When to Comment:**
- Roxygen `#'` blocks for exported functions: detailed parameter descriptions, return types, `@export` tag
- Roxygen S3 methods: `@rdname` to group method documentation, `@inheritParams` to avoid duplication
- Complex algorithmic sections: e.g., `resolve_peak()` logic for identifying peak response values
- Trade-off documentation in `DEVELOPMENT.md` about native bridge and bsvarSIGNs coupling

**JSDoc/TSDoc:**
- Roxygen markdown documentation: `@param object A posterior model object or posterior IRF array.`
- Return values documented in `@description` or via implicit tibble/array type
- Examples not typically included in roxygen (documentation via vignettes instead)

**Internal Comments:**
- Sparse internal comments; code clarity relied upon via naming
- `v2-utils.R` contains developer notes explaining the bsvarSIGNs native bridge rationale and coupling trade-off

## Function Design

**Size:**
- Functions range from ~5 lines (simple S3 method delegation like `tidy_irf.PosteriorBSVARMIX <- tidy_irf.PosteriorBSVAR`) to 100+ lines for complex array transformations
- Larger complex functions (e.g., `as_tidy_response_array()` in `utils.R`, 45 lines) organized with clear loops and index management

**Parameters:**
- Explicit parameter defaults: `probability = 0.68`, `horizon = 10`, `draws = FALSE`, `model = "model1"`
- Optional parameters: `variable = NULL`, `shock = NULL`, `restrictions = NULL`
- `...` used for method dispatch pass-through: `function(object, ...) UseMethod("function")`
- Long parameter lists documented in roxygen blocks with `@inheritParams` for method families

**Return Values:**
- S3 objects with class attributes: `class(x) <- c("bsvar_post_tbl", class(x))`
- Attributes added via `attr(x, "name") <- value` to carry metadata
- Tibbles returned by tidy helpers: `tibble::tibble(model = ..., variable = ..., shock = ..., ...)`
- Arrays returned from computation functions with structured dimnames

## Module Design

**Exports:**
- Public functions marked with `@export` in roxygen blocks
- All exported functions have roxygen documentation
- Example: `tidy_irf()`, `compare_irf()`, `cdm()`, `hypothesis_irf()`, `restriction_audit()`, `peak_response()`, `autoplot.bsvar_post_tbl()`

**Barrel Files:**
- Not used; each file handles one logical module (e.g., `tidy.R` for tidy extraction helpers, `compare.R` for multi-model comparison)

**Internal Architecture:**
- `utils.R`: Core array transformation and tibble creation: `as_tidy_response_array()`, `as_tidy_time_array()`, `as_tidy_hd_array()`, `new_bsvar_post_tbl()`
- `v2-utils.R`: Native bridge to bsvarSIGNs internals, array subsetting: `bsvarsigns_native()`, `subset_response_draws()`, `resolve_selection()`
- `plot-*.R`: ggplot2 visualization layers organized by output type
- `*-summary.R`: Response characteristic extraction: `response-summary.R` for peak, duration, half-life metrics

## Roxygen Integration

**Setup:**
- `DESCRIPTION`: `RoxygenNote: 7.3.3`
- `NAMESPACE` generated by roxygen; never edited manually
- Pre-push workflow regenerates docs: `Rscript --vanilla -e 'roxygen2::roxygenise(".")'`

**S3 Method Documentation:**
- Generic function defined with `@export` and roxygen block
- Methods use `@rdname` to group documentation
- Generic method implementations: `function(object, ...) UseMethod("function_name")`
- Example from `tidy.R`:
  ```r
  #' Tidy posterior impulse responses
  #' @param object A posterior model object or posterior IRF array.
  #' @export
  tidy_irf <- function(object, ...) UseMethod("tidy_irf")

  #' @rdname tidy_irf
  #' @export
  tidy_irf.PosteriorIR <- function(object, probability = 0.68, ...) { ... }

  #' @rdname tidy_irf
  #' @export
  tidy_irf.PosteriorBSVAR <- function(object, horizon = 10, ...) { ... }
  ```

---

*Convention analysis: 2026-03-11*
