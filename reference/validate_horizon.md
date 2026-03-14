# Validate a horizon parameter

Check that `horizon` is a single non-negative (or positive) integer
value.

## Usage

``` r
validate_horizon(horizon, arg_name = "horizon", allow_zero = TRUE)
```

## Arguments

- horizon:

  Value to validate.

- arg_name:

  Name of the argument for error messages.

- allow_zero:

  If `TRUE` (default), zero is a valid value. If `FALSE`, the horizon
  must be strictly positive.

## Value

`as.integer(horizon)` if valid.
