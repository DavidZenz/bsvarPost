# Create a structural restriction specification

Create a structural restriction specification

## Usage

``` r
structural_restriction(variable, shock, sign)
```

## Arguments

- variable:

  Row index or variable label.

- shock:

  Column index or shock label.

- sign:

  Sign restriction, typically `1` or `-1`.

## Value

A list of class `bsvar_post_structural_restriction` (inheriting from
`bsvar_post_restriction`) with elements `variable`, `shock`, and `sign`.

## Examples

``` r
r <- structural_restriction("gdp", "gdp", sign = 1)
print(r)
#> $variable
#> [1] "gdp"
#> 
#> $shock
#> [1] "gdp"
#> 
#> $sign
#> [1] 1
#> 
#> attr(,"class")
#> [1] "bsvar_post_structural_restriction" "bsvar_post_restriction"           
```
