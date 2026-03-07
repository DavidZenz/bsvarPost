# bsvarPost 0.2.0

- Added representative-model selection helpers for IRFs and CDMs:
  `representative_irf()`, `representative_cdm()`, `median_target_*()`,
  and `most_likely_admissible_*()`.
- Added posterior hypothesis helpers: `hypothesis_irf()` and
  `hypothesis_cdm()`.
- Added audit helpers: `restriction_audit()` and `magnitude_audit()`.
- Added restriction constructor helpers for IRF, structural, and narrative
  audits.

# bsvarPost 0.1.0

- Initial release.
- Added cross-package `cdm()` support for posterior objects from `bsvars` and
  `bsvarSIGNs`.
- Added `PosteriorCDM` summary and plotting methods.
- Added tidy extractors for impulse responses, cumulative dynamic multipliers,
  variance decompositions, shocks, historical decompositions, and forecasts.
- Added comparison helpers for IRFs, CDMs, FEVDs, and forecasts.
- Added `ggplot2` autoplot support for tidy and comparison outputs.
- Added bridge helpers for APRScenario-style forecast tables.
- Added optional `tsibble` conversion for tidy outputs.
