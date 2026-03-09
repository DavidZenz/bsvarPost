# Create a narrative restriction specification

Create a narrative restriction specification

## Usage

``` r
narrative_restriction(
  start,
  periods = 1,
  type = c("S", "A", "B"),
  sign = 1,
  shock = 1,
  var = NA
)
```

## Arguments

- start:

  Start period index used by upstream `bsvarSIGNs` semantics.

- periods:

  Number of constrained periods.

- type:

  Narrative restriction type: `"S"`, `"A"`, or `"B"`.

- sign:

  Sign direction, `1` or `-1`.

- shock:

  Shock index.

- var:

  Variable index for `"A"` and `"B"` restrictions.
