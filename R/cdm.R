#' Computes posterior draws of cumulative dynamic multipliers
#'
#' Each draw from the posterior distribution of the impulse responses is
#' transformed into a draw from the posterior distribution of cumulative
#' dynamic multipliers by summing responses from horizon zero onwards.
#'
#' @section Interpretation:
#' The cumulative response at horizon `H` sums draw-level impulse responses
#' from zero through `H` (inclusive). Units follow the input transformations
#' and fitted structural-shock normalization. For log-level data this is a
#' cumulative log response, not a dollar-per-dollar fiscal multiplier.
#' `shock_sd` scaling does not form an output-to-spending response ratio.
#'
#' @param object A posterior model object.
#' @param horizon Forecast horizon.
#' @param probability Probability mass of the equal-tailed credible interval.
#' @param scale_by Either `"none"` or `"shock_sd"`. The latter divides each
#'   cumulative response by the selected observed variable's sample standard
#'   deviation, computed from the fitted sample.
#' @param scale_var Observed variable name or index used for `shock_sd` scaling;
#'   a scalar applies to every shock, or supply one entry per shock. With `NULL`,
#'   variables are matched to shocks by position.
#' @param ... Additional arguments passed to methods.
#' @return A 4-dimensional array of class \code{PosteriorCDM} with dimensions
#'   \code{[variables x shocks x (horizon + 1) x draws]}.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' cdm_draws <- cdm(post, horizon = 3)
#' dim(cdm_draws)
#' @export
cdm <- function(object, ...) {
  UseMethod("cdm")
}

#' @rdname cdm
#' @export
cdm.default <- function(object, ...) {
  stop(
    "cdm() requires a posterior model object.\n",
    "Received object of class: ", paste(class(object), collapse = ", "),
    call. = FALSE
  )
}

cdm_from_model <- function(object, horizon = NULL, probability = 0.90,
                           scale_by = c("none", "shock_sd"),
                           scale_var = NULL, ...) {
  validate_probability(probability)
  scale_by <- match.arg(scale_by)
  irf <- get_irf_draws(object, horizon = resolve_horizon(horizon), ...)
  out <- compute_cdm_draws(irf, scale_by = scale_by, scale_var = scale_var, model = object)
  cdm_draws <- out$draws
  class(cdm_draws) <- "PosteriorCDM"
  attr(cdm_draws, "probability") <- probability
  attr(cdm_draws, "scale_by") <- match.arg(scale_by)
  attr(cdm_draws, "scale_var") <- scale_var
  attr(cdm_draws, "scale_factors") <- out$scale_factors
  cdm_draws
}

#' @rdname cdm
#' @export
cdm.PosteriorBSVAR <- function(object, horizon = NULL, probability = 0.90,
                               scale_by = c("none", "shock_sd"), scale_var = NULL, ...) {
  cdm_from_model(object, horizon = horizon, probability = probability,
                 scale_by = scale_by, scale_var = scale_var, ...)
}

#' @rdname cdm
#' @export
cdm.PosteriorBSVARMIX <- cdm.PosteriorBSVAR

#' @rdname cdm
#' @export
cdm.PosteriorBSVARMSH <- cdm.PosteriorBSVAR

#' @rdname cdm
#' @export
cdm.PosteriorBSVARSV <- cdm.PosteriorBSVAR

#' @rdname cdm
#' @export
cdm.PosteriorBSVART <- cdm.PosteriorBSVAR

#' @rdname cdm
#' @export
cdm.PosteriorBSVARSIGN <- cdm.PosteriorBSVAR

#' @export
summary.PosteriorCDM <- function(object, probability = attr(object, "probability", exact = TRUE) %||% 0.90, ...) {
  as_tidy_response_array(object, object_type = "cdm", probability = probability, draws = FALSE)
}

#' @export
plot.PosteriorCDM <- function(x, ...) {
  plot(as_tidy_response_array(x, object_type = "cdm", probability = attr(x, "probability", exact = TRUE) %||% 0.90), ...)
}

`%||%` <- function(x, y) if (is.null(x)) y else x
