# Shared schema for forecast summaries and the documented APR summary format.
validate_forecast_summary <- function(x, center, index) {
  if (!is.data.frame(x) || !nrow(x))
    stop("Forecast summaries require a nonempty data frame.", call. = FALSE)
  if (isTRUE(attr(x, "draws")) || any(c("draw", "draw_id", "shock") %in% names(x)))
    stop("APRScenario requires forecast summaries without draw or shock identifiers; summarise forecasts first.", call. = FALSE)
  required <- c("model", "variable", "lower", "upper", center, index)
  if (!all(required %in% names(x)))
    stop("`object` must contain forecast summary columns: ", paste(required, collapse = ", "), ".", call. = FALSE)
  fields <- unique(c(required, intersect(c("horizon", "time"), names(x))))
  if (anyDuplicated(names(x)) || any(vapply(x[fields], function(column) !is.null(dim(column)), logical(1))))
    stop("Forecast fields must be uniquely named, one-dimensional columns.", call. = FALSE)
  for (name in c("model", "variable")) {
    if (!(is.character(x[[name]]) || is.factor(x[[name]])) ||
        anyNA(x[[name]]) || any(!nzchar(trimws(as.character(x[[name]])))))
      stop("Forecast model and variable labels must be non-missing, nonempty text.", call. = FALSE)
  }
  for (name in c("lower", "upper", center)) {
    if (!is.numeric(x[[name]]) || any(!is.finite(x[[name]])))
      stop("Forecast summary values must be finite and numeric.", call. = FALSE)
  }
  if (any(x$lower > x$upper)) stop("Forecast lower bounds must not exceed upper bounds.", call. = FALSE)
  horizon <- x[[index]]
  if (inherits(horizon, "Date") || inherits(horizon, "POSIXt")) {
    valid <- all(is.finite(as.numeric(horizon)))
  } else if (is.numeric(horizon)) {
    valid <- all(is.finite(horizon) & horizon >= 0 & horizon == floor(horizon))
  } else if (is.character(horizon) || is.factor(horizon)) {
    valid <- !anyNA(horizon) && all(nzchar(trimws(as.character(horizon))))
  } else valid <- FALSE
  if (!valid) stop("Forecast horizons must be valid dates, non-negative integer offsets, or nonempty time labels.", call. = FALSE)
  duplicate <- anyDuplicated(vctrs::vec_group_id(as.data.frame(x[c("model", "variable", index)])))
  if (duplicate)
    stop("APR forecast output must have unique model-variable-horizon keys: duplicate model '", x$model[duplicate],
      "', variable '", x$variable[duplicate], "', horizon '", as.character(horizon[duplicate]), "'.", call. = FALSE)
  invisible(x)
}

