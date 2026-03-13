## Test environments

* macOS (arm64, Apple M), R 4.5.3 (2026-03-11), macOS Tahoe 26.3.1 -- local R CMD check --as-cran
* GitHub Actions: macOS/release, windows/release, ubuntu/devel, ubuntu/release, ubuntu/oldrel-1
* WinBuilder (R-devel): tarball submitted for cross-platform validation;
  results pending at office@davidzenz.com (~30 min)

## R CMD check results

0 errors | 0 warnings | 1 note

NOTE: New submission

This is the first CRAN submission of bsvarPost. The "New submission" NOTE
is expected for first-time packages.

Additional local-environment NOTEs (not package issues, will not appear on CRAN servers):
- "unable to verify current time" — network time check blocked locally
- "qpdf WARNING" — qpdf binary not installed locally (PDF size check)
- "Skipping checking HTML validation: 'tidy' doesn't look like recent enough HTML Tidy" — local tidy version

## Downstream dependencies

There are currently no downstream dependencies on bsvarPost.
