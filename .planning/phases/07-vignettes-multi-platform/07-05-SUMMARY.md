---
phase: 07-vignettes-multi-platform
plan: 05
subsystem: infra
tags: [R CMD check, CRAN, WinBuilder, .Rbuildignore, vignettes, validation]

# Dependency graph
requires:
  - phase: 07-vignettes-multi-platform
    provides: All 3 vignettes (getting-started, advanced, hypothesis-testing) with pre-built .rds fixtures
provides:
  - R CMD check passing locally: zero errors, zero vignette warnings, 1 NOTE (new submission), 1 WARNING (qpdf local env)
  - .Rbuildignore updated to exclude .planning/, .claude/, .git from CRAN tarball
  - All 941 tests passing
  - WinBuilder submission: deferred to Phase 8 (devtools not available in worktree environment)
affects:
  - 08-cran-submission: WinBuilder submission is Phase 8 prerequisite; DESCRIPTION maintainer email needed

# Tech tracking
tech-stack:
  added: []
  patterns:
    - R CMD check --as-cran with _R_CHECK_FORCE_SUGGESTS_=false for CRAN-realistic validation
    - KMP_DUPLICATE_LIB_OK=TRUE flag required for macOS arm64 OpenMP safety

key-files:
  created: []
  modified:
    - .Rbuildignore

key-decisions:
  - "Hidden dev directories (.planning, .claude, .git) must be in .Rbuildignore for CRAN tarball cleanliness — R CMD build does NOT auto-exclude hidden files"
  - "qpdf WARNING is local environment issue (tool not installed) — will not appear on CRAN servers"
  - "WinBuilder submission via devtools::check_win_devel() deferred to Phase 8 — devtools not available in worktree environment"
  - "R CMD check Status: 1 WARNING (qpdf), 1 NOTE (new submission) — both expected for CRAN first submission"

patterns-established:
  - "Always verify tarball contents (tar -tzf) after .Rbuildignore changes to confirm exclusions work"

# Metrics
duration: 15min
completed: 2026-03-13
---

# Phase 7 Plan 05: CRAN Validation Summary

**R CMD check passes with zero vignette errors (all 3 vignettes rebuild in 15s), 941 tests pass, .Rbuildignore fixed to exclude dev directories from CRAN tarball**

## Performance

- **Duration:** ~15 min
- **Started:** 2026-03-13T18:00:33Z
- **Completed:** 2026-03-13T18:15:00Z
- **Tasks:** 3 (2 fully executed, 1 deferred per plan fallback instructions)
- **Files modified:** 1 (.Rbuildignore)

## Accomplishments
- R CMD check --as-cran passes: zero errors, zero vignette-related warnings, all 941 tests pass
- All 3 vignettes rebuild from .rds fixtures in 15 seconds (well under 5-minute limit)
- .Rbuildignore fixed: added .planning/, .claude/, .git exclusions — hidden files note eliminated
- WinBuilder submission documented as Phase 8 prerequisite (devtools not available in worktree)

## Task Commits

Each task was committed atomically:

1. **Task 1: Verify .Rbuildignore and package structure** - `3dd80b5` (chore) — includes Rule 2 auto-fix for hidden directories
2. **Task 2: Run R CMD check** - validation only, no commit (no files modified; results documented in SUMMARY)
3. **Task 3: WinBuilder submission** - deferred to Phase 8 (devtools not installed)

**Plan metadata:** (docs: complete plan — see final commit)

## Files Created/Modified
- `.Rbuildignore` - Added exclusions for `.planning/`, `.claude/`, `.git/` directories

## Decisions Made
- Hidden directories `.planning`, `.claude`, `.git` need explicit .Rbuildignore entries — R CMD build does NOT auto-exclude hidden files/directories on macOS (only specific patterns like `.svn`, `.git` dir-type are excluded by default, but a `.git` worktree pointer file is included)
- `qpdf` WARNING is local environment only — qpdf tool not installed on this machine. CRAN check servers have qpdf installed, so this WARNING will not appear in the actual submission check
- WinBuilder deferred to Phase 8 per plan fallback instructions: "If devtools is not installed or check_win_devel fails, document the failure and note it as a Phase 8 prerequisite instead"

## R CMD Check Results

```
Status: 1 WARNING, 1 NOTE
```

**WARNING: 'qpdf' is needed for checks on size reduction of PDFs**
- Local environment issue: qpdf binary not installed on this machine
- CRAN servers have qpdf; this warning will not appear in actual submission
- Not a package issue

**NOTE: New submission**
- Expected for first-time CRAN packages
- Normal for all new package submissions

**All checks passed:**
- `checking for hidden files and directories ... OK` (after .Rbuildignore fix)
- `checking re-building of vignette outputs ... [15s/15s] OK`
- `checking tests ... [69s/67s] OK` (941 tests)
- `checking examples ... [16s/16s] OK`
- Zero errors
- Zero vignette-related warnings

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Added hidden directory exclusions to .Rbuildignore**
- **Found during:** Task 1 (Verify .Rbuildignore and package structure)
- **Issue:** `.planning/`, `.claude/`, and `.git` (worktree pointer file) were included in the package tarball. R CMD check reported NOTE: "Found the following hidden files and directories: .git, .claude, .planning". These development/infrastructure directories have no place in a CRAN package tarball.
- **Fix:** Added 6 patterns to .Rbuildignore: `^\.planning$`, `^\.planning/`, `^\.claude$`, `^\.claude/`, `^\.git$`, `^\.git/`
- **Files modified:** `.Rbuildignore`
- **Verification:** Rebuilt tarball, `tar -tzf bsvarPost_0.2.0.tar.gz | grep "^\."` returns empty. R CMD check shows `checking for hidden files and directories ... OK`
- **Committed in:** `3dd80b5` (Task 1 commit)

---

**Total deviations:** 1 auto-fixed (1 missing critical)
**Impact on plan:** Auto-fix essential for CRAN submission quality. Eliminates a NOTE that would appear on CRAN. No scope creep.

## Issues Encountered
- devtools package not available in worktree environment, preventing `devtools::check_win_devel()` submission. Per plan fallback instructions, this is documented as a Phase 8 prerequisite. The manual alternative: build tarball (`R CMD build .`) and upload to https://win-builder.r-project.org/upload.aspx

## Phase 8 Prerequisites

The following must be completed before or during Phase 8 (CRAN submission):

1. **WinBuilder R-devel submission** — Run `devtools::check_win_devel()` from a full R environment (not worktree) or manually upload tarball to https://win-builder.r-project.org/upload.aspx. Look for:
   - Zero ERRORs and zero WARNINGs
   - "Status: OK" or "Status: 1 NOTE" (new submission note is expected)
   - Vignette builds complete on Windows
   - .rds fixture loading paths resolve correctly on Windows

2. **Install qpdf** (optional) — `brew install qpdf` eliminates the local qpdf WARNING during local R CMD check runs

## Next Phase Readiness
- R CMD check locally clean (1 WARNING qpdf/env, 1 NOTE new-submission — both expected)
- All 3 vignettes build correctly from .rds fixtures in 15 seconds
- All 941 tests pass
- Package tarball clean (no dev directories)
- Phase 8 (CRAN submission) can proceed after WinBuilder validation

---
*Phase: 07-vignettes-multi-platform*
*Completed: 2026-03-13*
