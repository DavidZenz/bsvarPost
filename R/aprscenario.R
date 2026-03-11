#' Convert tidy forecasts to APRScenario format
#'
#' @param object A posterior model object, a `Forecasts` object, or a tidy
#'   forecast table returned by [tidy_forecast()].
#' @param horizon Forecast horizon when `object` is a posterior model object.
#' @param probability Equal-tailed interval probability.
#' @param center Which summary column to map to APRScenario's `center` column.
#' @param origin Optional `Date` origin for turning forecast horizons into APR
#'   style `hor` dates.
#' @param frequency Step size used with `origin`. One of `"quarter"`,
#'   `"month"`, `"year"`, or `"day"`.
#' @param model Optional model identifier.
#' @param ... Additional arguments passed to [tidy_forecast()].
#' @export
as_apr_cond_forc <- function(object, ...) {
  UseMethod("as_apr_cond_forc")
}

#' @rdname as_apr_cond_forc
#' @export
as_apr_cond_forc.bsvar_post_tbl <- function(object, center = c("median", "mean"), origin = NULL,
                                            frequency = c("quarter", "month", "year", "day"), ...) {
  center <- match.arg(center)
  frequency <- match.arg(frequency)
  x <- object
  if (!all(c("variable", "lower", "upper", center) %in% names(x))) {
    stop("`object` must contain forecast summary columns.", call. = FALSE)
  }
  if (!("horizon" %in% names(x) || "time" %in% names(x))) {
    stop("`object` must contain a `horizon` or `time` column.", call. = FALSE)
  }
  hor_value <- if ("horizon" %in% names(x)) x$horizon else x$time
  hor <- build_apr_hor(hor_value, origin = origin, frequency = frequency)
  out <- data.frame(
    hor = hor,
    variable = x$variable,
    lower = x$lower,
    center = x[[center]],
    upper = x$upper,
    stringsAsFactors = FALSE
  )
  if ("model" %in% names(x)) out$model <- x$model
  out
}

#' @rdname as_apr_cond_forc
#' @export
as_apr_cond_forc.Forecasts <- function(object, probability = 0.68, center = c("median", "mean"),
                                       origin = NULL, frequency = c("quarter", "month", "year", "day"),
                                       model = "model1", ...) {
  as_apr_cond_forc(tidy_forecast(object, probability = probability, model = model), center = center,
                   origin = origin, frequency = frequency)
}

as_apr_cond_forc_model <- function(object, horizon = 10, probability = 0.68, center = c("median", "mean"),
                                   origin = NULL, frequency = c("quarter", "month", "year", "day"),
                                   model = "model1", ...) {
  as_apr_cond_forc(tidy_forecast(object, horizon = horizon, probability = probability, model = model, ...),
                   center = center, origin = origin, frequency = frequency)
}

#' @rdname as_apr_cond_forc
#' @export
as_apr_cond_forc.PosteriorBSVAR <- function(object, horizon = 10, probability = 0.68, center = c("median", "mean"),
                                            origin = NULL, frequency = c("quarter", "month", "year", "day"),
                                            model = "model1", ...) {
  as_apr_cond_forc_model(object, horizon = horizon, probability = probability, center = center,
                         origin = origin, frequency = frequency, model = model, ...)
}
#' @export
as_apr_cond_forc.PosteriorBSVARMIX <- as_apr_cond_forc.PosteriorBSVAR
#' @export
as_apr_cond_forc.PosteriorBSVARMSH <- as_apr_cond_forc.PosteriorBSVAR
#' @export
as_apr_cond_forc.PosteriorBSVARSV <- as_apr_cond_forc.PosteriorBSVAR
#' @export
as_apr_cond_forc.PosteriorBSVART <- as_apr_cond_forc.PosteriorBSVAR
#' @export
as_apr_cond_forc.PosteriorBSVARSIGN <- as_apr_cond_forc.PosteriorBSVAR

#' Convert APRScenario-style forecast tables to bsvarPost tidy format
#'
#' @param data A data frame with APRScenario columns `hor`, `variable`,
#'   `lower`, `center`, and `upper`.
#' @param model Model identifier.
#' @export
tidy_apr_forecast <- function(data, model = "apr") {
  required <- c("hor", "variable", "lower", "center", "upper")
  missing <- setdiff(required, names(data))
  if (length(missing) > 0) {
    stop("APR forecast data is missing required columns: ", paste(missing, collapse = ", "), call. = FALSE)
  }
  tbl <- tibble::tibble(
    model = if ("model" %in% names(data)) data$model else model,
    object_type = "forecast",
    variable = data$variable,
    time = data$hor,
    mean = data$center,
    median = data$center,
    sd = NA_real_,
    lower = data$lower,
    upper = data$upper
  )
  new_bsvar_post_tbl(tbl, object_type = "forecast", draws = FALSE)
}

#' Optional wrapper around APRScenario::gen_mats
#'
#' @param posterior A posterior model object.
#' @param specification The corresponding specification object.
#' @param max_cores Passed to `APRScenario::gen_mats()`.
#' @return The object returned by `APRScenario::gen_mats()`.
#' @export
apr_gen_mats <- function(posterior = NULL, specification = NULL, max_cores = 1) {
  if (!requireNamespace("APRScenario", quietly = TRUE)) {
    stop("Package `APRScenario` must be installed to use `apr_gen_mats()`.", call. = FALSE)
  }
  max_cores <- validate_positive_count(max_cores, "apr_gen_mats()", arg = "max_cores")
  APRScenario::gen_mats(posterior = posterior, specification = specification, max_cores = max_cores)
}

build_apr_hor <- function(horizon, origin = NULL, frequency = c("quarter", "month", "year", "day")) {
  frequency <- match.arg(frequency)
  if (inherits(horizon, "Date")) return(horizon)
  if (is.null(origin)) return(horizon)
  step <- switch(frequency, quarter = "quarter", month = "month", year = "year", day = "day")
  idx <- sort(unique(as.integer(horizon)))
  seq_out <- seq.Date(from = origin, by = step, length.out = max(idx) + 1L)
  seq_out[as.integer(horizon) + 1L]
}
