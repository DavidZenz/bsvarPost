#' Peak response summaries for posterior IRFs and CDMs
#'
#' Summarise the peak response level and the horizon at which that peak occurs.
#'
#' @param object A posterior model object, `PosteriorIR`, or `PosteriorCDM`.
#' @param horizon Maximum horizon used when `object` is a posterior model object.
#' @param type Response type for posterior model objects: `"irf"` or `"cdm"`.
#' @param variables Optional response-variable subset (character or integer vector).
#' @param shocks Optional shock subset (character or integer vector).
#' @param variable **Deprecated.** Use \code{variables} instead.
#' @param shock **Deprecated.** Use \code{shocks} instead.
#' @param absolute If `TRUE`, search for the largest absolute response.
#' @param probability Equal-tailed interval probability.
#' @param model Optional model identifier.
#' @param scale_by Optional scaling mode for CDMs.
#' @param scale_var Optional scaling variable specification.
#' @param ... Additional arguments passed to computation methods.
#' @return A \code{bsvar_post_tbl} with columns \code{model},
#'   \code{object_type}, \code{variable}, \code{shock},
#'   \code{mean_value}, \code{median_value}, \code{sd_value},
#'   \code{lower_value}, \code{upper_value}, \code{mean_horizon},
#'   \code{median_horizon}, \code{sd_horizon}, \code{lower_horizon},
#'   and \code{upper_horizon}.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' pk <- peak_response(post, horizon = 3)
#' print(pk)
#' @export
peak_response <- function(object, ...) {
  UseMethod("peak_response")
}

#' @rdname peak_response
#' @export
peak_response.default <- function(object, ...) {
  stop(
    "peak_response() requires a PosteriorIR or PosteriorCDM array.\n",
    "Received object of class: ", paste(class(object), collapse = ", "),
    call. = FALSE
  )
}

resolve_peak <- function(path, horizons, absolute = FALSE) {
  eval_path <- if (absolute) abs(path) else path
  idx <- which.max(eval_path)
  c(value = path[idx], horizon = horizons[idx])
}

