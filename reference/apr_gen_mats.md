# Optional wrapper around APRScenario::gen_mats

Optional wrapper around APRScenario::gen_mats

## Usage

``` r
apr_gen_mats(posterior = NULL, specification = NULL, max_cores = 1)
```

## Arguments

- posterior:

  A posterior model object.

- specification:

  The corresponding specification object.

- max_cores:

  Passed to
  [`APRScenario::gen_mats()`](https://rdrr.io/pkg/APRScenario/man/gen_mats.html).

## Value

The result of
[`APRScenario::gen_mats()`](https://rdrr.io/pkg/APRScenario/man/gen_mats.html),
typically a list containing matrices used for conditional forecasting.

## Examples

``` r
if (FALSE) { # \dontrun{
# Requires APRScenario package
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
mats <- apr_gen_mats(posterior = post, specification = spec)
} # }
```
