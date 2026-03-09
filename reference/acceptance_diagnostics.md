# Acceptance and admissibility diagnostics for bsvarSIGNs

Summarise stored-draw diagnostics for sign-restricted posterior objects.
These diagnostics do not reconstruct the full proposal/rejection history
of the sampler. Instead, they report what can be recovered from the
saved posterior state, identification pattern, and admissibility
weights.

## Usage

``` r
acceptance_diagnostics(object, ...)

# S3 method for class 'PosteriorBSVARSIGN'
acceptance_diagnostics(
  object,
  kernel_tol = 1e-12,
  ess_threshold = 20,
  sparse_threshold = 0.1,
  model = "model1",
  ...
)

# Default S3 method
acceptance_diagnostics(object, ...)
```

## Arguments

- object:

  A `PosteriorBSVARSIGN` object.

- ...:

  Reserved for future extensions.

- kernel_tol:

  Numerical tolerance used to classify near-zero admissibility weights.

- ess_threshold:

  Effective-sample-size threshold below which a warning flag is raised.

- sparse_threshold:

  Share of near-zero admissibility weights above which a sparse-support
  warning flag is raised.

- model:

  Optional model identifier.
