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
5. Run the release QA contract check:
   - `Rscript --vanilla -e 'source("tools/release-qa.R"); release_qa_check(".")'`
6. Review the staged diff:
   - make sure only the intended feature, tests, and docs are included
7. Push only after GitHub `R-CMD-check` is green.

Additional rules:

- Do not assume suggested packages are installed.
- Do not assume suggested packages are absent.
- Tests for optional dependencies must branch on `requireNamespace(...)`.
- If a step depends on generated files, do not parallelize it. Run it after the
  generation step completes.
- If CI fails, inspect `00check.log` before changing code blindly.

There is a helper script for the local portion of this checklist:

- `tools/prepush-check.sh`

## CI Gotchas

The following issues already occurred in this repository and should be treated
as known failure modes.

### `check-r-package` workflow inputs must be valid R expressions

`r-lib/actions/check-r-package@v2` does not parse shell-style flags. Inputs like

- `args: --no-manual --as-cran`

are wrong. They get injected into R code and can fail with opaque errors such
as:

- `object 'no' not found`

Use quoted R expressions instead, for example:

- `args: 'c("--as-cran", "--no-manual")'`
- `build_args: 'character()'`

### Optional-dependency tests must support both branches

Tests for `tsibble`, `APRScenario`, and other suggested packages must not assume
either presence or absence. CI may install a suggested package even if the local
machine does not.

Pattern to use:

- if the package is installed, test the successful path
- otherwise, test the clean failure path

### `tsibble::as_tsibble()` does not accept `regular = NULL`

Do not forward `regular = NULL` directly to `tsibble::as_tsibble()`. Only pass
`regular` when the caller explicitly supplies it.

### S3 roxygen blocks must share the correct `@rdname`

If a generic has documented arguments and the methods add method-specific
arguments, the generated Rd file can fail `R CMD check` unless the methods are
properly tied to the same `@rdname`.

This already affected:

- `acceptance_diagnostics()`
- `peak_response()`
- `duration_response()`
- `half_life_response()`
- `time_to_threshold()`
- `simultaneous_irf()`
- `simultaneous_cdm()`
- `tidy_hd_event()`

When adding or changing S3 methods, always rerun roxygen and then inspect the
generated `\usage` sections if CI reports Rd mismatches.

### Upload the real check logs

The workflow should always expose:

- `check/**/00check.log`
- `check/**/00install.out`

If CI fails and the Actions page is vague, these files are the source of truth.

### `aes_string()` is still deprecated

This currently shows up as a warning in CI, not an error. It should still be
treated as technical debt and replaced with tidy-eval `aes()` usage in the
plotting layer when that code is touched again.
