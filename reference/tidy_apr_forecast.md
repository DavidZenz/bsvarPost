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
