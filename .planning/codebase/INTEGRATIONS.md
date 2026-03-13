# External Integrations

**Analysis Date:** 2026-03-11

## APIs & External Services

**Bayesian Time Series Analysis:**
- `bsvars` package - Provides core computation functions
  - Functions: `compute_impulse_responses()`, `compute_variance_decompositions()`, `compute_structural_shocks()`, `compute_historical_decompositions()`, `forecast()`
  - Used in: `R/tidy.R` (all tidy extraction functions)

- `bsvarSIGNs` package - Provides sign-restricted SVAR estimation
  - Native symbol bridge: `R/v2-utils.R` resolves registered native symbols at runtime for restriction auditing
  - Used in: `R/audit.R`, `R/representative.R`, `R/v2-utils.R`
  - Classes: PosteriorBSVARSIGN and related model types

**Optional Forecast Scenario Integration:**
- `APRScenario` package - Scenario analysis framework
  - Bridge implementation: `R/aprscenario.R`
  - Functions: `as_apr_cond_forc()`, `tidy_apr_forecast()`, `apr_gen_mats()`
  - Converts between bsvarPost forecast tables and APRScenario format (columns: `hor`, `variable`, `lower`, `center`, `upper`)
  - Failure mode: `requireNamespace()` check at runtime, raises error if not installed when called

## Data Storage

**Databases:**
- Not applicable - Package operates on in-memory R objects

**File Storage:**
- Local filesystem only via `write_bsvar_csv()` in `R/reporting.R`
  - Uses `utils::write.csv()` for CSV export
  - Returns normalized file path on success

**Caching:**
- None - Results are computed and held in memory during R session

## Authentication & Identity

**Auth Provider:**
- Not applicable - No authentication required

## Monitoring & Observability

**Error Tracking:**
- None configured

**Logs:**
- Standard R console output
- R CMD check logs available in GitHub Actions artifacts (`.github/workflows/R-CMD-check.yaml`)

## CI/CD & Deployment

**Hosting:**
- GitHub repository: https://github.com/DavidZenz/bsvarPost
- Package website: https://davidzenz.github.io/bsvarPost/
- CRAN distribution (planned)

**CI Pipeline:**
- GitHub Actions (`.github/workflows/`)
  - **R-CMD-check**: Triggered on push/PR to main, runs `R CMD check --as-cran --no-manual`
  - **pkgdown**: Triggered on push to main, builds and deploys documentation site to GitHub Pages

**Deployment Artifacts:**
- Documentation: `docs/` folder committed to `gh-pages` branch via pkgdown workflow
- CRAN package tarball: `R CMD build .` produces `.tar.gz` for distribution

## Environment Configuration

**Required env vars:**
- None

**Secrets location:**
- GitHub repository settings (for deployment permissions only)

## Table Export Backends

**Reporting Integration:**
- `knitr` - HTML tables via `as_kable()` in `R/reporting.R`
  - Function: `knitr::kable()`

- `gt` (Optional) - Native gt tables via `as_gt()` in `R/reporting.R`
  - Functions: `gt::gt()`, `gt::tab_header()`
  - Requires: `requireNamespace("gt", quietly = TRUE)` check

- `flextable` (Optional) - Office document tables via `as_flextable()` in `R/reporting.R`
  - Functions: `flextable::flextable()`, `flextable::set_caption()`
  - Requires: `requireNamespace("flextable", quietly = TRUE)` check

- `ggplot2` - Plot generation for all visualizations
  - Core to: `R/autoplot.R`, `R/plot-*.R` files
  - Provides: `autoplot()` generic methods for tidy response tables

## Time Series Integration

**tsibble Bridge:**
- `tsibble` (Optional) - Time series table conversion via `as_tsibble_post()` in `R/tsibble.R`
  - Maps: `horizon` or `time` columns as index, `model`/`variable`/`shock`/`draw` as keys
  - Requires: `requireNamespace("tsibble", quietly = TRUE)` check
  - Failure mode: Raises error if tsibble not installed when called

## Webhooks & Callbacks

**Incoming:**
- Not applicable

**Outgoing:**
- GitHub Pages deployment via pkgdown (automatic on push to main)
  - Deploys built documentation to `gh-pages` branch

## Native Symbol Integration

**bsvarSIGNs Native Bridge:**
- Location: `R/v2-utils.R`
- Purpose: Exposes native C++ routines from bsvarSIGNs that don't have R-level API
- Affects:
  - Representative-model scoring for `most_likely_admissible_*()`
  - Narrative restriction auditing
  - Zero-restriction weighting helpers in reconstructed sign score
- Mechanism: Resolves registered native symbols from loaded bsvarSIGNs DLL at runtime
- Maintenance note: Tightly coupled to bsvarSIGNs internals; if upstream changes native interface, this layer may need updates

## Data Format Bridges

**APRScenario Format Bridge:**
- Incoming: APRScenario-style tables with columns `hor`, `variable`, `lower`, `center`, `upper` → `tidy_apr_forecast()`
- Outgoing: bsvarPost forecast tables → `as_apr_cond_forc()` with APRScenario column schema
- Location: `R/aprscenario.R`
- Bidirectional conversion supports scenario analysis workflows

## Development & Documentation

**Package Documentation:**
- Tool: `pkgdown`
- Config: `_pkgdown.yml`
- URL: https://davidzenz.github.io/bsvarPost/
- Theme: Bootstrap 5 with Flatly color scheme
- Content: Two main articles (Getting Started, Post-Estimation Workflows) built from vignettes

---

*Integration audit: 2026-03-11*
