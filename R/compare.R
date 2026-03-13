#' Compare posterior impulse responses across models
#' @param ... Posterior model objects or a named list of model objects.
#' @param horizon Forecast horizon. If \code{NULL} (default), resolves to 20
#'   periods.
#' @param probability Interval probability.
#' @param draws If `TRUE`, return draw-level rows.
#' @return A \code{bsvar_post_tbl} combining results across models, with a
#'   \code{model} column identifying each input.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post1 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#' post2 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' comp <- compare_irf(m1 = post1, m2 = post2, horizon = 3)
#' head(comp)
#' @export
compare_irf <- function(..., horizon = NULL, probability = 0.90, draws = FALSE) {
  models <- collect_models(...)
  out <- lapply(names(models), function(nm) tidy_irf(models[[nm]], horizon = resolve_horizon(horizon), probability = probability, draws = draws, model = nm))
  validate_model_compatibility(out, "compare_irf")
  set_compare_flag(new_bsvar_post_tbl(do.call(rbind, out), object_type = "irf", draws = draws, compare = TRUE))
}

#' Compare cumulative dynamic multipliers across models
#' @inheritParams compare_irf
#' @param scale_by Optional scaling mode for CDMs.
#' @param scale_var Optional scaling variable specification.
#' @return A \code{bsvar_post_tbl} combining results across models, with a
#'   \code{model} column identifying each input.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post1 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#' post2 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' comp <- compare_cdm(m1 = post1, m2 = post2, horizon = 3)
#' head(comp)
#' @export
compare_cdm <- function(..., horizon = NULL, probability = 0.90, draws = FALSE,
                        scale_by = c("none", "shock_sd"), scale_var = NULL) {
  models <- collect_models(...)
  out <- lapply(names(models), function(nm) tidy_cdm(models[[nm]], horizon = resolve_horizon(horizon), probability = probability, draws = draws, model = nm, scale_by = scale_by, scale_var = scale_var))
  validate_model_compatibility(out, "compare_cdm")
  set_compare_flag(new_bsvar_post_tbl(do.call(rbind, out), object_type = "cdm", draws = draws, compare = TRUE))
}

#' Compare FEVDs across models
#' @inheritParams compare_irf
#' @return A \code{bsvar_post_tbl} combining results across models, with a
#'   \code{model} column identifying each input.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post1 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#' post2 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' comp <- compare_fevd(m1 = post1, m2 = post2, horizon = 3)
#' head(comp)
#' @export
compare_fevd <- function(..., horizon = NULL, probability = 0.90, draws = FALSE) {
  models <- collect_models(...)
  out <- lapply(names(models), function(nm) tidy_fevd(models[[nm]], horizon = resolve_horizon(horizon), probability = probability, draws = draws, model = nm))
  validate_model_compatibility(out, "compare_fevd")
  set_compare_flag(new_bsvar_post_tbl(do.call(rbind, out), object_type = "fevd", draws = draws, compare = TRUE))
}

#' Compare forecasts across models
#' @inheritParams compare_irf
#' @return A \code{bsvar_post_tbl} combining results across models, with a
#'   \code{model} column identifying each input.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post1 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#' post2 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' comp <- compare_forecast(m1 = post1, m2 = post2, horizon = 3)
#' head(comp)
#' @export
compare_forecast <- function(..., horizon = NULL, probability = 0.90, draws = FALSE) {
  models <- collect_models(...)
  out <- lapply(names(models), function(nm) tidy_forecast(models[[nm]], horizon = resolve_horizon(horizon), probability = probability, draws = draws, model = nm))
  validate_model_compatibility(out, "compare_forecast")
  set_compare_flag(new_bsvar_post_tbl(do.call(rbind, out), object_type = "forecast", draws = draws, compare = TRUE))
}


#' Compare restriction audits across models
#' @param ... Posterior model objects or a named list of model objects.
#' @param restrictions Optional list of restriction helper objects applied to each model.
#' @param zero_tol Numerical tolerance for zero restrictions.
#' @param probability Equal-tailed interval probability used in summaries.
#' @return A \code{bsvar_post_tbl} combining restriction audit results across
#'   models, with a \code{model} column identifying each input.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post1 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#' post2 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' r <- list(irf_restriction("gdp", "gdp", 0, sign = 1))
#' comp <- compare_restrictions(m1 = post1, m2 = post2, restrictions = r)
#' head(comp)
#' @export
compare_restrictions <- function(..., restrictions = NULL, zero_tol = 1e-8, probability = 0.90) {
  models <- collect_models(...)
  out <- lapply(names(models), function(nm) {
    restriction_audit(models[[nm]], restrictions = restrictions, zero_tol = zero_tol, probability = probability, model = nm)
  })
  validate_model_compatibility(out, "compare_restrictions")
  set_compare_flag(new_bsvar_post_tbl(do.call(rbind, out), object_type = "restriction_audit", draws = FALSE, compare = TRUE))
}

