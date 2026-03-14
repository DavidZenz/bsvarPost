# Convert APRScenario-style forecast tables to bsvarPost tidy format

Convert APRScenario-style forecast tables to bsvarPost tidy format

## Usage

``` r
tidy_apr_forecast(data, model = "apr")
```

## Arguments

- data:

  A data frame with APRScenario columns `hor`, `variable`, `lower`,
  `center`, and `upper`.

- model:

  Model identifier.

## Value

A `bsvar_post_tbl` with columns `model`, `object_type`, `variable`,
`time`, `mean`, `median`, `sd`, `lower`, and `upper`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Requires APRScenario package
apr_data <- data.frame(
  hor = 1:3,
  variable = "gdp",
  lower = c(0.8, 0.9, 1.0),
  center = c(1.0, 1.1, 1.2),
  upper = c(1.2, 1.3, 1.4)
)
tidy_tbl <- tidy_apr_forecast(apr_data)
head(tidy_tbl)
} # }
```
