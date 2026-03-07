# bsvarPost Roadmap

`bsvarPost` should stay a post-estimation companion package for `bsvars` and
`bsvarSIGNs`.

That means the package should focus on:

- extraction
- summarization
- diagnostics
- comparison
- reporting
- hypothesis evaluation

It should not try to become a second estimation package.

## Scope boundary

Good fits for `bsvarPost`:

- posterior summaries
- representative-model summaries
- restriction diagnostics
- historical decomposition summaries
- model comparison
- plotting/reporting helpers

Bad fits for `bsvarPost`:

- new MCMC samplers
- estimation-time identification algorithms
- new structural identification schemes implemented inside estimation
- magnitude restrictions as admissibility filters during estimation

Those belong in `bsvars` / `bsvarSIGNs`.

## v0.1

Status: implemented

Core package scope:

- `cdm()` for posterior objects from `bsvars` and `bsvarSIGNs`
- `PosteriorCDM` summary and plotting methods
- tidy extractors:
  - `tidy_irf()`
  - `tidy_cdm()`
  - `tidy_fevd()`
  - `tidy_shocks()`
  - `tidy_hd()`
  - `tidy_forecast()`
- comparison helpers:
  - `compare_irf()`
  - `compare_cdm()`
  - `compare_fevd()`
  - `compare_forecast()`
- `ggplot2` plotting via `autoplot()` for tidy outputs
- bridge helpers:
  - `as_apr_cond_forc()`
  - `tidy_apr_forecast()`
  - `apr_gen_mats()`
- optional `tsibble` conversion via `as_tsibble_post()`

## v0.2

Priority: highest

### 1. `median_target()`

Representative-model summaries for sign-restricted settings.

Planned functions:

- `median_target_irf()`
- `median_target_cdm()`
- `plot_median_target()`

Goal:

- choose a single posterior draw / structural model closest to posterior median
  IRFs or CDMs
- provide a coherent alternative to pointwise median summaries in
  sign-restricted settings

### 2. `restriction_audit()`

Posterior evaluation of sign, zero, ranking, and narrative-style restrictions.

Planned capabilities:

- posterior probability that a sign restriction holds
- posterior probability that a zero or near-zero restriction holds
- posterior probability that ranking conditions hold
- event-window summaries for narrative-style conditions

Goal:

- make restrictions inspectable as posterior objects rather than hidden inside
  estimation choices

### 3. `magnitude_audit()`

Posterior evaluation of threshold and relative-size conditions.

Planned capabilities:

- `P(IRF > c)`
- `P(CDM < c)`
- `P(abs(response_A) > abs(response_B))`
- event-window magnitude checks for historical decompositions or shocks

Important boundary:

- magnitude restrictions are treated as post-estimation audits in `bsvarPost`
- estimation-time magnitude restrictions do not belong here

### 4. `hypothesis_irf()` and `hypothesis_cdm()`

General posterior inequality engine.

Examples:

- `P(IRF[y, shock, h] < 0)`
- `P(CDM[y, shock, h] > 1)`
- `P(response_A > response_B)`

Goal:

- provide a compact API underlying both restriction and magnitude audits

## v0.3

Priority: high

### 5. `tidy_hd_event()`

Event-window summaries for historical decompositions.

Planned capabilities:

- cumulative contribution by shock over a user-defined window
- absolute contribution shares
- tidy event tables ready for reporting

### 6. `shock_ranking()`

Ranking of structural shocks by contribution.

Planned capabilities:

- largest positive contributor
- largest negative contributor
- absolute ranking by event or full sample window
- optional normalization by total contribution

### 7. `autoplot_event_hd()` and `autoplot_shock_ranking()`

Publication-ready plots for event decomposition summaries.

Goal:

- make the historical-decomposition side of the package as usable as IRF/CDM
  workflows

## v0.4

Priority: medium

### 8. `peak_response()` and `duration_response()`

Applied summaries for dynamic responses.

Planned capabilities:

- peak magnitude
- horizon of peak
- sign duration
- half-life
- time to threshold

Goal:

- remove the need for users to hand-code common paper tables from IRFs/CDMs

### 9. `compare_restrictions()`

Comparison across identification schemes or restriction sets.

Examples:

- baseline sign restrictions vs narrative restrictions
- unrestricted vs restricted identification
- two alternative sign matrices for the same model

Goal:

- make identification choices easier to compare systematically

## v0.5

Priority: medium to advanced

### 10. `acceptance_diagnostics()` for `bsvarSIGNs`

Diagnostics focused on admissible-set behavior.

Planned capabilities:

- acceptance / rejection summaries
- binding-frequency summaries by restriction
- warnings for weakly informative or sparse admissible sets

### 11. joint inference helpers

Possible functions:

- simultaneous bands for IRFs/CDMs
- multi-horizon posterior probability summaries
- joint restriction probabilities across several variables and horizons

Goal:

- support more rigorous post-estimation inference for identified sets

## Implementation order

Recommended next implementation order:

1. `median_target_irf()` / `median_target_cdm()`
2. `hypothesis_irf()` / `hypothesis_cdm()`
3. `restriction_audit()`
4. `magnitude_audit()`
5. `tidy_hd_event()`
6. `shock_ranking()`
7. `peak_response()` / `duration_response()`
8. `compare_restrictions()`
9. `acceptance_diagnostics()`
10. joint inference helpers

## Design principles

- keep one coherent API across `bsvars` and `bsvarSIGNs`
- return tidy outputs whenever possible
- make diagnostics explicit and inspectable
- keep normalization and interpretation choices opt-in
- do not duplicate estimation logic from upstream packages
- prefer reusable internal engines over one-off wrappers

## Notes on magnitude restrictions

Magnitude restrictions are worth supporting in `bsvarPost`, but only in the
following sense:

- as posterior probability statements
- as threshold audits
- as relative-magnitude comparisons
- as event-window contribution checks

They should not be implemented as estimation-time admissibility filters in this
package.
