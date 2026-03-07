#' Peak response summaries for posterior IRFs and CDMs
#'
#' Summarise the peak response level and the horizon at which that peak occurs.
#'
#' @param object A posterior model object, `PosteriorIR`, or `PosteriorCDM`.
#' @param horizon Maximum horizon used when `object` is a posterior model object.
#' @param type Response type for posterior model objects: `"irf"` or `"cdm"`.
#' @param variable Optional response-variable subset.
#' @param shock Optional shock subset.
#' @param absolute If `TRUE`, search for the largest absolute response.
#' @param probability Equal-tailed interval probability.
#' @param model Optional model identifier.
#' @param scale_by Optional scaling mode for CDMs.
#' @param scale_var Optional scaling variable specification.
#' @param ... Additional arguments passed to computation methods.
#' @export
peak_response <- function(object, ...) {
  UseMethod("peak_response")
}

resolve_peak <- function(path, horizons, absolute = FALSE) {
  eval_path <- if (absolute) abs(path) else path
  idx <- which.max(eval_path)
  c(value = path[idx], horizon = horizons[idx])
}

summarise_peak_draws <- function(draws, object_type, variable = NULL, shock = NULL,
                                 absolute = FALSE, probability = 0.68, model = "model1") {
  subset <- subset_response_draws(draws, variables = variable, shocks = shock, horizons = NULL)
  dims <- dim(subset$draws)
  horizons <- as.numeric(subset$labels$horizon)
  combos <- selection_combinations(subset$labels)

  rows <- vector("list", dims[1] * dims[2] * dims[3] / dims[3])
  idx <- 1L
  for (i in seq_len(dims[1])) {
    for (j in seq_len(dims[2])) {
      peak_stats <- t(vapply(seq_len(dims[4]), function(s) {
        resolve_peak(subset$draws[i, j, , s], horizons = horizons, absolute = absolute)
      }, c(value = 0, horizon = 0)))
      value_stats <- summarise_vec(peak_stats[, "value"], probability)
      horizon_stats <- summarise_vec(peak_stats[, "horizon"], probability)
      rows[[idx]] <- tibble::tibble(
        model = model,
        object_type = object_type,
        variable = subset$labels$variable[i],
        shock = subset$labels$shock[j],
        mean_value = value_stats[["mean"]],
        median_value = value_stats[["median"]],
        sd_value = value_stats[["sd"]],
        lower_value = value_stats[["lower"]],
        upper_value = value_stats[["upper"]],
        mean_horizon = horizon_stats[["mean"]],
        median_horizon = horizon_stats[["median"]],
        sd_horizon = horizon_stats[["sd"]],
        lower_horizon = horizon_stats[["lower"]],
        upper_horizon = horizon_stats[["upper"]]
      )
      idx <- idx + 1L
    }
  }

  new_bsvar_post_tbl(do.call(rbind, rows), object_type = object_type, draws = FALSE)
}

#' @export
peak_response.PosteriorIR <- function(object, variable = NULL, shock = NULL, absolute = FALSE,
                                      probability = 0.68, model = "model1", ...) {
  summarise_peak_draws(object, object_type = "peak_irf", variable = variable, shock = shock,
                       absolute = absolute, probability = probability, model = model)
}

peak_response_model <- function(object, horizon = 10, type = c("irf", "cdm"), variable = NULL, shock = NULL,
                                absolute = FALSE, probability = 0.68, model = "model1",
                                scale_by = c("none", "shock_sd"), scale_var = NULL, ...) {
  type <- match.arg(type)
  if (identical(type, "irf")) {
    return(peak_response(get_irf_draws(object, horizon = horizon, ...), variable = variable, shock = shock,
                         absolute = absolute, probability = probability, model = model))
  }
  peak_response(get_cdm_draws(object, horizon = horizon, probability = probability, scale_by = scale_by,
                              scale_var = scale_var, ...), variable = variable, shock = shock,
                absolute = absolute, probability = probability, model = model)
}

#' @export
peak_response.PosteriorBSVAR <- peak_response_model
#' @export
peak_response.PosteriorBSVARMIX <- peak_response_model
#' @export
peak_response.PosteriorBSVARMSH <- peak_response_model
#' @export
peak_response.PosteriorBSVARSV <- peak_response_model
#' @export
peak_response.PosteriorBSVART <- peak_response_model
#' @export
peak_response.PosteriorBSVARSIGN <- peak_response_model
#' @export
peak_response.PosteriorCDM <- function(object, variable = NULL, shock = NULL, absolute = FALSE,
                                       probability = 0.68, model = "model1", ...) {
  summarise_peak_draws(object, object_type = "peak_cdm", variable = variable, shock = shock,
                       absolute = absolute, probability = probability, model = model)
}

