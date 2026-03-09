#' Tidy posterior impulse responses
#' @param object A posterior model object or posterior IRF array.
#' @param horizon Forecast horizon when `object` is a posterior model object.
#' @param probability Equal-tailed interval probability.
#' @param draws If `TRUE`, return draw-level rows.
#' @param model Optional model identifier.
#' @param ... Additional arguments passed to computation methods.
#' @export
tidy_irf <- function(object, ...) UseMethod("tidy_irf")

#' @export
tidy_irf.PosteriorIR <- function(object, probability = 0.68, draws = FALSE, model = "model1", ...) {
  as_tidy_response_array(object, object_type = "irf", model = model, probability = probability, draws = draws)
}

tidy_irf_model <- function(object, horizon = 10, probability = 0.68, draws = FALSE, model = "model1", ...) {
  irf <- bsvars::compute_impulse_responses(object, horizon = horizon, ...)
  tidy_irf(set_response_dimnames(irf, model = object), probability = probability, draws = draws, model = model)
}

#' @rdname tidy_irf
#' @export
tidy_irf.PosteriorBSVAR <- function(object, horizon = 10, probability = 0.68, draws = FALSE, model = "model1", ...) {
  tidy_irf_model(object, horizon = horizon, probability = probability, draws = draws, model = model, ...)
}
#' @export
tidy_irf.PosteriorBSVARMIX <- tidy_irf.PosteriorBSVAR
#' @export
tidy_irf.PosteriorBSVARMSH <- tidy_irf.PosteriorBSVAR
#' @export
tidy_irf.PosteriorBSVARSV <- tidy_irf.PosteriorBSVAR
#' @export
tidy_irf.PosteriorBSVART <- tidy_irf.PosteriorBSVAR
#' @export
tidy_irf.PosteriorBSVARSIGN <- tidy_irf.PosteriorBSVAR

#' Tidy cumulative dynamic multipliers
#' @inheritParams tidy_irf
#' @param scale_by Optional scaling mode for CDMs.
#' @param scale_var Optional scaling variable specification.
#' @export
tidy_cdm <- function(object, ...) UseMethod("tidy_cdm")

#' @export
tidy_cdm.PosteriorCDM <- function(object, probability = attr(object, "probability", exact = TRUE) %||% 0.68,
                                  draws = FALSE, model = "model1", ...) {
  as_tidy_response_array(object, object_type = "cdm", model = model, probability = probability, draws = draws)
}

tidy_cdm_model <- function(object, horizon = 10, probability = 0.68, draws = FALSE,
                           model = "model1", scale_by = c("none", "shock_sd"), scale_var = NULL, ...) {
  tidy_cdm(cdm(object, horizon = horizon, probability = probability, scale_by = scale_by, scale_var = scale_var, ...),
           probability = probability, draws = draws, model = model)
}

#' @rdname tidy_cdm
#' @export
tidy_cdm.PosteriorBSVAR <- function(object, horizon = 10, probability = 0.68, draws = FALSE,
                                    model = "model1", scale_by = c("none", "shock_sd"), scale_var = NULL, ...) {
  tidy_cdm_model(object, horizon = horizon, probability = probability, draws = draws, model = model,
                 scale_by = scale_by, scale_var = scale_var, ...)
}
#' @export
tidy_cdm.PosteriorBSVARMIX <- tidy_cdm.PosteriorBSVAR
#' @export
tidy_cdm.PosteriorBSVARMSH <- tidy_cdm.PosteriorBSVAR
#' @export
tidy_cdm.PosteriorBSVARSV <- tidy_cdm.PosteriorBSVAR
#' @export
tidy_cdm.PosteriorBSVART <- tidy_cdm.PosteriorBSVAR
#' @export
tidy_cdm.PosteriorBSVARSIGN <- tidy_cdm.PosteriorBSVAR

#' Tidy forecast error variance decompositions
#' @inheritParams tidy_irf
#' @export
 tidy_fevd <- function(object, ...) UseMethod("tidy_fevd")
#' @export
 tidy_fevd.PosteriorFEVD <- function(object, probability = 0.68, draws = FALSE, model = "model1", ...) {
  as_tidy_response_array(object, object_type = "fevd", model = model, probability = probability, draws = draws)
 }
 tidy_fevd_model <- function(object, horizon = 10, probability = 0.68, draws = FALSE, model = "model1", ...) {
  fevd <- bsvars::compute_variance_decompositions(object, horizon = horizon, ...)
  tidy_fevd(set_response_dimnames(fevd, model = object), probability = probability, draws = draws, model = model)
 }
