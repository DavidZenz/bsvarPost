# Architecture

**Analysis Date:** 2026-03-11

## Pattern Overview

**Overall:** S3 Object Dispatch with Layered Data Transformation Pipeline

**Key Characteristics:**
- S3 method dispatch for polymorphism across posterior model types (PosteriorBSVAR, PosteriorBSVARMIX, PosteriorBSVARMSH, etc.)
- Tidy data extraction pattern: raw posterior arrays → structured tibbles with credible intervals
- Comparison layer enabling side-by-side analysis of multiple models
- Summary/audit layer for derived quantities and diagnostics
- Plotting layer on top of tidied data using ggplot2

## Layers

**Input Layer (Posterior Objects):**
- Purpose: Accept fitted posterior model objects from upstream `bsvars` and `bsvarSIGNs` packages
- Location: Implicit imports in `bsvarPost-package.R`
- Contains: Methods that dispatch on PosteriorBSVAR, PosteriorBSVARMIX, PosteriorBSVARMSH, PosteriorBSVARSV, PosteriorBSVART, PosteriorBSVARSIGN
- Depends on: External package objects from `bsvars` and `bsvarSIGNs`
- Used by: All tidy, comparison, hypothesis, and audit functions

**Computation Layer (Arrays and Draws):**
- Purpose: Compute impulse responses, CDMs, FEVDs, historical decompositions, and structural shocks via calls to upstream bsvars functions
- Location: `R/cdm.R`, `R/tidy.R`, `R/response-summary.R`, `R/v2-utils.R`
- Contains: Computing logic that wraps `bsvars::compute_impulse_responses()`, `bsvars::compute_variance_decompositions()`, `bsvars::compute_structural_shocks()`, etc.
- Depends on: Input Layer (posterior objects), v2-utils helpers
- Used by: Extraction Layer

**Extraction Layer (Tidy Conversion):**
- Purpose: Transform multi-dimensional posterior draw arrays (4D: variable × shock × horizon × draw) into long-format tibbles with summarized credible intervals
- Location: `R/tidy.R`, `R/response-summary.R`, `R/utils.R`, `R/v2-utils.R`
- Contains: `tidy_irf()`, `tidy_cdm()`, `tidy_fevd()`, `tidy_forecast()`, `tidy_hd()`, `tidy_shocks()` generic functions and methods
- Depends on: Computation Layer, utility conversion functions
- Used by: Comparison Layer, Summary/Audit Layer, Reporting Layer

**Comparison Layer (Multi-Model Analysis):**
- Purpose: Enable comparative analysis by collecting and stacking tidy outputs from multiple models
- Location: `R/compare.R`
- Contains: `compare_irf()`, `compare_cdm()`, `compare_fevd()`, `compare_forecast()`, `compare_hd_event()`, `compare_restrictions()`, `compare_acceptance_diagnostics()`
- Depends on: Extraction Layer (uses `tidy_*()` functions internally)
- Used by: Plotting Layer, Reporting Layer

**Summary/Audit Layer (Derived Statistics):**
- Purpose: Compute derived summaries like peak responses, duration responses, half-life responses, hypothesis tests, and restriction audits
- Location: `R/response-summary.R`, `R/hypothesis.R`, `R/audit.R`, `R/representative.R`, `R/diagnostics.R`
- Contains: `peak_response()`, `duration_response()`, `half_life_response()`, `hypothesis_irf()`, `hypothesis_cdm()`, `restriction_audit()`, `acceptance_diagnostics()`
- Depends on: Extraction Layer, Computation Layer
- Used by: Plotting Layer, Reporting Layer

**Plotting Layer (Visualization):**
- Purpose: Create publication-ready visualizations of tidied and summarized results
- Location: `R/autoplot.R`, `R/plot-event.R`, `R/plot-compare.R`, `R/plot-statements.R`, `R/plot-diagnostics.R`, `R/plot-joint-inference.R`, `R/plot-publication.R`
- Contains: `autoplot()` methods for `bsvar_post_tbl`, specialized plotting functions like `plot_hd_event()`, `plot_shock_ranking()`, `plot_hypothesis()`
- Depends on: Extraction Layer, ggplot2, `R/plot-style.R` theme utilities
- Used by: End users for visualization