#' Compare acceptance diagnostics across models
#' @param ... Posterior model objects or a named list of model objects.
#' @param kernel_tol Numerical tolerance used to classify near-zero admissibility
#'   weights.
#' @param ess_threshold Effective-sample-size threshold below which a warning
#'   flag is raised.
#' @param sparse_threshold Share of near-zero admissibility weights above which a
#'   sparse-support warning flag is raised.
#' @return A \code{bsvar_post_tbl} combining acceptance diagnostic results
#'   across models, with a \code{model} column identifying each input.
#' @examples
#' \donttest{
#' data(optimism, package = "bsvarSIGNs")
#' sign_irf <- matrix(c(1, rep(NA, 3)), 2, 2)
#' spec_s <- suppressMessages(
#'   bsvarSIGNs::specify_bsvarSIGN$new(optimism[, 1:2], p = 1,
#'                                      sign_irf = sign_irf)
#' )
#' post_s1 <- bsvars::estimate(spec_s, S = 5, show_progress = FALSE)
#' post_s2 <- bsvars::estimate(spec_s, S = 5, show_progress = FALSE)
#'
#' comp <- compare_acceptance_diagnostics(m1 = post_s1, m2 = post_s2)
#' print(comp)
#' }
#' @export
compare_acceptance_diagnostics <- function(..., kernel_tol = 1e-12,
                                           ess_threshold = 20,
                                           sparse_threshold = 0.1) {
  models <- collect_models(...)
  out <- lapply(names(models), function(nm) {
    acceptance_diagnostics(models[[nm]], kernel_tol = kernel_tol, ess_threshold = ess_threshold,
                           sparse_threshold = sparse_threshold, model = nm)
  })
  set_compare_flag(new_bsvar_post_tbl(do.call(rbind, out), object_type = "acceptance_diagnostics", draws = FALSE, compare = TRUE))
}


#' Compare event-window historical decompositions across models
#' @param ... Posterior model objects or a named list of model objects.
#' @param start First time index to include.
#' @param end Last time index to include. Defaults to `start`.
#' @param probability Equal-tailed interval probability used in summaries.
#' @param draws If `TRUE`, return draw-level rows.
#' @return A \code{bsvar_post_tbl} combining event-window historical
#'   decomposition results across models, with a \code{model} column
#'   identifying each input.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post1 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#' post2 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' comp <- compare_hd_event(m1 = post1, m2 = post2, start = "1948.25", end = "1948.5")
#' head(comp)
#' @export
compare_hd_event <- function(..., start, end = start, probability = 0.90, draws = FALSE) {
  models <- collect_models(...)
  out <- lapply(names(models), function(nm) {
    tidy_hd_event(models[[nm]], start = start, end = end, probability = probability, draws = draws, model = nm)
  })
  validate_model_compatibility(out, "compare_hd_event")
  set_compare_flag(new_bsvar_post_tbl(do.call(rbind, out), object_type = "hd_event", draws = draws, compare = TRUE))
}


#' Compare peak response summaries across models
#' @param ... Posterior model objects or a named list of model objects.
#' @param horizon Maximum horizon used when `object` is a posterior model object.
#'   If \code{NULL} (default), resolves to 20 periods.
#' @param type Response type for posterior model objects: `"irf"` or `"cdm"`.
#' @param variables Optional response-variable subset.
#' @param shocks Optional shock subset.
#' @param variable Deprecated. Use \code{variables} instead.
#' @param shock Deprecated. Use \code{shocks} instead.
#' @param absolute If `TRUE`, search for the largest absolute response.
#' @param probability Equal-tailed interval probability.
#' @param scale_by Optional scaling mode for CDMs.
#' @param scale_var Optional scaling variable specification.
#' @return A \code{bsvar_post_tbl} combining peak summary results across
#'   models, with a \code{model} column identifying each input.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post1 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#' post2 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' comp <- compare_peak_response(m1 = post1, m2 = post2, horizon = 3)
#' head(comp)
#' @export
compare_peak_response <- function(..., horizon = NULL, type = c("irf", "cdm"),
                                  variables = NULL, shocks = NULL,
                                  variable = NULL, shock = NULL,
                                  absolute = FALSE, probability = 0.90,
                                  scale_by = c("none", "shock_sd"), scale_var = NULL) {
  variables <- deprecate_arg(variables, variable, "variable", "variables", "compare_peak_response")
  shocks    <- deprecate_arg(shocks, shock, "shock", "shocks", "compare_peak_response")
  type <- match.arg(type)
  models <- collect_models(...)
  out <- lapply(names(models), function(nm) {
    peak_response(models[[nm]], horizon = resolve_horizon(horizon), type = type,
                  variables = variables, shocks = shocks,
                  absolute = absolute, probability = probability, model = nm,
                  scale_by = scale_by, scale_var = scale_var)
  })
  validate_model_compatibility(out, "compare_peak_response")
  set_compare_flag(new_bsvar_post_tbl(do.call(rbind, out), object_type = paste0("peak_", type), draws = FALSE, compare = TRUE))
}