#' @export
 tidy_fevd.PosteriorBSVAR <- tidy_fevd_model
#' @export
 tidy_fevd.PosteriorBSVARMIX <- tidy_fevd_model
#' @export
 tidy_fevd.PosteriorBSVARMSH <- tidy_fevd_model
#' @export
 tidy_fevd.PosteriorBSVARSV <- tidy_fevd_model
#' @export
 tidy_fevd.PosteriorBSVART <- tidy_fevd_model
#' @export
 tidy_fevd.PosteriorBSVARSIGN <- tidy_fevd_model

#' Tidy structural shocks
#' @inheritParams tidy_irf
#' @export
 tidy_shocks <- function(object, ...) UseMethod("tidy_shocks")
#' @export
 tidy_shocks.PosteriorShocks <- function(object, probability = 0.68, draws = FALSE, model = "model1", ...) {
  as_tidy_time_array(object, object_type = "shocks", model = model, probability = probability, draws = draws, time_name = "time")
 }
 tidy_shocks_model <- function(object, probability = 0.68, draws = FALSE, model = "model1", ...) {
  shocks <- bsvars::compute_structural_shocks(object)
  tidy_shocks(set_time_dimnames(shocks, model = object), probability = probability, draws = draws, model = model)
 }
#' @export
 tidy_shocks.PosteriorBSVAR <- tidy_shocks_model
#' @export
 tidy_shocks.PosteriorBSVARMIX <- tidy_shocks_model
#' @export
 tidy_shocks.PosteriorBSVARMSH <- tidy_shocks_model
#' @export
 tidy_shocks.PosteriorBSVARSV <- tidy_shocks_model
#' @export
 tidy_shocks.PosteriorBSVART <- tidy_shocks_model
#' @export
 tidy_shocks.PosteriorBSVARSIGN <- tidy_shocks_model

#' Tidy historical decompositions
#' @inheritParams tidy_irf
#' @export
 tidy_hd <- function(object, ...) UseMethod("tidy_hd")
#' @export
 tidy_hd.PosteriorHD <- function(object, probability = 0.68, draws = FALSE, model = "model1", ...) {
  as_tidy_hd_array(object, model = model, probability = probability, draws = draws)
 }
 tidy_hd_model <- function(object, probability = 0.68, draws = FALSE, model = "model1", ...) {
  hd <- bsvars::compute_historical_decompositions(object, show_progress = FALSE)
  tidy_hd(set_hd_dimnames(hd, model = object), probability = probability, draws = draws, model = model)
 }
#' @export
 tidy_hd.PosteriorBSVAR <- tidy_hd_model
#' @export
 tidy_hd.PosteriorBSVARMIX <- tidy_hd_model
#' @export
 tidy_hd.PosteriorBSVARMSH <- tidy_hd_model
#' @export
 tidy_hd.PosteriorBSVARSV <- tidy_hd_model
#' @export
 tidy_hd.PosteriorBSVART <- tidy_hd_model
#' @export
 tidy_hd.PosteriorBSVARSIGN <- tidy_hd_model

#' Tidy forecasts
#' @inheritParams tidy_irf
#' @export
 tidy_forecast <- function(object, ...) UseMethod("tidy_forecast")
#' @export
 tidy_forecast.Forecasts <- function(object, probability = 0.68, draws = FALSE, model = "model1", ...) {
  as_tidy_time_array(object$forecasts, object_type = "forecast", model = model, probability = probability, draws = draws, time_name = "horizon")
 }
 tidy_forecast_model <- function(object, horizon = 10, probability = 0.68, draws = FALSE, model = "model1", ...) {
  tidy_forecast(bsvars::forecast(object, horizon = horizon, ...), probability = probability, draws = draws, model = model)
 }
#' @export
 tidy_forecast.PosteriorBSVAR <- tidy_forecast_model
#' @export
 tidy_forecast.PosteriorBSVARMIX <- tidy_forecast_model
#' @export
 tidy_forecast.PosteriorBSVARMSH <- tidy_forecast_model
#' @export
 tidy_forecast.PosteriorBSVARSV <- tidy_forecast_model
#' @export
 tidy_forecast.PosteriorBSVART <- tidy_forecast_model
#' @export
 tidy_forecast.PosteriorBSVARSIGN <- tidy_forecast_model
