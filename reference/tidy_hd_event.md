# Tidy event-window historical decompositions

Aggregate historical decomposition draws or summaries over a selected
event window.

## Usage

``` r
tidy_hd_event(object, ...)

# S3 method for class 'bsvar_post_tbl'
tidy_hd_event(
  object,
  start,
  end = start,
  probability = 0.68,
  draws = FALSE,
  ...
)

# S3 method for class 'PosteriorHD'
tidy_hd_event(
  object,
  start,
  end = start,
  probability = 0.68,
  draws = FALSE,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVAR'
tidy_hd_event(
  object,
  start,
  end = start,
  probability = 0.68,
  draws = FALSE,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVARMIX'
tidy_hd_event(
  object,
  start,
  end = start,
  probability = 0.68,
  draws = FALSE,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVARMSH'
tidy_hd_event(
  object,
  start,
  end = start,
  probability = 0.68,
  draws = FALSE,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVARSV'
tidy_hd_event(
  object,
  start,
  end = start,
  probability = 0.68,
  draws = FALSE,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVART'
tidy_hd_event(
  object,
  start,
  end = start,
  probability = 0.68,
  draws = FALSE,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVARSIGN'
tidy_hd_event(
  object,
  start,
  end = start,
  probability = 0.68,
  draws = FALSE,
  model = "model1",
  ...
)
```

## Arguments

- object:

  A posterior model object, `PosteriorHD`, or tidy historical
  decomposition table.

- ...:

  Additional arguments passed to computation methods.

- start:

  First time index to include.

- end:

  Last time index to include. Defaults to `start`.

- probability:

  Equal-tailed interval probability.

- draws:

  If `TRUE`, return draw-level cumulative contributions.

- model:

  Optional model identifier.
