# Handle deprecated argument with warning

Issues a deprecation warning when an old argument is used, and resolves
which value to return (new takes precedence over old).

## Usage

``` r
deprecate_arg(new_val, old_val, old_name, new_name, fn_name)
```

## Arguments

- new_val:

  Value provided for the new argument (may be NULL).

- old_val:

  Value provided for the deprecated argument (may be NULL).

- old_name:

  Name of the deprecated argument for the warning message.

- new_name:

  Name of the replacement argument for the warning message.

- fn_name:

  Name of the calling function for the warning message.

## Value

`new_val` if not NULL; `old_val` otherwise.
