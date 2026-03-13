---
phase: 07-vignettes-multi-platform
plan: 04
subsystem: vignettes
tags: [vignette, hypothesis-testing, fiscal-policy, us_fiscal_lsuw, fixtures, bsvarPost, posterior-probability]

requires:
  - phase: 07-vignettes-multi-platform
    plan: 01
    provides: vignettes/fixtures/fiscal_post_bsvar.rds, vignettes/fixtures/fiscal_post_bsvar_alt.rds, figures/hypothesis-showcase.png

provides:
  - vignettes/hypothesis-testing.Rmd — third required vignette covering posterior hypothesis testing

affects:
  - CRAN submission — third vignette polished, completing hypothesis testing workflow coverage
  - pkgdown site — hypothesis testing narrative for all four required workflows

tech-stack:
  added: []
  patterns:
    - "Fixture-based vignette: readRDS() in hidden eval=TRUE setup chunk; no estimate() calls"
    - "joint_hypothesis_irf uses singular variable/shock — no plural deprecation shims for this function"
    - "magnitude_audit uses singular variable/shock — same pattern as joint_hypothesis_irf"
    - "hypothesis_irf/hypothesis_cdm/simultaneous_* use plural variables/shocks params"

key-files:
  created:
    - vignettes/hypothesis-testing.Rmd
  modified: []

key-decisions:
  - "joint_hypothesis_irf and magnitude_audit use singular variable/shock params — these functions do not have plural API variants"
  - "hypothesis_irf, hypothesis_cdm, simultaneous_irf, simultaneous_cdm use plural variables/shocks throughout"
  - "Line count 216 (slightly above 200 guideline) — full required content cannot fit in fewer lines without sacrificing clarity"

patterns-established:
  - "Hypothesis testing vignette scope: pointwise + joint + simultaneous + magnitude — the four pillars of bsvarPost posterior inference"

duration: 5min
completed: 2026-03-13
---

# Phase 7 Plan 04: Hypothesis Testing Vignette Summary

**216-line fiscal policy hypothesis testing narrative covering hypothesis_irf, joint_hypothesis_irf, simultaneous_irf/cdm, and magnitude_audit — the third required vignette completing the hypothesis testing workflow**

## Performance

- **Duration:** ~5 min
- **Started:** 2026-03-13T10:32:03Z
- **Completed:** 2026-03-13T10:36:56Z
- **Tasks:** 1
- **Files modified:** 1

## Accomplishments

- Created `vignettes/hypothesis-testing.Rmd` (216 lines) as the third required vignette
- Covers all four hypothesis testing functions: `hypothesis_irf()`, `hypothesis_cdm()`, `joint_hypothesis_irf()`, `simultaneous_irf()`, `simultaneous_cdm()`, `magnitude_audit()`
- Fixture-based: `readRDS()` loads both pre-computed posteriors; no `estimate()` calls anywhere
- Plural API (`variables =`, `shocks =`) used throughout `hypothesis_irf`, `hypothesis_cdm`, `simultaneous_irf`, `simultaneous_cdm`
- `hypothesis-showcase.png` embedded via `knitr::include_graphics()`
- Cross-model comparison section using both `post` and `post_alt` with `as_kable()` formatting
- Continues the `us_fiscal_lsuw` fiscal policy narrative (gs -> gdp): same economic question as vignettes 1 and 2

## Task Commits

1. **Task 1: Create Hypothesis Testing vignette with fiscal policy narrative** - `7de1338` (feat)

## Files Created/Modified

- `vignettes/hypothesis-testing.Rmd` - New: 216 lines, hypothesis testing narrative, fixture-based, six hypothesis functions demonstrated

## Decisions Made

- `joint_hypothesis_irf()` and `magnitude_audit()` use singular `variable`/`shock` params — these functions don't have plural API variants; using the correct API is required for correctness
- `hypothesis_irf()`, `hypothesis_cdm()`, `simultaneous_irf()`, `simultaneous_cdm()` use plural `variables`/`shocks` throughout
- Line count 216 (slightly above 200 guideline) — matches the precedent set by vignette 2 (224 lines) which was accepted; full required content warrants the length

## Deviations from Plan

**1. [Rule 1 - Bug] Singular params used for joint_hypothesis_irf and magnitude_audit**
- **Found during:** Task 1 - reading actual R source
- **Issue:** Plan specified "ALL parameter names must use plural forms" but `joint_hypothesis_irf()` and `magnitude_audit()` only accept singular `variable` and `shock` — no plural variants exist in those functions
- **Fix:** Used `variable = "gdp"` and `shock = "gs"` for `joint_hypothesis_irf()` and `magnitude_audit()`, plural `variables =` / `shocks =` for all other functions
- **Files modified:** vignettes/hypothesis-testing.Rmd
- **Commit:** 7de1338

## Issues Encountered

None - all hypothesis functions worked as documented in R source files.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Vignette 3 (hypothesis-testing.Rmd) complete, all three required vignettes now exist
- Plan 05 (WinBuilder / CRAN submission) is next
- All hypothesis testing workflow coverage complete per roadmap requirement

## Self-Check: PASSED

- FOUND: vignettes/hypothesis-testing.Rmd (216 lines)
- FOUND: VignetteIndexEntry{Hypothesis Testing in bsvarPost}
- FOUND: readRDS("fixtures/fiscal_post_bsvar.rds")
- FOUND: readRDS("fixtures/fiscal_post_bsvar_alt.rds")
- FOUND: 8x hypothesis_irf references
- FOUND: 3x joint_hypothesis references
- FOUND: 3x simultaneous_irf references
- FOUND: 5x magnitude_audit references
- FOUND: 6x variables = (plural API)
- FOUND: include_graphics("figures/hypothesis-showcase.png")
- FOUND: commit 7de1338 (Task 1)