#' Compare duration summaries across models
#' @param ... Posterior model objects or a named list of model objects.
#' @param horizon Maximum horizon used when `object` is a posterior model object.
#'   If \code{NULL} (default), resolves to 20 periods.
#' @param type Response type for posterior model objects: `"irf"` or `"cdm"`.
#' @param variables Optional response-variable subset.
#' @param shocks Optional shock subset.
#' @param variable Deprecated. Use \code{variables} instead.
#' @param shock Deprecated. Use \code{shocks} instead.
#' @param relation Comparison operator.
#' @param value Threshold value.
#' @param absolute If `TRUE`, compare absolute responses.
#' @param mode Either `"consecutive"` or `"total"`.
#' @param probability Equal-tailed interval probability.
#' @param scale_by Optional scaling mode for CDMs.
#' @param scale_var Optional scaling variable specification.
#' @return A \code{bsvar_post_tbl} combining duration summary results across
#'   models, with a \code{model} column identifying each input.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post1 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#' post2 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' comp <- compare_duration_response(m1 = post1, m2 = post2, horizon = 3,
#'                                    relation = ">", value = 0)
#' head(comp)
#' @export
compare_duration_response <- function(..., horizon = NULL, type = c("irf", "cdm"),
                                      variables = NULL, shocks = NULL,
                                      variable = NULL, shock = NULL,
                                      relation = c(">", ">=", "<", "<="), value = 0,
                                      absolute = FALSE, mode = c("consecutive", "total"),
                                      probability = 0.90,
                                      scale_by = c("none", "shock_sd"), scale_var = NULL) {
  variables <- deprecate_arg(variables, variable, "variable", "variables", "compare_duration_response")
  shocks    <- deprecate_arg(shocks, shock, "shock", "shocks", "compare_duration_response")
  type <- match.arg(type)
  relation <- match.arg(relation)
  mode <- match.arg(mode)
  models <- collect_models(...)
  out <- lapply(names(models), function(nm) {
    duration_response(models[[nm]], horizon = resolve_horizon(horizon), type = type,
                      variables = variables, shocks = shocks,
                      relation = relation, value = value, absolute = absolute, mode = mode,
                      probability = probability, model = nm, scale_by = scale_by, scale_var = scale_var)
  })
  validate_model_compatibility(out, "compare_duration_response")
  set_compare_flag(new_bsvar_post_tbl(do.call(rbind, out), object_type = paste0("duration_", type), draws = FALSE, compare = TRUE))
}

#' Compare half-life summaries across models
#' @param ... Posterior model objects or a named list of model objects.
#' @param horizon Maximum horizon used when `object` is a posterior model object.
#'   If \code{NULL} (default), resolves to 20 periods.
#' @param type Response type for posterior model objects: `"irf"` or `"cdm"`.
#' @param variables Optional response-variable subset.
#' @param shocks Optional shock subset.
#' @param variable Deprecated. Use \code{variables} instead.
#' @param shock Deprecated. Use \code{shocks} instead.
#' @param fraction Fraction of the reference level used to define the half-life.
#' @param baseline Reference level: `"peak"` or `"initial"`.
#' @param absolute If `TRUE`, compute half-lives using absolute responses.
#' @param probability Equal-tailed interval probability.
#' @param scale_by Optional scaling mode for CDMs.
#' @param scale_var Optional scaling variable specification.
#' @return A \code{bsvar_post_tbl} combining half-life summary results across
#'   models, with a \code{model} column identifying each input.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post1 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#' post2 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' comp <- compare_half_life_response(m1 = post1, m2 = post2, horizon = 3)
#' head(comp)
#' @export
compare_half_life_response <- function(..., horizon = NULL, type = c("irf", "cdm"),
                                       variables = NULL, shocks = NULL,
                                       variable = NULL, shock = NULL,
                                       fraction = 0.5, baseline = c("peak", "initial"),
                                       absolute = TRUE, probability = 0.90,
                                       scale_by = c("none", "shock_sd"), scale_var = NULL) {
  variables <- deprecate_arg(variables, variable, "variable", "variables", "compare_half_life_response")
  shocks    <- deprecate_arg(shocks, shock, "shock", "shocks", "compare_half_life_response")
  type <- match.arg(type)
  baseline <- match.arg(baseline)
  models <- collect_models(...)
  out <- lapply(names(models), function(nm) {
    half_life_response(models[[nm]], horizon = resolve_horizon(horizon), type = type,
                       variables = variables, shocks = shocks,
                       fraction = fraction, baseline = baseline, absolute = absolute,
                       probability = probability, model = nm, scale_by = scale_by, scale_var = scale_var)
  })
  validate_model_compatibility(out, "compare_half_life_response")
  set_compare_flag(new_bsvar_post_tbl(do.call(rbind, out), object_type = paste0("half_life_", type), draws = FALSE, compare = TRUE))
}

