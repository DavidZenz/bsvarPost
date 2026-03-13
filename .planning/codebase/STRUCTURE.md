# Codebase Structure

**Analysis Date:** 2026-03-11

## Directory Layout

```
sweet-chatelet/
├── R/                          # Core R source files (27 files)
├── man/                        # Roxygen2 generated documentation (63 files)
├── inst/tinytest/             # Test suite (19 test files)
├── vignettes/                 # Package articles
├── tests/                      # Test runner configuration
├── tools/                      # Development utilities
├── DESCRIPTION                # Package metadata
├── NAMESPACE                  # Roxygen2-generated exports and imports
├── .Rbuildignore             # R build exclusions
├── README.md                 # User documentation
├── ROADMAP.md                # Development roadmap
├── DEVELOPMENT.md            # Contributor guide
└── index.md                  # Package website index
```

## Directory Purposes

**R/ (Core Implementation):**
- Purpose: All user-facing and internal functions
- Contains: S3 methods, tidy extractors, comparison helpers, plotting functions, utilities
- Key files:
  - `bsvarPost-package.R` - Package imports and global variables
  - `tidy.R` - Tidy extraction generics and methods
  - `compare.R` - Multi-model comparison functions
  - `cdm.R` - Cumulative dynamic multipliers computation
  - `autoplot.R` - ggplot2 integration
  - `plot-*.R` - Specialized plotting functions (event, compare, statements, diagnostics, joint-inference, publication)
  - `plot-style.R` - Theme and styling utilities
  - `hypothesis.R` - Restriction testing functions
  - `representative.R` - Representative draw selection
  - `response-summary.R` - Peak response, duration, half-life summaries
  - `audit.R` - Restriction audits and shock rankings
  - `diagnostics.R` - Acceptance diagnostics
  - `reporting.R` - Table export and formatting
  - `utils.R` - Core utilities (bsvar_post_tbl creation, dimname handling, model collection)
  - `v2-utils.R` - Advanced utilities (array subsetting, selection resolution, native symbol caching)
  - `joint-inference.R` - Joint hypothesis testing
  - `representative.R` - Representative draw extraction
  - `tidy.R` - Main data tidying functions
  - `tsibble.R` - tsibble conversion helpers
  - `aprscenario.R` - APRScenario integration bridge

**man/ (Documentation):**
- Purpose: Roxygen2-generated .Rd files for all exported functions (auto-generated, do not edit)
- Contains: 63 .Rd files corresponding to all exported functions
- Note: Modify by editing roxygen comments in R/ files, then run roxygen regeneration

**inst/tinytest/ (Test Suite):**
- Purpose: Executable test suite using tinytest framework
- Location: Tests run via `R CMD check` and `tinytest::test_package("bsvarPost")`
- Contains: 19 test files with patterns:
  - `test_cdm.R` - CDM computation and structure tests
  - `test_tidy_*.R` - Tidy extraction tests
  - `test_compare_*.R` - Comparison function tests
  - `test_hypothesis.R` - Hypothesis testing validation
  - `test_plot_*.R` - Plotting output tests
  - `test_audit.R` - Restriction audit tests
  - `test_acceptance_diagnostics.R` - Diagnostics tests
  - `test_representative.R` - Representative draw selection tests
  - `test_response_summary.R` - Summary statistic tests
  - `test_reporting.R` - Table export tests
- Pattern: Direct assertions using `expect_equal()`, `expect_true()`, comparison tolerance set to 1e-12

**vignettes/ (User Articles):**
- Purpose: Long-form tutorials and workflows
- Key files: `bsvarPost-getting-started.Rmd`, `bsvarPost-workflows.Rmd`
- Format: R Markdown documents compiled by knitr

**tests/ (Test Configuration):**
- Purpose: Test runner entry point
- Contains: `tinytest.R` - runs `tinytest::test_package("bsvarPost")`

**tools/ (Development):**
- Purpose: Build and release automation scripts
- Contains: Utility scripts for package maintenance

## Key File Locations

**Entry Points:**
- `R/bsvarPost-package.R` - Package initialization, imports, global variables
- User-facing entry points are in `R/tidy.R`, `R/compare.R`, `R/plot-*.R`, `R/hypothesis.R`, `R/audit.R`

**Configuration:**
- `DESCRIPTION` - Package metadata (dependencies, version, authors)
- `NAMESPACE` - Roxygen2-generated exports and imports (auto-generated from roxygen comments)
- `.Rbuildignore` - Files excluded from R package build

**Core Logic:**
- `R/utils.R` - Tidy tibble creation and dimension handling
- `R/v2-utils.R` - Array manipulation and selection resolution
- `R/tidy.R` - Main extraction layer (tidy_irf, tidy_cdm, tidy_fevd, etc.)
- `R/compare.R` - Model comparison layer
- `R/cdm.R` - CDM computation and wrapping

**Plotting:**
- `R/autoplot.R` - Base autoplot method and generic plotting logic
- `R/plot-event.R` - HD event and shock ranking plots
- `R/plot-compare.R` - Comparison-specific plots
- `R/plot-style.R` - Theme and styling utilities
- `R/plot-publication.R` - Publication-ready plot styling
- `R/plot-statements.R` - Statement-based IR plots

**Summary/Analysis:**
- `R/response-summary.R` - Peak response, duration, half-life, time-to-threshold
- `R/hypothesis.R` - Hypothesis testing and restriction helpers
- `R/audit.R` - Restriction audits and shock ranking
- `R/diagnostics.R` - Acceptance diagnostics
- `R/representative.R` - Representative draw selection
- `R/joint-inference.R` - Joint hypothesis testing

**Reporting:**
- `R/reporting.R` - Table formatting and bundle creation

