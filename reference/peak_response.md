# Peak response summaries for posterior IRFs and CDMs

Summarise the peak response level and the horizon at which that peak
occurs.

## Usage

``` r
peak_response(object, ...)

# S3 method for class 'PosteriorIR'
peak_response(
  object,
  variable = NULL,
  shock = NULL,
  absolute = FALSE,
  probability = 0.68,
  model = "model1",
  ...
)

# S3 method for class 'PosteriorBSVAR'
peak_response(
  object,
  horizon = 10,
  type = c("irf", "cdm"),
  variable = NULL,
  shock = NULL,
  absolute = FALSE,
  probability = 0.68,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARMIX'
peak_response(
  object,
  horizon = 10,
  type = c("irf", "cdm"),
  variable = NULL,
  shock = NULL,
  absolute = FALSE,
  probability = 0.68,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARMSH'
peak_response(
  object,
  horizon = 10,
  type = c("irf", "cdm"),
  variable = NULL,
  shock = NULL,
  absolute = FALSE,
  probability = 0.68,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARSV'
peak_response(
  object,
  horizon = 10,
  type = c("irf", "cdm"),
  variable = NULL,
  shock = NULL,
  absolute = FALSE,
  probability = 0.68,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVART'
peak_response(
  object,
  horizon = 10,
  type = c("irf", "cdm"),
  variable = NULL,
  shock = NULL,
  absolute = FALSE,
  probability = 0.68,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorBSVARSIGN'
peak_response(
  object,
  horizon = 10,
  type = c("irf", "cdm"),
  variable = NULL,
  shock = NULL,
  absolute = FALSE,
  probability = 0.68,
  model = "model1",
  scale_by = c("none", "shock_sd"),
  scale_var = NULL,
  ...
)

# S3 method for class 'PosteriorCDM'
peak_response(
  object,
  variable = NULL,
  shock = NULL,
  absolute = FALSE,
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