#' Compare time-to-threshold summaries across models
#' @param ... Posterior model objects or a named list of model objects.
#' @param horizon Maximum horizon used when `object` is a posterior model object.
#'   If \code{NULL} (default), resolves to 20 periods.
#' @param type Response type for posterior model objects: `"irf"` or `"cdm"`.
#' @param variables Optional response-variable subset.
#' @param shocks Optional shock subset.
#' @param variable Deprecated. Use \code{variables} instead.
#' @param shock Deprecated. Use \code{shocks} instead.
#' @param relation Comparison operator.
#' @param value Threshold value.
#' @param absolute If `TRUE`, compare absolute responses.
#' @param probability Equal-tailed interval probability.
#' @param scale_by Optional scaling mode for CDMs.
#' @param scale_var Optional scaling variable specification.
#' @return A \code{bsvar_post_tbl} combining time-to-threshold summary results
#'   across models, with a \code{model} column identifying each input.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post1 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#' post2 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' comp <- compare_time_to_threshold(m1 = post1, m2 = post2, horizon = 3,
#'                                    relation = ">", value = 0)
#' head(comp)
#' @export
compare_time_to_threshold <- function(..., horizon = NULL, type = c("irf", "cdm"),
                                      variables = NULL, shocks = NULL,
                                      variable = NULL, shock = NULL,
                                      relation = c(">", ">=", "<", "<="), value = 0,
                                      absolute = FALSE, probability = 0.90,
                                      scale_by = c("none", "shock_sd"), scale_var = NULL) {
  variables <- deprecate_arg(variables, variable, "variable", "variables", "compare_time_to_threshold")
  shocks    <- deprecate_arg(shocks, shock, "shock", "shocks", "compare_time_to_threshold")
  type <- match.arg(type)
  relation <- match.arg(relation)
  models <- collect_models(...)
  out <- lapply(names(models), function(nm) {
    time_to_threshold(models[[nm]], horizon = resolve_horizon(horizon), type = type,
                      variables = variables, shocks = shocks,
                      relation = relation, value = value, absolute = absolute,
                      probability = probability, model = nm, scale_by = scale_by, scale_var = scale_var)
  })
  validate_model_compatibility(out, "compare_time_to_threshold")
  set_compare_flag(new_bsvar_post_tbl(do.call(rbind, out), object_type = paste0("time_to_threshold_", type), draws = FALSE, compare = TRUE))
}

validate_model_compatibility <- function(results, fn_name) {
  if (length(results) < 2L) return(invisible(NULL))
  validate_key <- function(column, label) {
    if (!(column %in% names(results[[1]]))) {
      return(invisible(NULL))
    }
    key_sets <- lapply(results, function(r) sort(unique(r[[column]])))
    ref <- key_sets[[1]]
    for (i in seq_along(key_sets)[-1]) {
      if (!identical(key_sets[[i]], ref)) {
        stop(
          "In ", fn_name, "(): models have incompatible ", label, ".\n",
          "Model 1 ", label, ": ", paste(ref, collapse = ", "), "\n",
          "Model ", i, " ", label, ": ", paste(key_sets[[i]], collapse = ", "),
          call. = FALSE
        )
      }
    }
    invisible(NULL)
  }

  validate_key("variable", "variable names")
  validate_key("shock", "shock names")
  validate_key("horizon", "horizon ranges")
  validate_key("time", "time indices")
  invisible(NULL)
}
