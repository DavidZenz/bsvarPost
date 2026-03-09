# Compare acceptance diagnostics across models

Compare acceptance diagnostics across models

## Usage

``` r
compare_acceptance_diagnostics(
  ...,
  kernel_tol = 1e-12,
  ess_threshold = 20,
  sparse_threshold = 0.1
)
```

## Arguments

- ...:

  Posterior model objects or a named list of model objects.

- kernel_tol:

  Numerical tolerance used to classify near-zero admissibility weights.

- ess_threshold:

  Effective-sample-size threshold below which a warning flag is raised.

- sparse_threshold:

  Share of near-zero admissibility weights above which a sparse-support
  warning flag is raised.
