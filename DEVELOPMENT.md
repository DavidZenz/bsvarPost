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
