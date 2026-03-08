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


#' Compare restriction audits across models
#' @param ... Posterior model objects or a named list of model objects.
#' @param restrictions Optional list of restriction helper objects applied to each model.
#' @param zero_tol Numerical tolerance for zero restrictions.
#' @param probability Equal-tailed interval probability used in summaries.
#' @export
compare_restrictions <- function(..., restrictions = NULL, zero_tol = 1e-8, probability = 0.68) {
  models <- collect_models(...)
  out <- lapply(names(models), function(nm) {
    restriction_audit(models[[nm]], restrictions = restrictions, zero_tol = zero_tol, probability = probability, model = nm)
  })
  set_compare_flag(new_bsvar_post_tbl(do.call(rbind, out), object_type = "restriction_audit", draws = FALSE, compare = TRUE))
}


#' Compare event-window historical decompositions across models
#' @param ... Posterior model objects or a named list of model objects.
#' @param start First time index to include.
#' @param end Last time index to include. Defaults to `start`.
#' @param probability Equal-tailed interval probability used in summaries.
#' @param draws If `TRUE`, return draw-level rows.
#' @export
compare_hd_event <- function(..., start, end = start, probability = 0.68, draws = FALSE) {
  models <- collect_models(...)
  out <- lapply(names(models), function(nm) {
    tidy_hd_event(models[[nm]], start = start, end = end, probability = probability, draws = draws, model = nm)
  })
  set_compare_flag(new_bsvar_post_tbl(do.call(rbind, out), object_type = "hd_event", draws = draws, compare = TRUE))
}


#' Compare peak response summaries across models
#' @param ... Posterior model objects or a named list of model objects.
#' @param horizon Maximum horizon used when `object` is a posterior model object.
#' @param type Response type for posterior model objects: `"irf"` or `"cdm"`.
#' @param variable Optional response-variable subset.
#' @param shock Optional shock subset.
#' @param absolute If `TRUE`, search for the largest absolute response.
#' @param probability Equal-tailed interval probability.
#' @param scale_by Optional scaling mode for CDMs.
#' @param scale_var Optional scaling variable specification.
#' @export
compare_peak_response <- function(..., horizon = 10, type = c("irf", "cdm"), variable = NULL, shock = NULL,
                                  absolute = FALSE, probability = 0.68,
                                  scale_by = c("none", "shock_sd"), scale_var = NULL) {
  type <- match.arg(type)
  models <- collect_models(...)
  out <- lapply(names(models), function(nm) {
    peak_response(models[[nm]], horizon = horizon, type = type, variable = variable, shock = shock,
                  absolute = absolute, probability = probability, model = nm,
                  scale_by = scale_by, scale_var = scale_var)
  })
  set_compare_flag(new_bsvar_post_tbl(do.call(rbind, out), object_type = paste0("peak_", type), draws = FALSE, compare = TRUE))
}

#' Compare duration summaries across models
#' @param ... Posterior model objects or a named list of model objects.
#' @param horizon Maximum horizon used when `object` is a posterior model object.
#' @param type Response type for posterior model objects: `"irf"` or `"cdm"`.
#' @param variable Optional response-variable subset.
#' @param shock Optional shock subset.
#' @param relation Comparison operator.
#' @param value Threshold value.
#' @param absolute If `TRUE`, compare absolute responses.
#' @param mode Either `"consecutive"` or `"total"`.
#' @param probability Equal-tailed interval probability.
#' @param scale_by Optional scaling mode for CDMs.
#' @param scale_var Optional scaling variable specification.
#' @export
compare_duration_response <- function(..., horizon = 10, type = c("irf", "cdm"), variable = NULL, shock = NULL,
                                      relation = c(">", ">=", "<", "<="), value = 0,
                                      absolute = FALSE, mode = c("consecutive", "total"), probability = 0.68,
                                      scale_by = c("none", "shock_sd"), scale_var = NULL) {
  type <- match.arg(type)
  relation <- match.arg(relation)
  mode <- match.arg(mode)
  models <- collect_models(...)
  out <- lapply(names(models), function(nm) {
    duration_response(models[[nm]], horizon = horizon, type = type, variable = variable, shock = shock,
                      relation = relation, value = value, absolute = absolute, mode = mode,
                      probability = probability, model = nm, scale_by = scale_by, scale_var = scale_var)
  })
  set_compare_flag(new_bsvar_post_tbl(do.call(rbind, out), object_type = paste0("duration_", type), draws = FALSE, compare = TRUE))
}

#' Compare half-life summaries across models
#' @param ... Posterior model objects or a named list of model objects.
#' @param horizon Maximum horizon used when `object` is a posterior model object.
#' @param type Response type for posterior model objects: `"irf"` or `"cdm"`.
#' @param variable Optional response-variable subset.
#' @param shock Optional shock subset.
#' @param fraction Fraction of the reference level used to define the half-life.
#' @param baseline Reference level: `"peak"` or `"initial"`.
#' @param absolute If `TRUE`, compute half-lives using absolute responses.
#' @param probability Equal-tailed interval probability.
#' @param scale_by Optional scaling mode for CDMs.
#' @param scale_var Optional scaling variable specification.
#' @export
compare_half_life_response <- function(..., horizon = 10, type = c("irf", "cdm"), variable = NULL, shock = NULL,
                                       fraction = 0.5, baseline = c("peak", "initial"),
                                       absolute = TRUE, probability = 0.68,
                                       scale_by = c("none", "shock_sd"), scale_var = NULL) {
  type <- match.arg(type)
  baseline <- match.arg(baseline)
  models <- collect_models(...)
  out <- lapply(names(models), function(nm) {
    half_life_response(models[[nm]], horizon = horizon, type = type, variable = variable, shock = shock,
                       fraction = fraction, baseline = baseline, absolute = absolute,
                       probability = probability, model = nm, scale_by = scale_by, scale_var = scale_var)
  })
  set_compare_flag(new_bsvar_post_tbl(do.call(rbind, out), object_type = paste0("half_life_", type), draws = FALSE, compare = TRUE))
}

#' Compare time-to-threshold summaries across models
#' @param ... Posterior model objects or a named list of model objects.
#' @param horizon Maximum horizon used when `object` is a posterior model object.
#' @param type Response type for posterior model objects: `"irf"` or `"cdm"`.
#' @param variable Optional response-variable subset.
#' @param shock Optional shock subset.
#' @param relation Comparison operator.
#' @param value Threshold value.
#' @param absolute If `TRUE`, compare absolute responses.
#' @param probability Equal-tailed interval probability.
#' @param scale_by Optional scaling mode for CDMs.
#' @param scale_var Optional scaling variable specification.
#' @export
compare_time_to_threshold <- function(..., horizon = 10, type = c("irf", "cdm"), variable = NULL, shock = NULL,
                                      relation = c(">", ">=", "<", "<="), value = 0,
                                      absolute = FALSE, probability = 0.68,
                                      scale_by = c("none", "shock_sd"), scale_var = NULL) {
  type <- match.arg(type)
  relation <- match.arg(relation)
  models <- collect_models(...)
  out <- lapply(names(models), function(nm) {
    time_to_threshold(models[[nm]], horizon = horizon, type = type, variable = variable, shock = shock,
                      relation = relation, value = value, absolute = absolute,
                      probability = probability, model = nm, scale_by = scale_by, scale_var = scale_var)
  })
  set_compare_flag(new_bsvar_post_tbl(do.call(rbind, out), object_type = paste0("time_to_threshold_", type), draws = FALSE, compare = TRUE))
}
