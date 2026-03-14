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

## Value

A list of class `bsvar_post_irf_restriction` (inheriting from
`bsvar_post_restriction`) with elements `variable`, `shock`, `horizon`,
`sign`, and `zero`.

## Examples

``` r
r <- irf_restriction("gdp", "gdp", 0, sign = 1)
print(r)
#> $variable
#> [1] "gdp"
#> 
#> $shock
#> [1] "gdp"
#> 
#> $horizon
#> [1] 0
#> 
#> $sign
#> [1] 1
#> 
#> $zero
#> [1] FALSE
#> 
#> attr(,"class")
#> [1] "bsvar_post_irf_restriction" "bsvar_post_restriction"    
```
