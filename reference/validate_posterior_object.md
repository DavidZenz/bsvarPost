# Validate a posterior model object

Check that `object` inherits from one of the supported posterior classes
from the bsvars or bsvarSIGNs packages.

## Usage

``` r
validate_posterior_object(object, arg_name = "object")
```

## Arguments

- object:

  Object to validate.

- arg_name:

  Name of the argument for error messages.

## Value

`invisible(object)` if valid.
