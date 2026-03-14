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

## Value

A `bsvar_post_tbl` combining acceptance diagnostic results across
models, with a `model` column identifying each input.

## Examples

``` r
# \donttest{
data(optimism, package = "bsvarSIGNs")
sign_irf <- matrix(c(1, rep(NA, 3)), 2, 2)
spec_s <- suppressMessages(
  bsvarSIGNs::specify_bsvarSIGN$new(optimism[, 1:2], p = 1,
                                     sign_irf = sign_irf)
)
post_s1 <- bsvars::estimate(spec_s, S = 5, show_progress = FALSE)
post_s2 <- bsvars::estimate(spec_s, S = 5, show_progress = FALSE)

comp <- compare_acceptance_diagnostics(m1 = post_s1, m2 = post_s2)
print(comp)
#> # A tibble: 26 × 6
#>    model object_type            metric                       value flag  message
#>    <chr> <chr>                  <chr>                        <dbl> <lgl> <chr>  
#>  1 m1    acceptance_diagnostics posterior_draws                  5 FALSE ""     
#>  2 m1    acceptance_diagnostics effective_sample_size            5 TRUE  "ESS b…
#>  3 m1    acceptance_diagnostics max_tries                      Inf FALSE ""     
#>  4 m1    acceptance_diagnostics irf_sign_restrictions            1 FALSE ""     
#>  5 m1    acceptance_diagnostics zero_restrictions                0 FALSE ""     
#>  6 m1    acceptance_diagnostics structural_sign_restrictions     0 FALSE ""     
#>  7 m1    acceptance_diagnostics narrative_restrictions           0 FALSE ""     
#>  8 m1    acceptance_diagnostics kernel_mean                      1 FALSE ""     
#>  9 m1    acceptance_diagnostics kernel_median                    1 FALSE ""     
#> 10 m1    acceptance_diagnostics kernel_min                       1 FALSE ""     
#> # ℹ 16 more rows
# }
```
