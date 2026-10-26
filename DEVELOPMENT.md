# Development Notes

## Hardening checks

The GitHub check workflow includes the existing platform matrix, R 4.1
and release jobs without the optional integration packages, and an
instrumented test job with all optional integrations installed. Runtime
coverage is saved as an artifact. `release_qa_check()` checks
documentation, registrations and assets; it does not infer test coverage
from function names appearing in test files.

Run `tools/benchmark-hardening.R` against the installed development
build to compare selected-window array aggregation with full-sample
long-table aggregation. The script checks numerical equivalence and
records median elapsed time and allocated bytes for fixed fixtures.
Timings are evidence, not CI gates.

For the 1.1.0 hardening run (R 4.6.1, Apple Silicon, macOS 26.6.2),
medians over three iterations were:

| HD dimensions (variables, shocks, periods, draws) | Full-table event, seconds | Array-window event, seconds | Full-table allocated bytes | Array-window allocated bytes |
|----|---:|---:|---:|---:|
| 2, 2, 100, 100 | 0.641 | 0.005 | 73,573,632 | 421,216 |
| 2, 2, 100, 1,000 | 3.812 | 0.009 | 717,532,600 | 3,913,152 |
| 5, 5, 200, 100 | 5.924 | 0.027 | 925,548,696 | 4,491,152 |

Both paths used the same fixed draws and two-period window; summaries
matched. The reference intentionally calls `tidy_hd(draws = TRUE)`
before selecting the event. Allocations are cumulative bytes from
`Rprofmem`, not peak memory. The script also measures ordinary HD
summaries, grouped plots and representative selection. These
measurements compare two paths in the current code, rather than claiming
a package-wide speedup over a previous release.

When testing HD reconciliation with a tiny fitted posterior, account for
floating-point cancellation relative to component magnitudes: unfiltered
explosive VAR draws can be much larger than the observed series. Use
bounded constructed fixtures to verify the exact aggregation invariant
separately.

## bsvarSIGNs native bridge

`bsvarPost` depends on `bsvarSIGNs` for estimation, and part of the v0.2
post-estimation layer currently reuses native routines exposed by
`bsvarSIGNs`. This affects:

- representative-model scoring for `most_likely_admissible_*()`
- narrative restriction auditing
- zero-restriction weighting helpers used in the reconstructed sign
  score

