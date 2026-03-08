#' Simultaneous posterior bands for impulse responses
#'
#' Construct simultaneous bands over a selected set of impulse responses using
#' the empirical sup-norm around the posterior median path.
#'
#' @param object A posterior model object or a `PosteriorIR` object.
#' @param horizon Maximum horizon used when `object` is a posterior model object.
#' @param probability Coverage probability for the simultaneous band.
#' @param variable Optional response-variable subset.
#' @param shock Optional shock subset.
#' @param model Optional model identifier.
#' @param ... Additional arguments passed to computation methods.
#' @export
simultaneous_irf <- function(object, ...) {
  UseMethod("simultaneous_irf")
}

simultaneous_band_impl <- function(draws, object_type, probability = 0.68,
                                   variable = NULL, shock = NULL, model = "model1") {
  subset <- subset_response_draws(draws, variables = variable, shocks = shock, horizons = NULL)
  mat <- draw_matrix(subset$draws)
  target <- apply(mat, 1, stats::median)
  max_dev <- apply(abs(mat - target), 2, max)
  crit <- stats::quantile(max_dev, probs = probability, names = FALSE)

  labels <- selection_combinations(subset$labels)
  out <- tibble::tibble(
    model = model,
    object_type = paste0("simultaneous_", object_type),
    variable = labels$variable,
    shock = labels$shock,
    horizon = labels$horizon,
    median = target,
    lower = target - crit,
    upper = target + crit,
    simultaneous_prob = probability,
    critical_value = crit
  )

  new_bsvar_post_tbl(out, object_type = paste0("simultaneous_", object_type), draws = FALSE)
}

#' @rdname simultaneous_irf
#' @export
simultaneous_irf.PosteriorIR <- function(object, probability = 0.68,
                                         variable = NULL, shock = NULL,
                                         model = "model1", ...) {
  simultaneous_band_impl(object, object_type = "irf", probability = probability,
                         variable = variable, shock = shock, model = model)
}

simultaneous_irf_model <- function(object, horizon = 10, probability = 0.68,
                                   variable = NULL, shock = NULL,
                                   model = "model1", ...) {
  simultaneous_irf(get_irf_draws(object, horizon = horizon, ...), probability = probability,
                   variable = variable, shock = shock, model = model)
}

#' @rdname simultaneous_irf
#' @export
simultaneous_irf.PosteriorBSVAR <- simultaneous_irf_model
#' @rdname simultaneous_irf
#' @export
simultaneous_irf.PosteriorBSVARMIX <- simultaneous_irf_model
#' @rdname simultaneous_irf
#' @export
simultaneous_irf.PosteriorBSVARMSH <- simultaneous_irf_model
#' @rdname simultaneous_irf
#' @export
simultaneous_irf.PosteriorBSVARSV <- simultaneous_irf_model
#' @rdname simultaneous_irf
#' @export
simultaneous_irf.PosteriorBSVART <- simultaneous_irf_model
#' @rdname simultaneous_irf
#' @export
simultaneous_irf.PosteriorBSVARSIGN <- simultaneous_irf_model

#' Simultaneous posterior bands for cumulative dynamic multipliers
#'
#' @inheritParams simultaneous_irf
#' @param scale_by Optional scaling mode for CDMs.
#' @param scale_var Optional scaling variable specification.
#' @export
simultaneous_cdm <- function(object, ...) {
  UseMethod("simultaneous_cdm")
}

#' @rdname simultaneous_cdm
#' @export
simultaneous_cdm.PosteriorCDM <- function(object, probability = 0.68,
                                          variable = NULL, shock = NULL,
                                          model = "model1", ...) {
  simultaneous_band_impl(object, object_type = "cdm", probability = probability,
                         variable = variable, shock = shock, model = model)
}

simultaneous_cdm_model <- function(object, horizon = 10, probability = 0.68,
                                   variable = NULL, shock = NULL,
                                   model = "model1",
                                   scale_by = c("none", "shock_sd"), scale_var = NULL, ...) {
  simultaneous_cdm(
    get_cdm_draws(object, horizon = horizon, probability = probability, scale_by = scale_by, scale_var = scale_var, ...),
    probability = probability,
    variable = variable,
    shock = shock,
    model = model
  )
}

#' @rdname simultaneous_cdm
#' @export
simultaneous_cdm.PosteriorBSVAR <- simultaneous_cdm_model
#' @rdname simultaneous_cdm
#' @export
simultaneous_cdm.PosteriorBSVARMIX <- simultaneous_cdm_model
#' @rdname simultaneous_cdm
#' @export
simultaneous_cdm.PosteriorBSVARMSH <- simultaneous_cdm_model
#' @rdname simultaneous_cdm
#' @export
simultaneous_cdm.PosteriorBSVARSV <- simultaneous_cdm_model
#' @rdname simultaneous_cdm
#' @export
simultaneous_cdm.PosteriorBSVART <- simultaneous_cdm_model
#' @rdname simultaneous_cdm
#' @export
simultaneous_cdm.PosteriorBSVARSIGN <- simultaneous_cdm_model

