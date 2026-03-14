# Create a narrative restriction specification

Create a narrative restriction specification

## Usage

``` r
narrative_restriction(
  start,
  periods = 1,
  type = c("S", "A", "B"),
  sign = 1,
  shock = 1,
  var = NA
)
```

## Arguments

- start:

  Start period index used by upstream `bsvarSIGNs` semantics.

- periods:

  Number of constrained periods.

- type:

  Narrative restriction type: `"S"`, `"A"`, or `"B"`.

- sign:

  Sign direction, `1` or `-1`.

- shock:

  Shock index.

- var:

  Variable index for `"A"` and `"B"` restrictions.

## Value

A list of class `bsvar_post_narrative_restriction` (inheriting from
`bsvar_post_restriction`) with elements `start`, `periods`, `type`,
`sign`, `shock`, and `var`.

## Examples

``` r
r <- narrative_restriction(start = 10, periods = 1, type = "S", sign = 1, shock = 1)
print(r)
#> $start
#> [1] 10
#> 
#> $periods
#> [1] 1
#> 
#> $type
#> [1] "S"
#> 
#> $sign
#> [1] 1
#> 
#> $shock
#> [1] 1
#> 
#> $var
#> [1] NA
#> 
#> attr(,"class")
#> [1] "bsvar_post_narrative_restriction" "bsvar_post_restriction"          
```