#' Duration summaries for posterior IRFs and CDMs
#'
#' Summarise how long a response satisfies a threshold condition over the
#' available horizons.
#'
#' @param mode Either `"consecutive"` for the duration until first violation or
#'   `"total"` for the total count of satisfying horizons.
#' @inheritParams peak_response
#' @param relation Comparison operator.
#' @param value Threshold value.
#' @export
duration_response <- function(object, ...) {
  UseMethod("duration_response")
}

compute_duration <- function(path, relation = c(">", ">=", "<", "<="), value = 0,
                             absolute = FALSE, mode = c("consecutive", "total")) {
  relation <- match.arg(relation)
  mode <- match.arg(mode)
  eval_path <- if (absolute) abs(path) else path
  satisfied <- switch(
    relation,
    ">" = eval_path > value,
    ">=" = eval_path >= value,
    "<" = eval_path < value,
    "<=" = eval_path <= value
  )
  if (identical(mode, "total")) {
    return(sum(satisfied))
  }
  if (!length(satisfied) || !satisfied[1]) {
    return(0)
  }
  first_fail <- which(!satisfied)[1]
  if (is.na(first_fail)) length(satisfied) else first_fail - 1L
}

summarise_duration_draws <- function(draws, object_type, variable = NULL, shock = NULL,
                                     relation = c(">", ">=", "<", "<="), value = 0,
                                     absolute = FALSE, mode = c("consecutive", "total"),
                                     probability = 0.68, model = "model1") {
  relation <- match.arg(relation)
  mode <- match.arg(mode)
  subset <- subset_response_draws(draws, variables = variable, shocks = shock, horizons = NULL)
  dims <- dim(subset$draws)

  rows <- vector("list", dims[1] * dims[2])
  idx <- 1L
  for (i in seq_len(dims[1])) {
    for (j in seq_len(dims[2])) {
      durations <- vapply(seq_len(dims[4]), function(s) {
        compute_duration(subset$draws[i, j, , s], relation = relation, value = value,
                         absolute = absolute, mode = mode)
      }, numeric(1))
      stats <- summarise_vec(durations, probability)
      rows[[idx]] <- tibble::tibble(
        model = model,
        object_type = object_type,
        variable = subset$labels$variable[i],
        shock = subset$labels$shock[j],
        relation = relation,
        threshold = value,
        mode = mode,
        mean_duration = stats[["mean"]],
        median_duration = stats[["median"]],
        sd_duration = stats[["sd"]],
        lower_duration = stats[["lower"]],
        upper_duration = stats[["upper"]]
      )
      idx <- idx + 1L
    }
  }

  new_bsvar_post_tbl(do.call(rbind, rows), object_type = object_type, draws = FALSE)
}

#' @export
duration_response.PosteriorIR <- function(object, variable = NULL, shock = NULL,
                                          relation = c(">", ">=", "<", "<="), value = 0,
                                          absolute = FALSE, mode = c("consecutive", "total"),
                                          probability = 0.68, model = "model1", ...) {
  summarise_duration_draws(object, object_type = "duration_irf", variable = variable, shock = shock,
                           relation = relation, value = value, absolute = absolute, mode = mode,
                           probability = probability, model = model)
}

duration_response_model <- function(object, horizon = 10, type = c("irf", "cdm"), variable = NULL, shock = NULL,
                                        relation = c(">", ">=", "<", "<="), value = 0,
                                        absolute = FALSE, mode = c("consecutive", "total"),
                                        probability = 0.68, model = "model1",
                                        scale_by = c("none", "shock_sd"), scale_var = NULL, ...) {
  type <- match.arg(type)
  if (identical(type, "irf")) {
    return(duration_response(get_irf_draws(object, horizon = horizon, ...), variable = variable, shock = shock,
                             relation = relation, value = value, absolute = absolute, mode = mode,
                             probability = probability, model = model))
  }
  duration_response(get_cdm_draws(object, horizon = horizon, probability = probability, scale_by = scale_by,
                                  scale_var = scale_var, ...), variable = variable, shock = shock,
                    relation = relation, value = value, absolute = absolute, mode = mode,
                    probability = probability, model = model)
}

#' @export
duration_response.PosteriorBSVAR <- duration_response_model
#' @export
duration_response.PosteriorBSVARMIX <- duration_response_model
#' @export
duration_response.PosteriorBSVARMSH <- duration_response_model
#' @export
duration_response.PosteriorBSVARSV <- duration_response_model
#' @export
duration_response.PosteriorBSVART <- duration_response_model
#' @export
duration_response.PosteriorBSVARSIGN <- duration_response_model

#' @export
duration_response.PosteriorCDM <- function(object, variable = NULL, shock = NULL,
                                           relation = c(">", ">=", "<", "<="), value = 0,
                                           absolute = FALSE, mode = c("consecutive", "total"),
                                           probability = 0.68, model = "model1", ...) {
  summarise_duration_draws(object, object_type = "duration_cdm", variable = variable, shock = shock,
                           relation = relation, value = value, absolute = absolute, mode = mode,
                           probability = probability, model = model)
}