#' Converts posterior forecasts to APRScenario format
#'
#' Transforms draws or summaries from the posterior predictive distribution into
#' the lower, centre, and upper paths used for conditional forecast analysis by
#' `APRScenario`.
#'
#' @param object A posterior model object, a `Forecasts` object, or a posterior
#'   forecast summary table returned by [tidy_forecast()]. Draw-level tables
#'   must be summarised first.
#' @param horizon Forecast horizon when `object` is a posterior model object.
#' @param probability Probability mass of the equal-tailed credible interval.
#' @param center Posterior location summary represented by APRScenario's
#'   `center` column.
#' @param origin Optional `Date` origin for turning forecast horizons into APR
#'   style `hor` dates.
#' @param frequency Step size used with `origin`. One of `"quarter"`,
#'   `"month"`, `"year"`, or `"day"`.
#' @section Forecast identity and dates:
#' Tables must describe forecasts, with finite numeric summary values and
#' unique model-variable-horizon keys. Draw and shock identifiers are rejected
#' because APRScenario's summary format cannot retain those dimensions.
#' Horizons are non-negative integer offsets when converted using `origin`;
#' zero denotes the origin itself. Without `origin`, numeric offsets or
#' nonempty character time labels are retained. Date/POSIXt indices are
#' retained as supplied.
#'
#' Month, quarter and year steps are anchored to the origin's calendar day.
#' An origin at month end stays at month end. Otherwise, the day is clamped to
#' the target month's last day when necessary, without shifting later dates.
#' For example, quarterly steps from 2024-03-31 give 2024-06-30 and 2024-09-30;
#' monthly steps from 2024-01-30 give 2024-02-29 and 2024-03-30. Calendar
#' conversion supports target years 1 through 9999.
#' @param model Label identifying the model specification.
#' @param ... Additional arguments passed to [tidy_forecast()].
#' @return A data frame with columns \code{hor}, \code{variable},
#'   \code{lower}, \code{center}, \code{upper}, and \code{model}, suitable for use with
#'   conditional forecast analysis with APRScenario.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' apr_forc <- as_apr_cond_forc(post, horizon = 3)
#' head(apr_forc)
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
  if (!identical(attr(x, "object_type"), "forecast") ||
      ("object_type" %in% names(x) && anyNA(match(x$object_type, "forecast")))) {
    stop("`object` must be a forecast-type table returned by tidy_forecast() or tidy_apr_forecast().", call. = FALSE)
  }
  if (!("horizon" %in% names(x) || "time" %in% names(x)))
    stop("`object` must contain a `horizon` or `time` column.", call. = FALSE)
  index <- if ("horizon" %in% names(x)) "horizon" else "time"
  validate_forecast_summary(x, center, index)
  hor_value <- x[[index]]
  hor <- build_apr_hor(hor_value, origin = origin, frequency = frequency)
  out <- data.frame(
    hor = hor,
    variable = x$variable,
    lower = x$lower,
    center = x[[center]],
    upper = x$upper,
    stringsAsFactors = FALSE
  )
  out$model <- x$model
  if (anyDuplicated(vctrs::vec_group_id(out[c("model", "variable", "hor")])))
    stop("APR forecast output must have unique model-variable-horizon keys.", call. = FALSE)
  out
}

#' @rdname as_apr_cond_forc
#' @export
as_apr_cond_forc.Forecasts <- function(object, probability = 0.90, center = c("median", "mean"),
                                       origin = NULL, frequency = c("quarter", "month", "year", "day"),
                                       model = "model1", ...) {
  as_apr_cond_forc(tidy_forecast(object, probability = probability, model = model), center = center,
                   origin = origin, frequency = frequency)
}

as_apr_cond_forc_model <- function(object, horizon = NULL, probability = 0.90, center = c("median", "mean"),
                                   origin = NULL, frequency = c("quarter", "month", "year", "day"),
                                   model = "model1", ...) {
  as_apr_cond_forc(tidy_forecast(object, horizon = horizon, probability = probability, model = model, ...),
                   center = center, origin = origin, frequency = frequency)
}