joint_hypothesis_impl <- function(draws, object_type, variable, shock, horizon,
                                  relation = c("<", "<=", ">", ">=", "=="), value = 0,
                                  compare_to = NULL, absolute = FALSE, model = "model1") {
  relation <- match.arg(relation)
  compare_to <- normalise_compare_to(compare_to)
  predicate <- evaluate_draw_predicate(
    draws = draws,
    variable = variable,
    shock = shock,
    horizon = horizon,
    relation = relation,
    value = value,
    compare_to = compare_to,
    absolute = absolute
  )

  combos <- selection_combinations(predicate$labels)
  out <- tibble::tibble(
    model = model,
    object_type = paste0("joint_", object_type),
    relation = relation,
    posterior_prob = mean(apply(predicate$indicator, 2, all)),
    n_constraints = nrow(predicate$indicator),
    variable = paste(unique(combos$variable), collapse = ","),
    shock = paste(unique(combos$shock), collapse = ","),
    horizon = paste(unique(combos$horizon), collapse = ",")
  )

  out <- append_hypothesis_rhs(out, compare_to = predicate$rhs_labels, value = value, absolute = absolute)
  new_bsvar_post_tbl(out, object_type = paste0("joint_", object_type), draws = FALSE)
}

#' Joint posterior probability statements for impulse responses
#'
#' Evaluate whether a set of posterior IRF inequalities holds jointly across all
#' selected variables, shocks, and horizons.
#'
#' @inheritParams hypothesis_irf
#' @param ... Additional arguments passed to computation methods.
#' @export
joint_hypothesis_irf <- function(object, ...) {
  UseMethod("joint_hypothesis_irf")
}

#' @export
joint_hypothesis_irf.PosteriorIR <- function(object, variable, shock, horizon,
                                             relation = c("<", "<=", ">", ">=", "=="), value = 0,
                                             compare_to = NULL, absolute = FALSE,
                                             model = "model1", ...) {
  joint_hypothesis_impl(object, object_type = "irf", variable = variable, shock = shock, horizon = horizon,
                        relation = relation, value = value, compare_to = compare_to,
                        absolute = absolute, model = model)
}

joint_hypothesis_irf_model <- function(object, variable, shock, horizon,
                                       relation = c("<", "<=", ">", ">=", "=="), value = 0,
                                       compare_to = NULL, absolute = FALSE,
                                       model = "model1", ...) {
  irf_draws <- get_irf_draws(object, horizon = response_fetch_horizon(horizon, compare_to), ...)
  joint_hypothesis_irf(irf_draws, variable = variable, shock = shock, horizon = horizon,
                       relation = relation, value = value, compare_to = compare_to,
                       absolute = absolute, model = model)
}

#' @export
joint_hypothesis_irf.PosteriorBSVAR <- joint_hypothesis_irf_model
#' @export
joint_hypothesis_irf.PosteriorBSVARMIX <- joint_hypothesis_irf_model
#' @export
joint_hypothesis_irf.PosteriorBSVARMSH <- joint_hypothesis_irf_model
#' @export
joint_hypothesis_irf.PosteriorBSVARSV <- joint_hypothesis_irf_model
#' @export
joint_hypothesis_irf.PosteriorBSVART <- joint_hypothesis_irf_model
#' @export
joint_hypothesis_irf.PosteriorBSVARSIGN <- joint_hypothesis_irf_model

#' Joint posterior probability statements for cumulative dynamic multipliers
#'
#' @inheritParams joint_hypothesis_irf
#' @inheritParams hypothesis_cdm
#' @export
joint_hypothesis_cdm <- function(object, ...) {
  UseMethod("joint_hypothesis_cdm")
}

#' @export
joint_hypothesis_cdm.PosteriorCDM <- function(object, variable, shock, horizon,
                                              relation = c("<", "<=", ">", ">=", "=="), value = 0,
                                              compare_to = NULL, absolute = FALSE,
                                              model = "model1", ...) {
  joint_hypothesis_impl(object, object_type = "cdm", variable = variable, shock = shock, horizon = horizon,
                        relation = relation, value = value, compare_to = compare_to,
                        absolute = absolute, model = model)
}

joint_hypothesis_cdm_model <- function(object, variable, shock, horizon,
                                       relation = c("<", "<=", ">", ">=", "=="), value = 0,
                                       compare_to = NULL, absolute = FALSE,
                                       model = "model1",
                                       scale_by = c("none", "shock_sd"), scale_var = NULL, ...) {
  cdm_draws <- get_cdm_draws(object, horizon = response_fetch_horizon(horizon, compare_to),
                             scale_by = scale_by, scale_var = scale_var, ...)
  joint_hypothesis_cdm(cdm_draws, variable = variable, shock = shock, horizon = horizon,
                       relation = relation, value = value, compare_to = compare_to,
                       absolute = absolute, model = model)
}

#' @export
joint_hypothesis_cdm.PosteriorBSVAR <- joint_hypothesis_cdm_model
#' @export
joint_hypothesis_cdm.PosteriorBSVARMIX <- joint_hypothesis_cdm_model
#' @export
joint_hypothesis_cdm.PosteriorBSVARMSH <- joint_hypothesis_cdm_model
#' @export
joint_hypothesis_cdm.PosteriorBSVARSV <- joint_hypothesis_cdm_model
#' @export
joint_hypothesis_cdm.PosteriorBSVART <- joint_hypothesis_cdm_model
#' @export
joint_hypothesis_cdm.PosteriorBSVARSIGN <- joint_hypothesis_cdm_model
