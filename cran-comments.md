## Test environments

* macOS (arm64, Apple M), R 4.5.3 (2026-03-11), macOS Tahoe 26.3.1 -- local R CMD check --as-cran
* GitHub Actions: macOS/release, windows/release, ubuntu/devel, ubuntu/release, ubuntu/oldrel-1

## R CMD check results

0 errors | 1 warning | 3 notes

The local `R CMD check --as-cran` result is clean with respect to package code,
tests, documentation, and examples.

The remaining warning and notes are local environment issues:

- WARNING: `qpdf` is not installed locally, so PDF size reduction checks are skipped.
- NOTE: `unable to verify current time` because the local network time check is blocked.
- NOTE: HTML validation is skipped because the local `tidy` binary is not recent enough.
- NOTE: URL checks failed because this machine could not resolve external hosts during the check.

## Downstream dependencies

There are currently no downstream dependencies on bsvarPost.
