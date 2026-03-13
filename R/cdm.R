#' Cumulative Dynamic Multipliers
#'
#' Compute cumulative dynamic multipliers (CDMs) for posterior objects from
#' `bsvars` and `bsvarSIGNs`.
#'
#' @param object A posterior model object.
#' @param horizon Forecast horizon.
#' @param probability Equal-tailed interval probability.
#' @param scale_by Optional scaling mode for CDMs.
#' @param scale_var Optional scaling variable specification.
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
  irf <- bsvars::compute_impulse_responses(object, horizon = resolve_horizon(horizon), ...)
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
