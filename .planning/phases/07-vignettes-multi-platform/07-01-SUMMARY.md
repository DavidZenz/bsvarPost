---
phase: 07-vignettes-multi-platform
plan: 01
subsystem: infra
tags: [rds, fixtures, vignettes, ci, github-actions, r-lib-actions, bsvars, bsvarPost]

requires:
  - phase: 06-api-consistency-error-messages
    provides: plural API params (variables/shocks), updated defaults (horizon=NULL->20, prob=0.90)

provides:
  - vignettes/fixtures/fiscal_post_bsvar.rds — pre-computed posterior for p=1 model
  - vignettes/fixtures/fiscal_post_bsvar_alt.rds — pre-computed posterior for p=3 model
  - vignettes/figures/*.png (6 files) — showcase figures with updated API
  - .github/workflows/R-CMD-check.yaml — 5-platform CI matrix

affects:
  - 07-02 and later plans — vignettes that readRDS() these fixtures
  - 07-05 — WinBuilder submission relies on same matrix strategy understanding

tech-stack:
  added: []
  patterns:
    - "Fixture pattern: saveRDS with compress=xz, ~90-120KB per posterior at S=200"
    - "CI matrix: r-lib/actions v2 standard 5-config pattern (macos/release, windows/release, ubuntu/devel, ubuntu/release, ubuntu/oldrel-1)"
    - "Pandoc step required before setup-r in workflow for vignette Rmd rendering"
    - "macOS OpenMP: KMP_DUPLICATE_LIB_OK=TRUE at script top prevents crash"

key-files:
  created:
    - vignettes/fixtures/fiscal_post_bsvar.rds
    - vignettes/fixtures/fiscal_post_bsvar_alt.rds
    - vignettes/figures/hypothesis-showcase.png
  modified:
    - tools/render-vignette-figures.R
    - vignettes/figures/cdm-showcase.png
    - vignettes/figures/compare-irf-showcase.png
    - vignettes/figures/representative-showcase.png
    - vignettes/figures/diagnostics-showcase.png
    - vignettes/figures/hd-event-showcase.png
    - .github/workflows/R-CMD-check.yaml

key-decisions:
  - "Fixture seed convention: fiscal_post_bsvar uses seed=123, fiscal_post_bsvar_alt uses seed=456"
  - "Fixture draw count: S=200, thin=1 for vignette fixtures (vs S=5 for test fixtures) — balances representativeness vs file size"
  - "CI R-devel on ubuntu only — macOS/R-devel not standard (slow/flaky); Windows/R-devel via WinBuilder in Plan 05"
  - "setup-pandoc placed before setup-r — required for vignette Rmd rendering on Windows/macOS"
  - "Artifact names include matrix config (os-r) to avoid collision across parallel matrix jobs"
  - "bsvarSIGNs diagnostics/hd-event figures still use live estimation (need PosteriorBSVARSIGN object)"

patterns-established:
  - "Fixture pattern: vignettes/fixtures/*.rds loaded via readRDS() at vignette top, never re-estimated in vignette"
  - "Figure generation: .save_base() for base R plots, .save_gg() for ggplot2 objects"

duration: 2min
completed: 2026-03-13
---

# Phase 7 Plan 01: Fixtures, Figures, and CI Matrix Summary

**Pre-computed .rds posterior fixtures (211KB total) and 6 showcase PNGs with updated API, plus 5-platform r-lib/actions CI matrix with pandoc step**

## Performance

- **Duration:** ~2 min
- **Started:** 2026-03-13T10:17:49Z
- **Completed:** 2026-03-13T10:19:37Z
- **Tasks:** 2
- **Files modified:** 11 (1 script, 2 new fixtures, 6 figures regenerated + 1 new, 1 CI workflow)

## Accomplishments

- Created `vignettes/fixtures/` with two pre-computed .rds posteriors (211KB total, well under 3MB limit), enabling vignettes to use `readRDS()` instead of `estimate()` during `R CMD check`
- Regenerated all 5 existing showcase figures with updated plural API params (`baseline=`/`alternative=`, `variables=`, `shocks=`) and `horizon=20` default, and added new `hypothesis-showcase.png`
- Expanded CI from single-ubuntu to standard r-lib/actions 5-platform matrix with `fail-fast: false`, `setup-pandoc`, and `_R_CHECK_FORCE_SUGGESTS_: false`

## Task Commits

1. **Task 1: Update fixture generation script and generate .rds fixtures + figures** - `5ec987e` (feat)
2. **Task 2: Expand CI workflow to 5-platform matrix** - `09fb36b` (feat)

## Files Created/Modified

- `tools/render-vignette-figures.R` - Rewritten: macOS OpenMP workaround, fixture generation with saveRDS/xz, updated API calls, hypothesis-showcase block
- `vignettes/fixtures/fiscal_post_bsvar.rds` - p=1, S=200, seed=123, 90KB
- `vignettes/fixtures/fiscal_post_bsvar_alt.rds` - p=3, S=200, seed=456, 120KB
- `vignettes/figures/cdm-showcase.png` - Regenerated with horizon=20
- `vignettes/figures/compare-irf-showcase.png` - Regenerated with baseline=/alternative= params
- `vignettes/figures/representative-showcase.png` - Regenerated with horizon=20
- `vignettes/figures/diagnostics-showcase.png` - Regenerated with S=200
- `vignettes/figures/hd-event-showcase.png` - Regenerated
- `vignettes/figures/hypothesis-showcase.png` - New: plot_hypothesis on fiscal model, irf type, horizon 0:20
- `.github/workflows/R-CMD-check.yaml` - 5-platform matrix, setup-pandoc, env vars, matrix-tagged artifacts

## Decisions Made

- Fixture seeds 123/456 for primary/alternative posteriors — reproducible, memorable
- S=200 for vignette fixtures vs S=5 for unit tests — vignettes need plausible-looking posterior draws
- R-devel CI runs on ubuntu only per community standard — macOS/R-devel omitted (flaky); Windows/R-devel via WinBuilder (Plan 05)
- `setup-pandoc` placed before `setup-r` — required order for Rmd rendering to work on Windows/macOS
- Artifact names include `${{ matrix.config.os }}-${{ matrix.config.r }}` to avoid upload collisions

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None - script ran cleanly on first attempt. Warning "Using alpha for a discrete variable is not advised" from ggplot2 is a pre-existing cosmetic warning from the bsvarSIGNs plot, not a regression.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Fixtures ready for vignette `readRDS()` calls in Plans 02-04
- CI matrix ready for multi-platform validation
- All 6 showcase figures regenerated for embedding in vignette prose
- Blocker removed: vignettes can now run `R CMD check --no-rebuild-vignettes` using pre-computed fixtures

## Self-Check: PASSED

- FOUND: vignettes/fixtures/fiscal_post_bsvar.rds
- FOUND: vignettes/fixtures/fiscal_post_bsvar_alt.rds
- FOUND: vignettes/figures/hypothesis-showcase.png
- FOUND: .github/workflows/R-CMD-check.yaml
- FOUND: commit 5ec987e (Task 1)
- FOUND: commit 09fb36b (Task 2)
