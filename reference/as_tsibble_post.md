# Convert bsvarPost tidy outputs to tsibble

Convert bsvarPost tidy outputs to tsibble

## Usage

``` r
as_tsibble_post(
  object,
  key = NULL,
  index = NULL,
  regular = NULL,
  validate = TRUE
)
```

## Arguments

- object:

  A `bsvar_post_tbl`.

- key:

  Optional key columns. By default, `bsvarPost` chooses a key from
  `model`, `variable`, `shock`, and `draw` when present.

- index:

  Optional index column. By default, `horizon` is used if present,
  otherwise `time`.

- regular:

  Optional regularity flag passed to
  [`tsibble::as_tsibble()`](https://tsibble.tidyverts.org/reference/as-tsibble.html).

- validate:

  Passed to
  [`tsibble::as_tsibble()`](https://tsibble.tidyverts.org/reference/as-tsibble.html).
