# Audit sign, zero, structural, and narrative restrictions

Audit sign, zero, structural, and narrative restrictions

## Usage

``` r
restriction_audit(
  object,
  restrictions = NULL,
  zero_tol = 1e-08,
  probability = 0.68,
  model = "model1",
  ...
)
```

## Arguments

- object:

  A posterior model object.

- restrictions:

  Optional list of restriction helper objects. If omitted for
  `PosteriorBSVARSIGN`, restrictions are extracted from the fitted
  identification scheme.

- zero_tol:

  Numerical tolerance for zero restrictions.

- probability:

  Equal-tailed interval probability used in summaries.

- model:

  Optional model identifier.

- ...:

  Reserved for future extensions.
