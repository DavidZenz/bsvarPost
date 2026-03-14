# Resolve horizon to a validated integer, defaulting to 20

Converts NULL to the default horizon (20 periods, following the
econometric convention of covering business cycle dynamics). Non-NULL
values are validated via
[`validate_horizon()`](https://davidzenz.github.io/bsvarPost/reference/validate_horizon.md).

## Usage

``` r
resolve_horizon(horizon, default = 20L, arg_name = "horizon")
```

## Arguments

- horizon:

  Horizon value to resolve (NULL or numeric).

- default:

  Default integer horizon when `horizon` is NULL. Defaults to `20L`
  (econometric convention covering business cycle dynamics).

- arg_name:

  Name of the argument for error messages.

## Value

`as.integer(default)` if `horizon` is NULL; otherwise
`validate_horizon(horizon, arg_name)` which returns
`as.integer(horizon)`.