The bridge lives in
[R/v2-utils.R](https://github.com/DavidZenz/bsvarPost/blob/main/R/v2-utils.R).
It resolves registered native symbols from the loaded `bsvarSIGNs` DLL
at runtime. For bsvarSIGNs 3.0 and later, the bridge converts upstream
log importance weights to the weight scale used by the existing
diagnostics and representative selection APIs. Version 2.0 uses the
original weight symbols. Symbol arity is checked before invocation, and
unknown interfaces produce versioned errors.

Why this exists: - `bsvarSIGNs` does not currently expose an R-level API
for these internals - reusing the upstream routines keeps the
post-estimation semantics aligned with the package that produced the
posterior object

Trade-off: - this creates tighter coupling to `bsvarSIGNs` internals
than the rest of the package - if upstream changes the native interface,
this layer may need to be updated

If `bsvarSIGNs` later exposes stable R wrappers for these operations,
`bsvarPost` should switch to those wrappers and remove the native
bridge.

## Before Pushing

Every feature is incomplete until both a clean local check and GitHub
Actions agree.

Minimum pre-push checklist:

1.  Regenerate docs:
    - `Rscript --vanilla -e 'roxygen2::roxygenise(".")'`
2.  Build the source tarball:
    - `R CMD build .`
3.  Run a clean local check:
    - `_R_CHECK_FORCE_SUGGESTS_=false R CMD check --as-cran bsvarPost_*.tar.gz`
4.  Run focused tests for the files or feature area you changed.
5.  Run the release QA contract check:
    - `Rscript --vanilla -e 'source("tools/release-qa.R"); release_qa_check(".")'`
6.  Review the staged diff:
    - make sure only the intended feature, tests, and docs are included
7.  Push the feature branch and require GitHub `R-CMD-check` to be green
    before merging or releasing.
8.  If you changed vignette/showcase visuals, verify that committed
    files under
    [vignettes/figures](https://github.com/DavidZenz/bsvarPost/tree/main/vignettes/figures)
    are only the images actually referenced by articles and README
    content.

Additional rules:

- Do not assume suggested packages are installed.
- Do not assume suggested packages are absent.
- Tests for optional dependencies must branch on
  [`requireNamespace(...)`](https://rdrr.io/r/base/ns-load.html).
- If a step depends on generated files, do not parallelize it. Run it
  after the generation step completes.
- If CI fails, inspect `00check.log` before changing code blindly.

## Pre-generated Figures and pkgdown Assets

The package intentionally versions a small set of pre-rendered PNGs used
by the pkgdown site and vignette prose.

Policy:

- The source of truth for figure calculations is the labeled `fig-*`
  chunks in the articles.
  [tools/render-vignette-figures.R](https://github.com/DavidZenz/bsvarPost/blob/main/tools/render-vignette-figures.R)
  executes those chunks and saves the resulting plots.
- Only commit figures that are actually referenced by:
  - vignettes under
    [vignettes](https://github.com/DavidZenz/bsvarPost/tree/main/vignettes)
  - the package README
- Pre-generated figures are documentation assets, not CRAN validation
  artifacts.
- Do not keep unused generated files in the repository.
- Do not treat figure regeneration as part of the minimum CRAN check
  path unless the code or vignette text that produces them changed.

Operational rules:

- Keep the renderer deterministic.
- Keep fixture sizes modest and stable.
- Regenerate only the affected figures when plot code or article usage
  changes.
- Ignore or remove local render leftovers such as:
  - `Rplots.pdf`
  - unused showcase images
  - editor swap files

There is a helper script for the local portion of this checklist:

- `tools/prepush-check.sh`

## CI Gotchas

The following issues already occurred in this repository and should be
treated as known failure modes.

### `check-r-package` workflow inputs must be valid R expressions

`r-lib/actions/check-r-package@v2` does not parse shell-style flags.
Inputs like

- `args: --no-manual --as-cran`

are wrong. They get injected into R code and can fail with opaque errors
such as:

- `object 'no' not found`

Use quoted R expressions instead, for example:

- `args: 'c("--as-cran", "--no-manual")'`
- `build_args: 'character()'`

### Optional-dependency tests must support both branches

Tests for `tsibble`, `APRScenario`, and other suggested packages must
not assume either presence or absence. CI may install a suggested
package even if the local machine does not.

Pattern to use:

- if the package is installed, test the successful path
- otherwise, test the clean failure path

### `tsibble::as_tsibble()` does not accept `regular = NULL`

Do not forward `regular = NULL` directly to
[`tsibble::as_tsibble()`](https://tsibble.tidyverts.org/reference/as-tsibble.html).
Only pass `regular` when the caller explicitly supplies it.

### S3 roxygen blocks must share the correct `@rdname`

If a generic has documented arguments and the methods add
method-specific arguments, the generated Rd file can fail `R CMD check`
unless the methods are properly tied to the same `@rdname`.

This already affected:

- [`acceptance_diagnostics()`](https://davidzenz.github.io/bsvarPost/reference/acceptance_diagnostics.md)
- [`peak_response()`](https://davidzenz.github.io/bsvarPost/reference/peak_response.md)
- [`duration_response()`](https://davidzenz.github.io/bsvarPost/reference/duration_response.md)
- [`half_life_response()`](https://davidzenz.github.io/bsvarPost/reference/half_life_response.md)
- [`time_to_threshold()`](https://davidzenz.github.io/bsvarPost/reference/time_to_threshold.md)
- [`simultaneous_irf()`](https://davidzenz.github.io/bsvarPost/reference/simultaneous_irf.md)
- [`simultaneous_cdm()`](https://davidzenz.github.io/bsvarPost/reference/simultaneous_cdm.md)
- [`tidy_hd_event()`](https://davidzenz.github.io/bsvarPost/reference/tidy_hd_event.md)

When adding or changing S3 methods, always rerun roxygen and then
inspect the generated `\usage` sections if CI reports Rd mismatches.

### Upload the real check logs

The workflow should always expose:

- `check/**/00check.log`
- `check/**/00install.out`

If CI fails and the Actions page is vague, these files are the source of
truth.

### `aes_string()` is still deprecated

This currently shows up as a warning in CI, not an error. It should
still be treated as technical debt and replaced with tidy-eval `aes()`
usage in the plotting layer when that code is touched again.

## Reproducible documentation checks

The homepage is built from README.md; do not add an overriding index.md.
Analysis setup must be visible. Every article loads installed extdata
assets with system.file(…, mustWork = TRUE), so exported scripts work
outside the checkout. Only knitr formatting and include_graphics chunks
use purl = FALSE. Installation and estimation recipes have explicit,
non-rendered documentation-skip HTML comments; analysis chunks must
remain evaluated and included in exported scripts. The checker rejects
unmarked eval = FALSE analysis instead of running a second copy of every
vignette.

Installed demo assets are generated by tools/build-demo-fixtures.R.
Existing frozen inputs are reused unless –refresh-inputs is supplied.
The four fits contain 200 draws; CSV metadata records seeds, sample
ranges, transformations, versions and asset checksums. Regenerating
fixtures requires reinstalling before running documentation checks or
rendering figures. Input updates and resulting numerical changes must be
reviewed together.

After changing an article’s analysis or figure code:

1.  Install the package to make the checkout’s extdata assets available.
2.  Run Rscript –vanilla tools/render-vignette-figures.R, optionally
    with PNG basenames to regenerate only affected figures. QA verifies
    declared recipes, references and missing/unused assets. Regenerate
    affected figures when their calculations change and review them
    visually; formatting changes do not require regeneration.
3.  Run Rscript –vanilla tools/test-doc-qa.R and Rscript –vanilla
    tools/check-documentation.R (README and static checks).
4.  Build and install the source tarball with vignettes, build pkgdown,
    then run Rscript –vanilla tools/check-documentation.R
    –installed-docs –site=docs.
5.  Inspect changed figures and the homepage visually. Do not use
    byte-identical image comparisons across rendering platforms as a CI
    requirement.

Documentation CI builds a reviewable site artifact for PRs. A separate
job with write permission deploys only main. The R 4.1
minimal-dependency job pins bsvars 3.2 and bsvarSIGNs 2.0 and
smoke-tests installed demo assets; release tests use current
dependencies. HTML QA checks local files/fragments and maps canonical
package-site links to the built site. Third-party web availability is
not a CI gate.

## Focused test boundaries

Use bounded arrays or small tables for numerical contracts and ggplot
inputs for styling. Fit models where the test crosses an upstream
integration boundary. The HD plot integration test uses 24 observations
and five draws; the full historical sample is unnecessary for its
baseline and observed-data checks. Timings are measured before/after
under matching dependencies, never CI gates.

The test reduction retains these contracts:

| Removed repetition | Retained coverage |
|----|----|
| Vignette-source re-execution and example-specific variable/row-count assertions | Tarball/pkgdown rendering, one fresh session per installed script, README smoke; numerical and CSV contracts in tinytest |
| Cumulative figure/image checksum gates and immediate-chunk placement | Shared labeled figure recipes, per-article mapping, missing/unused assets, visual review; fixture integrity checksums remain |
| Full-sample fits and repeated HD event summaries in plot variants | Bounded-array plots/events; one small fitted-model test for baseline, observed data and stacked plots; hardening tests for grouping and array/table equivalence |
| Exact baseline grey colour | Baseline component inclusion/exclusion and rendering |
| Mixed test_utils_coverage.R smoke assertions | Styling behavior in test_plot_style.R; table type, labels, horizons and names in API/tidy/identity tests; distinct plots and end-to-end pipeline remain |
| test_plot_template_annotation.R fits and class-only checks | Palette, ribbon alpha, labels, legend placement, reference lines, highlighted-window bounds and invalid-input checks in test_plot_style.R |
| Upstream ggplot/tibble inheritance details | Public bsvar_post_tbl contract and successful builds of supported plot implementations |

Keep the regression tests for aggregation before quantiles,
simultaneous-band coverage, model/draw identity, provenance, native
interfaces and optional integrations. Consolidating smoke checks is not
a reason to remove those tests. Documentation fault tests cover
undefined objects, skipped analysis, missing fixtures, broken
links/fragments, hidden analysis and unmapped figures.

Measured on the same Apple Silicon host with R 4.6.1, bsvars 4.0 and
bsvarSIGNs 3.0, before/after summed tinytest file timings were:

| Metric        | Before |  After |
|---------------|-------:|-------:|
| Full suite    | 75.0 s | 37.7 s |
| HD plot tests | 34.8 s |  2.2 s |
| Test files    |     42 |     40 |
| Test results  |    562 |    544 |

The baseline used the previously installed suite; the after run came
from the clean source-tarball package check. Both passed. Counts
describe the reduction; they are not coverage or performance
requirements.
