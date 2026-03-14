# Joint posterior probability statements for impulse responses

Evaluate whether a set of posterior IRF inequalities holds jointly
across all selected variables, shocks, and horizons.

## Usage

``` r
joint_hypothesis_irf(object, ...)

# Default S3 method
joint_hypothesis_irf(object, ...)
```

## Arguments

- object:

  A posterior model object or a `PosteriorIR` object.

- ...:

  Additional arguments passed to computation methods.

## Value

A `bsvar_post_tbl` with columns `model`, `object_type`, `relation`,
`posterior_prob`, `n_constraints`, `variable`, `shock`, `horizon`,
`rhs_variable`, `rhs_shock`, `rhs_horizon`, `rhs_value`, and `absolute`.

## Examples

``` r
data(us_fiscal_lsuw, package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#> The identification is set to the default option of lower-triangular structural matrix.
post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)

jh <- joint_hypothesis_irf(post, variable = "gdp", shock = "gdp",
                           horizon = 0:2, relation = ">", value = 0)
print(jh)
#> # A tibble: 1 × 13
#>   model object_type relation posterior_prob n_constraints variable shock horizon
#>   <chr> <chr>       <chr>             <dbl>         <int> <chr>    <chr> <chr>  
#> 1 mode… joint_irf   >                     0             3 gdp      gdp   0,1,2  
#> # ℹ 5 more variables: rhs_variable <chr>, rhs_shock <chr>, rhs_horizon <dbl>,
#> #   rhs_value <dbl>, absolute <lgl>
```
