# Create an impulse-response restriction specification

Create an impulse-response restriction specification

## Usage

``` r
irf_restriction(variable, shock, horizon, sign = NULL, zero = FALSE)
```

## Arguments

- variable:

  Response variable.

- shock:

  Shock.

- horizon:

  Horizon.

- sign:

  Optional sign restriction, typically `1` or `-1`.

- zero:

  If `TRUE`, treat the restriction as a zero restriction.
