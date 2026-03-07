#' Compare posterior impulse responses across models
#' @param ... Posterior model objects or a named list of model objects.
#' @param horizon Forecast horizon.
#' @param probability Interval probability.
#' @param draws If `TRUE`, return draw-level rows.
#' @export
compare_irf <- function(..., horizon = 10, probability = 0.68, draws = FALSE) {
  models <- collect_models(...)
  out <- lapply(names(models), function(nm) tidy_irf(models[[nm]], horizon = horizon, probability = probability, draws = draws, model = nm))
  set_compare_flag(new_bsvar_post_tbl(do.call(rbind, out), object_type = "irf", draws = draws, compare = TRUE))
}

#' Compare cumulative dynamic multipliers across models
#' @inheritParams compare_irf
#' @param scale_by Optional scaling mode for CDMs.
#' @param scale_var Optional scaling variable specification.
#' @export
compare_cdm <- function(..., horizon = 10, probability = 0.68, draws = FALSE,
                        scale_by = c("none", "shock_sd"), scale_var = NULL) {
  models <- collect_models(...)
  out <- lapply(names(models), function(nm) tidy_cdm(models[[nm]], horizon = horizon, probability = probability, draws = draws, model = nm, scale_by = scale_by, scale_var = scale_var))
  set_compare_flag(new_bsvar_post_tbl(do.call(rbind, out), object_type = "cdm", draws = draws, compare = TRUE))
}

#' Compare FEVDs across models
#' @inheritParams compare_irf
#' @export
compare_fevd <- function(..., horizon = 10, probability = 0.68, draws = FALSE) {
  models <- collect_models(...)
  out <- lapply(names(models), function(nm) tidy_fevd(models[[nm]], horizon = horizon, probability = probability, draws = draws, model = nm))
  set_compare_flag(new_bsvar_post_tbl(do.call(rbind, out), object_type = "fevd", draws = draws, compare = TRUE))
}

#' Compare forecasts across models
#' @inheritParams compare_irf
#' @export
compare_forecast <- function(..., horizon = 10, probability = 0.68, draws = FALSE) {
  models <- collect_models(...)
  out <- lapply(names(models), function(nm) tidy_forecast(models[[nm]], horizon = horizon, probability = probability, draws = draws, model = nm))
  set_compare_flag(new_bsvar_post_tbl(do.call(rbind, out), object_type = "forecast", draws = draws, compare = TRUE))
}