**Testing:**
- `inst/tinytest/` - Complete test suite

## Naming Conventions

**Files:**
- `tidy-*.R` pattern for tidying functions (e.g., `R/tidy.R`)
- `plot-*.R` pattern for plotting functions (e.g., `R/plot-event.R`, `R/plot-compare.R`)
- `compare-*.R` pattern for comparison functions (e.g., functions in `R/compare.R`)
- `test_*.R` pattern for tests (e.g., `inst/tinytest/test_cdm.R`)
- Hyphenated lowercase for multi-word files

**Functions:**
- Snake_case for exported functions: `tidy_irf`, `compare_irf`, `plot_hd_event`, `hypothesis_irf`
- Underscore prefix for internal helpers: `tidy_irf_model`, `peak_response_model`, `as_tidy_response_array`
- CamelCase for S3 class names: `PosteriorBSVAR`, `PosteriorCDM`, `bsvar_post_tbl`

**Variables:**
- Snake_case: `object_type`, `var_names`, `shock_names`, `posterior_prob`
- Single-letter indices in tight loops: `i`, `j`, `s` (for draw index)
- Descriptive names for extracted components: `prob_alpha`, `summary_probs`, `eval_path`

**Types/Classes:**
- S3 methods use dot notation: `tidy_irf.PosteriorBSVAR`, `autoplot.bsvar_post_tbl`
- Multiple inheritance via `class(x) <- c("bsvar_post_tbl", class(x))` (tibble subclass)
- Posterior array types: `PosteriorIR`, `PosteriorCDM`, `PosteriorFEVD`, `PosteriorShocks`, `PosteriorHD`
- Posterior model types: `PosteriorBSVAR`, `PosteriorBSVARMIX`, `PosteriorBSVARMSH`, `PosteriorBSVARSV`, `PosteriorBSVART`, `PosteriorBSVARSIGN`

## Where to Add New Code

**New Tidy Extraction Function:**
- File: `R/tidy.R`
- Pattern: Create generic `function_name <- function(object, ...) UseMethod("function_name")`
- Then add methods: `function_name.PosteriorBSVAR <- function(object, ...) { ... }`
- For each posterior model type: duplicate method assignment or alias to shared implementation
- Helper function pattern: `function_name_model <- function(...)` for shared logic
- Use `as_tidy_response_array()` or `as_tidy_time_array()` to reshape arrays to tibbles
- Wrap result: `new_bsvar_post_tbl(result, object_type = "type_name")`

**New Comparison Function:**
- File: `R/compare.R`
- Pattern: `compare_name <- function(..., horizon = 10, probability = 0.68, draws = FALSE)`
- Collect models: `models <- collect_models(...)`
- Apply tidy function per model: `lapply(names(models), function(nm) tidy_name(models[[nm]], ..., model = nm))`
- Stack results: `new_bsvar_post_tbl(do.call(rbind, out), object_type = "type_name", compare = TRUE)`
- Call `set_compare_flag()` to mark output

**New Plot Function:**
- File: `R/plot-[category].R` (create new file if not category-specific plotting yet)
- Pattern: Either add to `autoplot()` dispatch for existing tidy types OR create specialized function
- If specialized: handle both tidy input and raw posterior input (compute tidy if needed)
- Validate object_type matches expected type
- Use `ggplot2::ggplot()` + geom layers
- Apply `ggplot2::theme_minimal()` as base, users can override with `style_bsvar_plot()`

**New Summary/Audit Function:**
- File: `R/response-summary.R` (or new file like `R/new-category.R`)
- Pattern: Generic dispatch function + implementation per model type
- Extract draw array: `get_irf_draws()` or `get_cdm_draws()` for computed arrays
- Subset draws: `subset_response_draws(draws, variables = ..., shocks = ..., horizons = ...)`
- Summarize per draw: typically loop over dimensions, apply statistic, collect results
- Return as tibble: `new_bsvar_post_tbl(result_tibble, object_type = "new_type")`

**New Utility Helper:**
- Internal-only functions: `R/utils.R` for general purpose, `R/v2-utils.R` for array/selection logic
- Follow pattern: Pure functions with clear inputs/outputs, no side effects
- For dimension manipulation: consistent with `set_response_dimnames()`, `set_time_dimnames()` patterns
- For selection: consistent with `resolve_selection()` error handling (unknown labels, bounds checking)

**New Test:**
- File: `inst/tinytest/test_[category].R`
- Pattern: Load sample data (e.g., `data(us_fiscal_lsuw, package = "bsvars")`)
- Estimate model: `spec <- bsvars::specify_bsvar$new(...); post <- bsvars::estimate(...)`
- Call function under test
- Assert results: `expect_equal()` with appropriate tolerance (1e-12 for numerical, exact for structure)
- Include both happy path and error cases

## Special Directories

**man/:**
- Purpose: Roxygen2-generated documentation files
- Generated: Yes (auto-generated from roxygen comments in R files)
- Committed: Yes (but modifications should be made in source, not here)
- Regenerate: Run `roxygen2::roxygenise()` after editing .R comments

**vignettes/:**
- Purpose: Long-form documentation
- Generated: No (hand-written R Markdown)
- Committed: Yes
- Build: `knitr::knit()` during package build

**inst/tinytest/:**
- Purpose: Test suite
- Generated: No (hand-written)
- Committed: Yes
- Run: `tinytest::test_package("bsvarPost")` or `R CMD check`

**.planning/codebase/:**
- Purpose: GSD codebase documentation
- Generated: By GSD codebase mapper
- Committed: Yes
- Contents: ARCHITECTURE.md, STRUCTURE.md, CONVENTIONS.md, TESTING.md, CONCERNS.md (as created)

---

*Structure analysis: 2026-03-11*