summarise_peak_draws <- function(draws, object_type, variables = NULL, shocks = NULL,
                                 absolute = FALSE, probability = 0.90, model = "model1") {
  subset <- subset_response_draws(draws, variables = variables, shocks = shocks, horizons = NULL)
  dims <- dim(subset$draws)
  horizons <- as.numeric(subset$labels$horizon)

  rows <- vector("list", dims[1] * dims[2])
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

#' @rdname peak_response
#' @export
peak_response.PosteriorIR <- function(object, variables = NULL, shocks = NULL,
                                      variable = NULL, shock = NULL,
                                      absolute = FALSE, probability = 0.90, model = "model1", ...) {
  variables <- deprecate_arg(variables, variable, "variable", "variables", "peak_response")
  shocks <- deprecate_arg(shocks, shock, "shock", "shocks", "peak_response")
  summarise_peak_draws(object, object_type = "peak_irf", variables = variables, shocks = shocks,
                       absolute = absolute, probability = probability, model = model)
}

peak_response_model <- function(object, horizon = NULL, type = c("irf", "cdm"), variables = NULL, shocks = NULL,
                                variable = NULL, shock = NULL,
                                absolute = FALSE, probability = 0.90, model = "model1",
                                scale_by = c("none", "shock_sd"), scale_var = NULL, ...) {
  variables <- deprecate_arg(variables, variable, "variable", "variables", "peak_response")
  shocks <- deprecate_arg(shocks, shock, "shock", "shocks", "peak_response")
  type <- match.arg(type)
  if (identical(type, "irf")) {
    return(peak_response(get_irf_draws(object, horizon = resolve_horizon(horizon), ...), variables = variables, shocks = shocks,
                         absolute = absolute, probability = probability, model = model))
  }
  peak_response(get_cdm_draws(object, horizon = resolve_horizon(horizon), probability = probability, scale_by = scale_by,
                              scale_var = scale_var, ...), variables = variables, shocks = shocks,
                absolute = absolute, probability = probability, model = model)
}

#' @rdname peak_response
#' @export
peak_response.PosteriorBSVAR <- peak_response_model
#' @rdname peak_response
#' @export
peak_response.PosteriorBSVARMIX <- peak_response_model
#' @rdname peak_response
#' @export
peak_response.PosteriorBSVARMSH <- peak_response_model
#' @rdname peak_response
#' @export
peak_response.PosteriorBSVARSV <- peak_response_model
#' @rdname peak_response
#' @export
peak_response.PosteriorBSVART <- peak_response_model
#' @rdname peak_response
#' @export
peak_response.PosteriorBSVARSIGN <- peak_response_model
#' @rdname peak_response
#' @export
peak_response.PosteriorCDM <- function(object, variables = NULL, shocks = NULL,
                                       variable = NULL, shock = NULL,
                                       absolute = FALSE, probability = 0.90, model = "model1", ...) {
  variables <- deprecate_arg(variables, variable, "variable", "variables", "peak_response")
  shocks <- deprecate_arg(shocks, shock, "shock", "shocks", "peak_response")
  summarise_peak_draws(object, object_type = "peak_cdm", variables = variables, shocks = shocks,
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
#' @param variables Optional response-variable subset (character or integer vector).
#' @param shocks Optional shock subset (character or integer vector).
#' @param variable **Deprecated.** Use \code{variables} instead.
#' @param shock **Deprecated.** Use \code{shocks} instead.
#' @param relation Comparison operator.
#' @param value Threshold value.
#' @return A \code{bsvar_post_tbl} with columns \code{model},
#'   \code{object_type}, \code{variable}, \code{shock}, \code{relation},
#'   \code{threshold}, \code{mode}, \code{mean_duration},
#'   \code{median_duration}, \code{sd_duration}, \code{lower_duration},
#'   and \code{upper_duration}.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' dur <- duration_response(post, horizon = 3, relation = ">", value = 0)
#' print(dur)
#' @export
duration_response <- function(object, ...) {
  UseMethod("duration_response")
}

#' @rdname duration_response
#' @export
duration_response.default <- function(object, ...) {
  stop(
    "duration_response() requires a PosteriorIR or PosteriorCDM array.\n",
    "Received object of class: ", paste(class(object), collapse = ", "),
    call. = FALSE
  )
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

summarise_duration_draws <- function(draws, object_type, variables = NULL, shocks = NULL,
                                     relation = c(">", ">=", "<", "<="), value = 0,
                                     absolute = FALSE, mode = c("consecutive", "total"),
                                     probability = 0.90, model = "model1") {
  relation <- match.arg(relation)
  mode <- match.arg(mode)
  subset <- subset_response_draws(draws, variables = variables, shocks = shocks, horizons = NULL)
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

#' @rdname duration_response
#' @export
duration_response.PosteriorIR <- function(object, variables = NULL, shocks = NULL,
                                          variable = NULL, shock = NULL,
                                          relation = c(">", ">=", "<", "<="), value = 0,
                                          absolute = FALSE, mode = c("consecutive", "total"),
                                          probability = 0.90, model = "model1", ...) {
  variables <- deprecate_arg(variables, variable, "variable", "variables", "duration_response")
  shocks <- deprecate_arg(shocks, shock, "shock", "shocks", "duration_response")
  summarise_duration_draws(object, object_type = "duration_irf", variables = variables, shocks = shocks,
                           relation = relation, value = value, absolute = absolute, mode = mode,
                           probability = probability, model = model)
}

duration_response_model <- function(object, horizon = NULL, type = c("irf", "cdm"), variables = NULL, shocks = NULL,
                                    variable = NULL, shock = NULL,
                                    relation = c(">", ">=", "<", "<="), value = 0,
                                    absolute = FALSE, mode = c("consecutive", "total"),
                                    probability = 0.90, model = "model1",
                                    scale_by = c("none", "shock_sd"), scale_var = NULL, ...) {
  variables <- deprecate_arg(variables, variable, "variable", "variables", "duration_response")
  shocks <- deprecate_arg(shocks, shock, "shock", "shocks", "duration_response")
  type <- match.arg(type)
  if (identical(type, "irf")) {
    return(duration_response(get_irf_draws(object, horizon = resolve_horizon(horizon), ...), variables = variables, shocks = shocks,
                             relation = relation, value = value, absolute = absolute, mode = mode,
                             probability = probability, model = model))
  }
  duration_response(get_cdm_draws(object, horizon = resolve_horizon(horizon), probability = probability, scale_by = scale_by,
                                  scale_var = scale_var, ...), variables = variables, shocks = shocks,
                    relation = relation, value = value, absolute = absolute, mode = mode,
                    probability = probability, model = model)
}

#' @rdname duration_response
#' @export
duration_response.PosteriorBSVAR <- duration_response_model
#' @rdname duration_response
#' @export
duration_response.PosteriorBSVARMIX <- duration_response_model
#' @rdname duration_response
#' @export
duration_response.PosteriorBSVARMSH <- duration_response_model
#' @rdname duration_response
#' @export
duration_response.PosteriorBSVARSV <- duration_response_model
#' @rdname duration_response
#' @export
duration_response.PosteriorBSVART <- duration_response_model
#' @rdname duration_response
#' @export
duration_response.PosteriorBSVARSIGN <- duration_response_model

#' @rdname duration_response
#' @export
duration_response.PosteriorCDM <- function(object, variables = NULL, shocks = NULL,
                                           variable = NULL, shock = NULL,
                                           relation = c(">", ">=", "<", "<="), value = 0,
                                           absolute = FALSE, mode = c("consecutive", "total"),
                                           probability = 0.90, model = "model1", ...) {
  variables <- deprecate_arg(variables, variable, "variable", "variables", "duration_response")
  shocks <- deprecate_arg(shocks, shock, "shock", "shocks", "duration_response")
  summarise_duration_draws(object, object_type = "duration_cdm", variables = variables, shocks = shocks,
                           relation = relation, value = value, absolute = absolute, mode = mode,
                           probability = probability, model = model)
}

summarise_optional_timing <- function(x, probability) {
  valid <- x[!is.na(x)]
  reached_prob <- if (length(x)) mean(!is.na(x)) else NA_real_
  if (!length(valid)) {
    return(c(mean = NA_real_, median = NA_real_, sd = NA_real_, lower = NA_real_, upper = NA_real_, reached_prob = reached_prob))
  }
  probs <- summary_probs(probability)
  stats <- c(
    mean = mean(valid),
    median = stats::median(valid),
    sd = stats::sd(valid),
    lower = stats::quantile(valid, probs = probs[1], names = FALSE),
    upper = stats::quantile(valid, probs = probs[2], names = FALSE)
  )
  c(stats, reached_prob = reached_prob)
}

#' Half-life summaries for posterior IRFs and CDMs
#'
#' Summarise the first horizon at which a response falls to a chosen fraction of
#' its initial or peak level.
#'
#' @param fraction Fraction of the reference level used to define the half-life.
#' @param baseline Reference level: `"peak"` uses the largest response over the
#'   available horizons, `"initial"` uses the horizon-0 response.
#' @inheritParams peak_response
#' @param variables Optional response-variable subset (character or integer vector).
#' @param shocks Optional shock subset (character or integer vector).
#' @param variable **Deprecated.** Use \code{variables} instead.
#' @param shock **Deprecated.** Use \code{shocks} instead.
#' @return A \code{bsvar_post_tbl} with columns \code{model},
#'   \code{object_type}, \code{variable}, \code{shock}, \code{fraction},
#'   \code{baseline}, \code{mean_half_life}, \code{median_half_life},
#'   \code{sd_half_life}, \code{lower_half_life}, \code{upper_half_life},
#'   and \code{reached_prob}.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' hl <- half_life_response(post, horizon = 3)
#' print(hl)
#' @export
half_life_response <- function(object, ...) {
  UseMethod("half_life_response")
}

#' @rdname half_life_response
#' @export
half_life_response.default <- function(object, ...) {
  stop(
    "half_life_response() requires a PosteriorIR or PosteriorCDM array.\n",
    "Received object of class: ", paste(class(object), collapse = ", "),
    call. = FALSE
  )
}

compute_half_life <- function(path, horizons, fraction = 0.5,
                              baseline = c("peak", "initial"), absolute = TRUE) {
  baseline <- match.arg(baseline)
  eval_path <- if (absolute) abs(path) else path
  if (!length(eval_path) || anyNA(eval_path)) {
    return(NA_real_)
  }

  if (identical(baseline, "peak")) {
    ref_idx <- which.max(eval_path)
  } else {
    ref_idx <- 1L
  }
  ref_value <- eval_path[ref_idx]
  if (is.na(ref_value) || ref_value <= 0) {
    return(NA_real_)
  }

  target <- fraction * ref_value
  tail_idx <- seq.int(ref_idx, length(eval_path))
  hit <- tail_idx[eval_path[tail_idx] <= target][1]
  if (is.na(hit)) {
    return(NA_real_)
  }
  horizons[hit] - horizons[ref_idx]
}

summarise_half_life_draws <- function(draws, object_type, variables = NULL, shocks = NULL,
                                      fraction = 0.5, baseline = c("peak", "initial"),
                                      absolute = TRUE, probability = 0.90, model = "model1") {
  baseline <- match.arg(baseline)
  subset <- subset_response_draws(draws, variables = variables, shocks = shocks, horizons = NULL)
  dims <- dim(subset$draws)
  horizons <- as.numeric(subset$labels$horizon)

  rows <- vector("list", dims[1] * dims[2])
  idx <- 1L
  for (i in seq_len(dims[1])) {
    for (j in seq_len(dims[2])) {
      values <- vapply(seq_len(dims[4]), function(s) {
        compute_half_life(subset$draws[i, j, , s], horizons = horizons, fraction = fraction,
                          baseline = baseline, absolute = absolute)
      }, numeric(1))
      stats <- summarise_optional_timing(values, probability)
      rows[[idx]] <- tibble::tibble(
        model = model,
        object_type = object_type,
        variable = subset$labels$variable[i],
        shock = subset$labels$shock[j],
        fraction = fraction,
        baseline = baseline,
        mean_half_life = stats[["mean"]],
        median_half_life = stats[["median"]],
        sd_half_life = stats[["sd"]],
        lower_half_life = stats[["lower"]],
        upper_half_life = stats[["upper"]],
        reached_prob = stats[["reached_prob"]]
      )
      idx <- idx + 1L
    }
  }

  new_bsvar_post_tbl(do.call(rbind, rows), object_type = object_type, draws = FALSE)
}

#' @rdname half_life_response
#' @export
half_life_response.PosteriorIR <- function(object, variables = NULL, shocks = NULL,
                                           variable = NULL, shock = NULL,
                                           fraction = 0.5, baseline = c("peak", "initial"),
                                           absolute = TRUE, probability = 0.90, model = "model1", ...) {
  variables <- deprecate_arg(variables, variable, "variable", "variables", "half_life_response")
  shocks <- deprecate_arg(shocks, shock, "shock", "shocks", "half_life_response")
  summarise_half_life_draws(object, object_type = "half_life_irf", variables = variables, shocks = shocks,
                            fraction = fraction, baseline = baseline, absolute = absolute,
                            probability = probability, model = model)
}

half_life_response_model <- function(object, horizon = NULL, type = c("irf", "cdm"), variables = NULL, shocks = NULL,
                                     variable = NULL, shock = NULL,
                                     fraction = 0.5, baseline = c("peak", "initial"),
                                     absolute = TRUE, probability = 0.90, model = "model1",
                                     scale_by = c("none", "shock_sd"), scale_var = NULL, ...) {
  variables <- deprecate_arg(variables, variable, "variable", "variables", "half_life_response")
  shocks <- deprecate_arg(shocks, shock, "shock", "shocks", "half_life_response")
  type <- match.arg(type)
  if (identical(type, "irf")) {
    return(half_life_response(get_irf_draws(object, horizon = resolve_horizon(horizon), ...), variables = variables, shocks = shocks,
                              fraction = fraction, baseline = baseline, absolute = absolute,
                              probability = probability, model = model))
  }
  half_life_response(get_cdm_draws(object, horizon = resolve_horizon(horizon), probability = probability, scale_by = scale_by,
                                   scale_var = scale_var, ...), variables = variables, shocks = shocks,
                     fraction = fraction, baseline = baseline, absolute = absolute,
                     probability = probability, model = model)
}

#' @rdname half_life_response
#' @export
half_life_response.PosteriorBSVAR <- half_life_response_model
#' @rdname half_life_response
#' @export
half_life_response.PosteriorBSVARMIX <- half_life_response_model
#' @rdname half_life_response
#' @export
half_life_response.PosteriorBSVARMSH <- half_life_response_model
#' @rdname half_life_response
#' @export
half_life_response.PosteriorBSVARSV <- half_life_response_model
#' @rdname half_life_response
#' @export
half_life_response.PosteriorBSVART <- half_life_response_model
#' @rdname half_life_response
#' @export
half_life_response.PosteriorBSVARSIGN <- half_life_response_model
#' @rdname half_life_response
#' @export
half_life_response.PosteriorCDM <- function(object, variables = NULL, shocks = NULL,
                                            variable = NULL, shock = NULL,
                                            fraction = 0.5, baseline = c("peak", "initial"),
                                            absolute = TRUE, probability = 0.90, model = "model1", ...) {
  variables <- deprecate_arg(variables, variable, "variable", "variables", "half_life_response")
  shocks <- deprecate_arg(shocks, shock, "shock", "shocks", "half_life_response")
  summarise_half_life_draws(object, object_type = "half_life_cdm", variables = variables, shocks = shocks,
                            fraction = fraction, baseline = baseline, absolute = absolute,
                            probability = probability, model = model)
}

#' Time-to-threshold summaries for posterior IRFs and CDMs
#'
#' Summarise the first horizon at which a response satisfies a threshold
#' condition.
#'
#' @inheritParams duration_response
#' @inheritParams peak_response
#' @param variables Optional response-variable subset (character or integer vector).
#' @param shocks Optional shock subset (character or integer vector).
#' @param variable **Deprecated.** Use \code{variables} instead.
#' @param shock **Deprecated.** Use \code{shocks} instead.
#' @return A \code{bsvar_post_tbl} with columns \code{model},
#'   \code{object_type}, \code{variable}, \code{shock}, \code{relation},
#'   \code{threshold}, \code{mean_horizon}, \code{median_horizon},
#'   \code{sd_horizon}, \code{lower_horizon}, \code{upper_horizon},
#'   and \code{reached_prob}.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' ttt <- time_to_threshold(post, horizon = 3, relation = ">", value = 0)
#' print(ttt)
#' @export
time_to_threshold <- function(object, ...) {
  UseMethod("time_to_threshold")
}

#' @rdname time_to_threshold
#' @export
time_to_threshold.default <- function(object, ...) {
  stop(
    "time_to_threshold() requires a PosteriorIR or PosteriorCDM array.\n",
    "Received object of class: ", paste(class(object), collapse = ", "),
    call. = FALSE
  )
}

compute_time_to_threshold <- function(path, horizons, relation = c(">", ">=", "<", "<="), value = 0,
                                      absolute = FALSE) {
  relation <- match.arg(relation)
  eval_path <- if (absolute) abs(path) else path
  satisfied <- switch(
    relation,
    ">" = eval_path > value,
    ">=" = eval_path >= value,
    "<" = eval_path < value,
    "<=" = eval_path <= value
  )
  hit <- which(satisfied)[1]
  if (is.na(hit)) {
    return(NA_real_)
  }
  horizons[hit]
}

summarise_threshold_draws <- function(draws, object_type, variables = NULL, shocks = NULL,
                                      relation = c(">", ">=", "<", "<="), value = 0,
                                      absolute = FALSE, probability = 0.90, model = "model1") {
  relation <- match.arg(relation)
  subset <- subset_response_draws(draws, variables = variables, shocks = shocks, horizons = NULL)
  dims <- dim(subset$draws)
  horizons <- as.numeric(subset$labels$horizon)

  rows <- vector("list", dims[1] * dims[2])
  idx <- 1L
  for (i in seq_len(dims[1])) {
    for (j in seq_len(dims[2])) {
      values <- vapply(seq_len(dims[4]), function(s) {
        compute_time_to_threshold(subset$draws[i, j, , s], horizons = horizons,
                                  relation = relation, value = value, absolute = absolute)
      }, numeric(1))
      stats <- summarise_optional_timing(values, probability)
      rows[[idx]] <- tibble::tibble(
        model = model,
        object_type = object_type,
        variable = subset$labels$variable[i],
        shock = subset$labels$shock[j],
        relation = relation,
        threshold = value,
        mean_horizon = stats[["mean"]],
        median_horizon = stats[["median"]],
        sd_horizon = stats[["sd"]],
        lower_horizon = stats[["lower"]],
        upper_horizon = stats[["upper"]],
        reached_prob = stats[["reached_prob"]]
      )
      idx <- idx + 1L
    }
  }

  new_bsvar_post_tbl(do.call(rbind, rows), object_type = object_type, draws = FALSE)
}

#' @rdname time_to_threshold
#' @export
time_to_threshold.PosteriorIR <- function(object, variables = NULL, shocks = NULL,
                                          variable = NULL, shock = NULL,
                                          relation = c(">", ">=", "<", "<="), value = 0,
                                          absolute = FALSE, probability = 0.90, model = "model1", ...) {
  variables <- deprecate_arg(variables, variable, "variable", "variables", "time_to_threshold")
  shocks <- deprecate_arg(shocks, shock, "shock", "shocks", "time_to_threshold")
  summarise_threshold_draws(object, object_type = "time_to_threshold_irf", variables = variables, shocks = shocks,
                            relation = relation, value = value, absolute = absolute,
                            probability = probability, model = model)
}

time_to_threshold_model <- function(object, horizon = NULL, type = c("irf", "cdm"), variables = NULL, shocks = NULL,
                                    variable = NULL, shock = NULL,
                                    relation = c(">", ">=", "<", "<="), value = 0,
                                    absolute = FALSE, probability = 0.90, model = "model1",
                                    scale_by = c("none", "shock_sd"), scale_var = NULL, ...) {
  variables <- deprecate_arg(variables, variable, "variable", "variables", "time_to_threshold")
  shocks <- deprecate_arg(shocks, shock, "shock", "shocks", "time_to_threshold")
  type <- match.arg(type)
  if (identical(type, "irf")) {
    return(time_to_threshold(get_irf_draws(object, horizon = resolve_horizon(horizon), ...), variables = variables, shocks = shocks,
                             relation = relation, value = value, absolute = absolute,
                             probability = probability, model = model))
  }
  time_to_threshold(get_cdm_draws(object, horizon = resolve_horizon(horizon), probability = probability, scale_by = scale_by,
                                  scale_var = scale_var, ...), variables = variables, shocks = shocks,
                    relation = relation, value = value, absolute = absolute,
                    probability = probability, model = model)
}

#' @rdname time_to_threshold
#' @export
time_to_threshold.PosteriorBSVAR <- time_to_threshold_model
#' @rdname time_to_threshold
#' @export
time_to_threshold.PosteriorBSVARMIX <- time_to_threshold_model
#' @rdname time_to_threshold
#' @export
time_to_threshold.PosteriorBSVARMSH <- time_to_threshold_model
#' @rdname time_to_threshold
#' @export
time_to_threshold.PosteriorBSVARSV <- time_to_threshold_model
#' @rdname time_to_threshold
#' @export
time_to_threshold.PosteriorBSVART <- time_to_threshold_model
#' @rdname time_to_threshold
#' @export
time_to_threshold.PosteriorBSVARSIGN <- time_to_threshold_model
#' @rdname time_to_threshold
#' @export
time_to_threshold.PosteriorCDM <- function(object, variables = NULL, shocks = NULL,
                                           variable = NULL, shock = NULL,
                                           relation = c(">", ">=", "<", "<="), value = 0,
                                           absolute = FALSE, probability = 0.90, model = "model1", ...) {
  variables <- deprecate_arg(variables, variable, "variable", "variables", "time_to_threshold")
  shocks <- deprecate_arg(shocks, shock, "shock", "shocks", "time_to_threshold")
  summarise_threshold_draws(object, object_type = "time_to_threshold_cdm", variables = variables, shocks = shocks,
                            relation = relation, value = value, absolute = absolute,
                            probability = probability, model = model)
}
