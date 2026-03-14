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

## Value

A `bsvar_post_tbl` with columns `model`, `object_type`, `metric`,
`value`, `flag`, and `message`. Each row reports one diagnostic metric.

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
#> # A tibble: 13 × 6
#>    model  object_type            metric                      value flag  message
#>    <chr>  <chr>                  <chr>                       <dbl> <lgl> <chr>  
#>  1 model1 acceptance_diagnostics posterior_draws                 5 FALSE ""     
#>  2 model1 acceptance_diagnostics effective_sample_size           5 TRUE  "ESS b…
#>  3 model1 acceptance_diagnostics max_tries                     Inf FALSE ""     
#>  4 model1 acceptance_diagnostics irf_sign_restrictions           1 FALSE ""     
#>  5 model1 acceptance_diagnostics zero_restrictions               0 FALSE ""     
#>  6 model1 acceptance_diagnostics structural_sign_restrictio…     0 FALSE ""     
#>  7 model1 acceptance_diagnostics narrative_restrictions          0 FALSE ""     
#>  8 model1 acceptance_diagnostics kernel_mean                     1 FALSE ""     
#>  9 model1 acceptance_diagnostics kernel_median                   1 FALSE ""     
#> 10 model1 acceptance_diagnostics kernel_min                      1 FALSE ""     
#> 11 model1 acceptance_diagnostics kernel_max                      1 FALSE ""     
#> 12 model1 acceptance_diagnostics kernel_zero_share               0 FALSE ""     
#> 13 model1 acceptance_diagnostics kernel_cv                       0 FALSE ""     
# }
```
