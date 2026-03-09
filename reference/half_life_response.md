# Half-life summaries for posterior IRFs and CDMs

Summarise the first horizon at which a response falls to a chosen
fraction of its initial or peak level.

## Usage

``` r
half_life_response(object, ...)

# S3 method for class 'PosteriorIR'
half_life_response(
  object,
  variable = NULL,
  shock = NULL,
  fraction = 0.5,
  baseline = c("peak", "initial"),
  absolute = TRUE,
  probability = 0.68,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVAR'
half_life_response(
  object,
  horizon = 10,
  type = c("irf", "cdm"),
  variable = NULL,
  shock = NULL,
  fraction = 0.5,
  baseline = c("peak", "initial"),
  absolute = TRUE,
  probability = 0.68,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARMIX'
half_life_response(
  object,
  horizon = 10,
  type = c("irf", "cdm"),
  variable = NULL,
  shock = NULL,
  fraction = 0.5,
  baseline = c("peak", "initial"),
  absolute = TRUE,
  probability = 0.68,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARMSH'
half_life_response(
  object,
  horizon = 10,
  type = c("irf", "cdm"),
  variable = NULL,
  shock = NULL,
  fraction = 0.5,
  baseline = c("peak", "initial"),
  absolute = TRUE,
  probability = 0.68,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARSV'
half_life_response(
  object,
  horizon = 10,
  type = c("irf", "cdm"),
  variable = NULL,
  shock = NULL,
  fraction = 0.5,
  baseline = c("peak", "initial"),
  absolute = TRUE,
  probability = 0.68,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVART'
half_life_response(
  object,
  horizon = 10,
  type = c("irf", "cdm"),
  variable = NULL,
  shock = NULL,
  fraction = 0.5,
  baseline = c("peak", "initial"),
  absolute = TRUE,
  probability = 0.68,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARSIGN'
half_life_response(
  object,
  horizon = 10,
  type = c("irf", "cdm"),
  variable = NULL,
  shock = NULL,
  fraction = 0.5,
  baseline = c("peak", "initial"),
  absolute = TRUE,
  probability = 0.68,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorCDM'
half_life_response(
  object,
  variable = NULL,
  shock = NULL,
  fraction = 0.5,
  baseline = c("peak", "initial"),
  absolute = TRUE,
  probability = 0.68,
  model = "model1",
  ...
)
```

## Arguments

- object:

  A posterior model object, `PosteriorIR`, or `PosteriorCDM`.

- ...:

  Additional arguments passed to computation methods.

- variable:

  Optional response-variable subset.

- shock:

  Optional shock subset.

- fraction:

  Fraction of the reference level used to define the half-life.

- baseline:

  Reference level: `"peak"` uses the largest response over the available
  horizons, `"initial"` uses the horizon-0 response.

- absolute:

  If `TRUE`, search for the largest absolute response.

- probability:

  Equal-tailed interval probability.

- model:

  Optional model identifier.

- horizon:

  Maximum horizon used when `object` is a posterior model object.

- type:

  Response type for posterior model objects: `"irf"` or `"cdm"`.

- scale_by:

  Optional scaling mode for CDMs.

- scale_var:

  Optional scaling variable specification.