#' @rdname as_apr_cond_forc
#' @export
as_apr_cond_forc.PosteriorBSVAR <- function(object, horizon = NULL, probability = 0.90, center = c("median", "mean"),
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

#' Converts APRScenario forecasts to posterior summary tables
#'
#' Transforms lower, centre, and upper APRScenario forecast paths into the
#' posterior-summary table format used by `bsvarPost`.
#'
#' @param data A data frame with APRScenario columns `hor`, `variable`,
#'   `lower`, `center`, and `upper`, and optionally `model`.
#' @details Both APR adapters require finite numeric summaries, nonempty
#'   model/variable labels, valid horizons and unique model-variable-horizon
#'   keys. Lower bounds cannot exceed upper bounds. The centre may lie outside
#'   the interval, for example when it represents a skewed forecast's mean.
#'   Draw and shock dimensions are unsupported in this summary format. Other
#'   extra columns are rejected on import; encode additional series identities
#'   in `model` explicitly. Date/POSIXt indices retain their supplied values.
#' @param model Label identifying the model specification.
#' @return A \code{bsvar_post_tbl} with columns \code{model}, \code{object_type},
#'   \code{variable}, \code{time}, \code{mean}, \code{median}, \code{sd},
#'   \code{lower}, and \code{upper}.
#' @examples
#' \dontrun{
#' # Requires APRScenario package
#' apr_data <- data.frame(
#'   hor = 1:3,
#'   variable = "gdp",
#'   lower = c(0.8, 0.9, 1.0),
#'   center = c(1.0, 1.1, 1.2),
#'   upper = c(1.2, 1.3, 1.4)
#' )
#' tidy_tbl <- tidy_apr_forecast(apr_data)
#' head(tidy_tbl)
#' }
#' @export
tidy_apr_forecast <- function(data, model = "apr") {
  if (!is.data.frame(data)) stop("APR forecast data must be a data frame.", call. = FALSE)
  if (!"model" %in% names(data)) {
    if (!(is.character(model) || is.factor(model)) || length(model) != 1L || is.na(model) || !nzchar(trimws(as.character(model))))
      stop("`model` must be a single nonempty text label.", call. = FALSE)
    data$model <- rep(model, nrow(data))
  }
  validate_forecast_summary(data, "center", "hor")
  extra <- setdiff(names(data), c("model", "hor", "variable", "lower", "center", "upper"))
  if (length(extra))
    stop("Unsupported APR forecast column(s): ", paste(extra, collapse = ", "),
      ". Encode additional series identities in `model` before conversion.", call. = FALSE)
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

#' Computes conditional-forecast matrices with APRScenario
#'
#' Applies `APRScenario::gen_mats()` to a posterior distribution and its model
#' specification to obtain the matrices used for conditional forecasting.
#'
#' @param posterior A posterior model object.
#' @param specification The corresponding specification object.
#' @param max_cores Maximum number of processor cores used by
#'   `APRScenario::gen_mats()`.
#' @return The result of \code{APRScenario::gen_mats()}, typically a list
#'   containing matrices used for conditional forecasting.
#' @examples
#' \dontrun{
#' # Requires APRScenario package
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#' mats <- apr_gen_mats(posterior = post, specification = spec)
#' }
#' @export
apr_gen_mats <- function(posterior = NULL, specification = NULL, max_cores = 1) {
  if (!requireNamespace("APRScenario", quietly = TRUE)) {
    stop("Package `APRScenario` must be installed to use `apr_gen_mats()`.", call. = FALSE)
  }
  max_cores <- validate_positive_count(max_cores, "apr_gen_mats", arg = "max_cores")
  APRScenario::gen_mats(posterior = posterior, specification = specification, max_cores = max_cores)
}

build_apr_hor <- function(horizon, origin = NULL, frequency = c("quarter", "month", "year", "day")) {
  frequency <- match.arg(frequency)
  if (inherits(horizon, "Date") || inherits(horizon, "POSIXt")) return(horizon)
  if (is.null(origin)) return(horizon)
  if (!inherits(origin, "Date") || length(origin) != 1L || !is.finite(as.numeric(origin))) {
    stop("`origin` must be a single non-missing Date.", call. = FALSE)
  }
  suppressWarnings(indices <- as.numeric(as.character(horizon)))
  if (!length(indices) || anyNA(indices) || any(!is.finite(indices)) ||
      any(indices < 0 | indices > .Machine$integer.max | indices != floor(indices))) {
    stop("Forecast date conversion requires non-negative integer horizons.", call. = FALSE)
  }
  if (frequency == "day") return(origin + indices)
  year <- as.numeric(format(origin, "%Y"))
  month <- as.numeric(format(origin, "%m"))
  day <- as.numeric(format(origin, "%d"))
  step <- switch(frequency, quarter = 3, month = 1, year = 12)
  target <- year * 12 + month - 1 + indices * step
  target_year <- target %/% 12
  target_month <- target %% 12 + 1
  if (any(target_year < 1 | target_year > 9999))
    stop("Forecast calendar conversion requires target years between 1 and 9999.", call. = FALSE)
  month_end_day <- function(y, m) {
    days <- c(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)[m]
    leap <- y %% 4 == 0 & (y %% 100 != 0 | y %% 400 == 0)
    days[m == 2 & leap] <- 29
    days
  }
  last_day <- month_end_day(target_year, target_month)
  target_day <- if (day == month_end_day(year, month)) last_day else pmin(day, last_day)
  as.Date(sprintf("%04d-%02d-%02d", as.integer(target_year), as.integer(target_month), as.integer(target_day)))
}
