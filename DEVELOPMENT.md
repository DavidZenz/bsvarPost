# Development Notes

## bsvarSIGNs native bridge

`bsvarPost` depends on `bsvarSIGNs` for estimation, and part of the v0.2
post-estimation layer currently reuses native routines exposed by `bsvarSIGNs`.
This affects:

- representative-model scoring for `most_likely_admissible_*()`
- narrative restriction auditing
- zero-restriction weighting helpers used in the reconstructed sign score

The bridge lives in [R/v2-utils.R](R/v2-utils.R). It resolves registered native
symbols from the loaded `bsvarSIGNs` DLL at runtime.

Why this exists:
- `bsvarSIGNs` does not currently expose an R-level API for these internals
- reusing the upstream routines keeps the post-estimation semantics aligned with
  the package that produced the posterior object

Trade-off:
- this creates tighter coupling to `bsvarSIGNs` internals than the rest of the
  package
- if upstream changes the native interface, this layer may need to be updated

If `bsvarSIGNs` later exposes stable R wrappers for these operations, `bsvarPost`
should switch to those wrappers and remove the native bridge.

## Before Pushing

Every feature is incomplete until both a clean local check and GitHub Actions
agree.

Minimum pre-push checklist:

1. Regenerate docs:
   - `Rscript --vanilla -e 'roxygen2::roxygenise(".")'`
2. Build the source tarball:
   - `R CMD build .`
3. Run a clean local check:
   - `_R_CHECK_FORCE_SUGGESTS_=false R CMD check --as-cran bsvarPost_*.tar.gz`
4. Run focused tests for the files or feature area you changed.
5. Review the staged diff:
   - make sure only the intended feature, tests, and docs are included
6. Push only after GitHub `R-CMD-check` is green.

Additional rules:

- Do not assume suggested packages are installed.
- Do not assume suggested packages are absent.
- Tests for optional dependencies must branch on `requireNamespace(...)`.
- If a step depends on generated files, do not parallelize it. Run it after the
  generation step completes.
- If CI fails, inspect `00check.log` before changing code blindly.

There is a helper script for the local portion of this checklist:

- `tools/prepush-check.sh`
