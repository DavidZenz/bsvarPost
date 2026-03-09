# Compare restriction audits across models

Compare restriction audits across models

## Usage

``` r
compare_restrictions(
  ...,
  restrictions = NULL,
  zero_tol = 1e-08,
  probability = 0.68
)
```

## Arguments

- ...:

  Posterior model objects or a named list of model objects.

- restrictions:

  Optional list of restriction helper objects applied to each model.

- zero_tol:

  Numerical tolerance for zero restrictions.

- probability:

  Equal-tailed interval probability used in summaries.