**Styling/Reporting Layer (Output Formatting):**
- Purpose: Apply consistent styling to plots and format tables for different output formats (kable, gt, flextable)
- Location: `R/plot-style.R`, `R/reporting.R`
- Contains: `theme_bsvarpost()`, `style_bsvar_plot()`, `publish_bsvar_plot()`, `report_bundle()`, `as_kable()`, `as_gt()`, `as_flextable()`
- Depends on: Plotting Layer, reporting packages (knitr, gt, flextable)
- Used by: End users for output generation

**Utility Layer (Cross-Cutting):**
- Purpose: Provide helper functions for dimension naming, data type conversion, array subsetting, and selection resolution
- Location: `R/utils.R`, `R/v2-utils.R`
- Contains: `new_bsvar_post_tbl()`, `set_response_dimnames()`, `set_time_dimnames()`, `set_hd_dimnames()`, `collect_models()`, `subset_response_draws()`, `infer_model_variable_names()`, bsvarSIGNs native symbol caching
- Depends on: None (provides dependencies)
- Used by: All other layers

## Data Flow

**Standard Extraction Workflow:**

1. User supplies posterior model object (e.g., `post_b`, output from `bsvars::estimate()`)
2. Call tidy function: `tidy_irf(post_b, horizon = 10)`
3. Tidy function dispatches to `tidy_irf.PosteriorBSVAR()`
4. Function calls `bsvars::compute_impulse_responses(post_b, horizon = 10)` → returns 4D array [variables × shocks × horizons × draws]
5. Helper `set_response_dimnames()` adds names to array dimensions using model metadata
6. `as_tidy_response_array()` reshapes array to long tibble with columns: variable, shock, horizon, draw, value, median, lower, upper, model
7. Wraps result in `bsvar_post_tbl` class (extends tibble) with attributes for object_type, draws flag, compare flag
8. Returns tidy tibble ready for plotting or summarization

**Comparison Workflow:**

1. User supplies multiple posterior models: `compare_irf(post_b, post_s, horizon = 10)`
2. `collect_models()` ensures named list with auto-generated names if needed
3. For each model, `tidy_irf()` is called, producing separate tibbles
4. `do.call(rbind, ...)` stacks all tibbles vertically
5. `new_bsvar_post_tbl()` wraps combined result with compare flag set to TRUE
6. Result ready for side-by-side plotting with model faceting/coloring

**Hypothesis Testing Workflow:**

1. User defines restriction: `restrict <- irf_restriction(matrix_spec, values)`
2. Call hypothesis test: `hypothesis_irf(post_b, restrictions = restrict, horizon = 10)`
3. Function computes tidy IRF (see extraction workflow)
4. Applies restriction matrix to filter compatible draws
5. Computes posterior probability of restriction satisfaction
6. Returns tidy table with posterior_prob column

**State Management:**

- **Array Dimensions:** Posterior draws stored as 4D arrays: [variable × shock × horizon/time × draw] for response functions, [variable × time × draw] for shocks/forecasts
- **Tidy Format:** Long-format tibbles with explicit rows per variable-shock-horizon-draw combination, plus computed summary statistics (median, lower, upper)
- **Metadata:** Attributes attached to tibbles store object_type (e.g., "irf", "cdm"), draws flag, compare flag, probability level, scaling parameters
- **Model Identity:** Model names propagated through all stages; added as explicit column in tidy format

## Key Abstractions

**bsvar_post_tbl (Tidy Posterior Table):**
- Purpose: Standard output container for all extraction and comparison operations
- Examples: `R/tidy.R`, `R/compare.R`, `R/response-summary.R`
- Pattern: Tibble subclass with attributes specifying object_type, draws, compare flags and parameters; enables polymorphic autoplot methods

**PosteriorCDM (Cumulative Dynamic Multiplier Object):**
- Purpose: Store computed CDM draws with metadata (probability, scale_by, scale_factors)
- Examples: `R/cdm.R` (returned by `cdm()` and stored as class PosteriorCDM)
- Pattern: 4D array with attributes; represents cumulative sum of impulse response path

