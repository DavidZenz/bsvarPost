# Summarises acceptance and admissibility diagnostics for bsvarSIGNs

Summarises the stored effective sample size and admissibility weights
recomputed from posterior draws and identification restrictions. These
diagnostics do not reconstruct the full proposal/rejection history of
the sampler. They report quantities obtained from the stored posterior
distribution and its identification restrictions. The upstream stored
ESS is an importance-weight ESS, computed before weighted resampling,
not an autocorrelation-based MCMC convergence diagnostic. Recomputed
kernel weights describe the stored draws and need not reproduce the
original weight vector.

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

  Label identifying the model specification.

## Value

A `bsvar_post_tbl` with columns `model`, `object_type`, `metric`,
`value`, `flag`, and `message`. Each row reports one diagnostic metric.

## See also

[posterior_provenance](https://davidzenz.github.io/bsvarPost/reference/posterior_provenance.md)

## Examples

``` r
# \donttest{
data(optimism, package = "bsvarSIGNs")
sign_irf <- matrix(c(1, rep(NA, 3)), 2, 2)
spec_s <- suppressMessages(
  bsvarSIGNs::specify_bsvarSIGN$new(optimism[, 1:2], p = 1,
                                     sign_irf = sign_irf)
)
post_s <- bsvars::estimate(spec_s, S = 5, show_progress = FALSE)

diag <- acceptance_diagnostics(post_s)
print(diag)
#> # A tibble: 13 × 16
#>    model  object_type            metric        value flag  message analysis_type
#>    <chr>  <chr>                  <chr>         <dbl> <lgl> <chr>   <chr>        
#>  1 model1 acceptance_diagnostics posterior_dr…     5 FALSE ""      acceptance_d…
#>  2 model1 acceptance_diagnostics effective_sa…     5 TRUE  "ESS b… acceptance_d…
#>  3 model1 acceptance_diagnostics max_tries       Inf FALSE ""      acceptance_d…
#>  4 model1 acceptance_diagnostics irf_sign_res…     1 FALSE ""      acceptance_d…
#>  5 model1 acceptance_diagnostics zero_restric…     0 FALSE ""      acceptance_d…
#>  6 model1 acceptance_diagnostics structural_s…     0 FALSE ""      acceptance_d…
#>  7 model1 acceptance_diagnostics narrative_re…     0 FALSE ""      acceptance_d…
#>  8 model1 acceptance_diagnostics kernel_mean       1 FALSE ""      acceptance_d…
#>  9 model1 acceptance_diagnostics kernel_median     1 FALSE ""      acceptance_d…
#> 10 model1 acceptance_diagnostics kernel_min        1 FALSE ""      acceptance_d…
#> 11 model1 acceptance_diagnostics kernel_max        1 FALSE ""      acceptance_d…
#> 12 model1 acceptance_diagnostics kernel_zero_…     0 FALSE ""      acceptance_d…
#> 13 model1 acceptance_diagnostics kernel_cv         0 FALSE ""      acceptance_d…
#> # ℹ 9 more variables: interval_probability <dbl>, interval_method <chr>,
#> #   scale_by <chr>, scale_var <chr>, scale_factor <dbl>, units <chr>,
#> #   source_package <chr>, source_version <chr>, n_draws <int>
# }
```