**Restriction Objects (irf_restriction, narrative_restriction, structural_restriction):**
- Purpose: Encode prior restrictions on model coefficients and impulse responses
- Examples: `R/audit.R`, created via helper functions in `R/hypothesis.R`
- Pattern: List structure specifying restriction type, target matrix, and validation logic

**S3 Method Dispatch:**
- Purpose: Enable single function names (e.g., `tidy_irf()`) to work with multiple model types and derivative objects
- Examples: `tidy_irf.PosteriorBSVAR`, `tidy_irf.PosteriorIR` in `R/tidy.R`
- Pattern: UseMethod() dispatcher with separate implementations per type; many posterior model types delegate to shared implementation

## Entry Points

**Data Extraction:**
- Location: `R/tidy.R` - `tidy_irf()`, `tidy_cdm()`, `tidy_fevd()`, `tidy_forecast()`, `tidy_hd()`, `tidy_shocks()`
- Triggers: User calls `tidy_*()` with posterior model object
- Responsibilities: Accept model, compute posterior draws/arrays, summarize to credible intervals, return tidy tibble

**Model Comparison:**
- Location: `R/compare.R` - `compare_irf()`, `compare_cdm()`, `compare_fevd()`, `compare_forecast()`, `compare_hd_event()`, `compare_restrictions()`, `compare_acceptance_diagnostics()`
- Triggers: User calls `compare_*()` with multiple models
- Responsibilities: Collect models, apply tidy extraction to each, stack results, mark as comparison

**Plotting:**
- Location: `R/autoplot.R`, `R/plot-event.R`, `R/plot-compare.R` - `autoplot()` methods and specialized functions
- Triggers: User calls `plot()` or `autoplot()` on tidy tables, or calls specialized `plot_*()` functions
- Responsibilities: Detect object_type from attributes, route to appropriate geom/facet logic, apply theme

**Hypothesis Testing:**
- Location: `R/hypothesis.R` - `hypothesis_irf()`, `hypothesis_cdm()`, `joint_hypothesis_irf()`, `joint_hypothesis_cdm()`
- Triggers: User calls hypothesis function with posterior and restriction objects
- Responsibilities: Extract tidy data, check restrictions, compute posterior probability, return probability table

**Auditing & Diagnostics:**
- Location: `R/audit.R`, `R/diagnostics.R` - `restriction_audit()`, `acceptance_diagnostics()`, `shock_ranking()`
- Triggers: User calls audit/diagnostic function on posterior
- Responsibilities: Compute diagnostics (admissibility weights, restriction compatibility), return summary table

**Reporting & Export:**
- Location: `R/reporting.R` - `report_bundle()`, `report_table()`, `as_kable()`, `as_gt()`, `as_flextable()`
- Triggers: User calls reporting function on tidy table or report bundle
- Responsibilities: Format table for target output (markdown, HTML, LaTeX), optionally add plot

## Error Handling

**Strategy:** Check input types early, use informative error messages, fail fast before expensive computation

**Patterns:**
- Type checking via `inherits()` and `is()` for class validation (e.g., `if (!inherits(object, "bsvar_post_tbl"))`)
- Selection validation in `resolve_selection()` (`R/v2-utils.R`) catches out-of-bounds indices and unknown labels
- Dimension matching checks in reshape functions (e.g., array dimension mismatch raises error in `set_response_dimnames()`)
- Null safety checks using `%||%` operator (`R/cdm.R`) for optional attributes

## Cross-Cutting Concerns

**Logging:** None - package uses silent computation; progress suppressed by passing `show_progress = FALSE` to upstream bsvars functions

**Validation:** Input validation in entry-point functions (tidy, compare, hypothesis); dimension and dimname validation in utility functions

**Authentication:** Not applicable - package is pure analysis tool without external API integration

**Posterior Probability Handling:** Standard equal-tailed credible interval computation in `summary_probs()` (`R/utils.R`); intervals computed from draws quantiles; intervals are default summarization, raw draws available via `draws = TRUE` parameter

---

*Architecture analysis: 2026-03-11*
