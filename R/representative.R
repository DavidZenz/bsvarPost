#' Representative impulse responses
#'
#' Select a representative impulse-response draw from the posterior.
#'
#' @param object A posterior model object or a `PosteriorIR`.
#' @param horizon Forecast horizon when `object` is a posterior model object.
#' @param method Representative-model selection method.
#' @param center Posterior summary used as the target for median-target selection.
#' @param variables Optional subset of response variables.
#' @param shocks Optional subset of shocks.
#' @param horizons Optional subset of horizons.
#' @param metric Distance metric used for median-target selection.
#' @param standardize Optional standardisation used in distance computation.
#' @param probability Equal-tailed interval probability used for summaries.
#' @param ... Additional arguments passed to computation methods.
#' @return A list of class \code{RepresentativeIR} (inheriting from
#'   \code{RepresentativeResponse}) with elements \code{representative_draw}
#'   (the selected IRF array), \code{posterior_draws} (all IRF draws),
#'   \code{draw_index} (integer index of the selected draw), \code{method},
#'   \code{score}, \code{target_summary}, \code{selection_spec},
#'   \code{probability}, and \code{object_type}.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' rep_irf <- representative_irf(post, horizon = 3)
#' rep_irf$draw_index
#' @export
representative_irf <- function(object, ...) {
  UseMethod("representative_irf")
}

#' @rdname representative_irf
#' @export
representative_irf.default <- function(object, ...) {
  stop(
    "representative_irf() requires a posterior model object or PosteriorIR array.\n",
    "Received object of class: ", paste(class(object), collapse = ", "),
    call. = FALSE
  )
}

new_representative_object <- function(draws, selected, object_type, probability = 0.90) {
  structure(
    list(
      representative_draw = selected$representative_draw,
      posterior_draws = draws,
      draw_index = selected$draw_index,
      method = selected$selection_spec$method,
      score = selected$score,
      target_summary = selected$target_summary,
      selection_spec = selected$selection_spec,
      probability = probability,
      object_type = object_type
    ),
    class = c(if (identical(object_type, "irf")) "RepresentativeIR" else "RepresentativeCDM", "RepresentativeResponse")
  )
}

representative_irf_impl <- function(object, draws, horizon = NULL,
                                    method = c("median_target", "most_likely_admissible"),
                                    center = c("median", "mean"), variables = NULL, shocks = NULL, horizons = NULL,
                                    metric = c("l2", "weighted_l2"), standardize = c("none", "sd"),
                                    probability = 0.90, ...) {
  method <- match.arg(method)
  if (identical(method, "most_likely_admissible") && !inherits(object, "PosteriorBSVARSIGN")) {
    stop("`most_likely_admissible` is only supported for 'PosteriorBSVARSIGN' in bsvarPost v0.2.", call. = FALSE)
  }

  selected <- compute_representative_draw(
    draws,
    method = method,
    center = center,
    variables = variables,
    shocks = shocks,
    horizons = horizons,
    metric = metric,
    standardize = standardize,
    object = object,
    object_type = "irf"
  )

  new_representative_object(draws, selected, object_type = "irf", probability = probability)
}

#' @rdname representative_irf
#' @export
representative_irf.PosteriorIR <- function(object, method = c("median_target", "most_likely_admissible"),
                                           center = c("median", "mean"), variables = NULL, shocks = NULL,
                                           horizons = NULL, metric = c("l2", "weighted_l2"),
                                           standardize = c("none", "sd"), probability = 0.90, ...) {
  representative_irf_impl(object, object, method = method, center = center, variables = variables,
                          shocks = shocks, horizons = horizons, metric = metric,
                          standardize = standardize, probability = probability, ...)
}

representative_irf_model <- function(object, horizon = NULL, method = c("median_target", "most_likely_admissible"),
                                     center = c("median", "mean"), variables = NULL, shocks = NULL,
                                     horizons = NULL, metric = c("l2", "weighted_l2"),
                                     standardize = c("none", "sd"), probability = 0.90, ...) {
  draws <- get_irf_draws(object, horizon = resolve_horizon(horizon), ...)
  representative_irf_impl(object, draws, horizon = horizon, method = method, center = center,
                          variables = variables, shocks = shocks, horizons = horizons,
                          metric = metric, standardize = standardize, probability = probability, ...)
}

#' @rdname representative_irf
#' @export
representative_irf.PosteriorBSVAR <- representative_irf_model
#' @export
representative_irf.PosteriorBSVARMIX <- representative_irf_model
#' @export
representative_irf.PosteriorBSVARMSH <- representative_irf_model
#' @export
representative_irf.PosteriorBSVARSV <- representative_irf_model
#' @export
representative_irf.PosteriorBSVART <- representative_irf_model
#' @export
representative_irf.PosteriorBSVARSIGN <- representative_irf_model

#' Representative cumulative dynamic multipliers
#'
#' @inheritParams representative_irf
#' @param scale_by Optional scaling mode for CDMs.
#' @param scale_var Optional scaling variable specification.
#' @return A list of class \code{RepresentativeCDM} (inheriting from
#'   \code{RepresentativeResponse}) with elements \code{representative_draw}
#'   (the selected CDM array), \code{posterior_draws} (all CDM draws),
#'   \code{draw_index} (integer index of the selected draw), \code{method},
#'   \code{score}, \code{target_summary}, \code{selection_spec},
#'   \code{probability}, and \code{object_type}.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' rep_cdm <- representative_cdm(post, horizon = 3)
#' rep_cdm$draw_index
#' @export
representative_cdm <- function(object, ...) {
  UseMethod("representative_cdm")
}

#' @rdname representative_cdm
#' @export
representative_cdm.default <- function(object, ...) {
  stop(
    "representative_cdm() requires a posterior model object or PosteriorCDM array.\n",
    "Received object of class: ", paste(class(object), collapse = ", "),
    call. = FALSE
  )
}

representative_cdm_impl <- function(object, draws, method = c("median_target", "most_likely_admissible"),
                                    center = c("median", "mean"), variables = NULL, shocks = NULL, horizons = NULL,
                                    metric = c("l2", "weighted_l2"), standardize = c("none", "sd"),
                                    probability = 0.90, ...) {
  method <- match.arg(method)
  if (identical(method, "most_likely_admissible") && !inherits(object, "PosteriorBSVARSIGN")) {
    stop("`most_likely_admissible` is only supported for 'PosteriorBSVARSIGN' in bsvarPost v0.2.", call. = FALSE)
  }

  selected <- compute_representative_draw(
    draws,
    method = method,
    center = center,
    variables = variables,
    shocks = shocks,
    horizons = horizons,
    metric = metric,
    standardize = standardize,
    object = object,
    object_type = "cdm"
  )

  new_representative_object(draws, selected, object_type = "cdm", probability = probability)
}

#' @rdname representative_cdm
#' @export
representative_cdm.PosteriorCDM <- function(object, method = c("median_target", "most_likely_admissible"),
                                            center = c("median", "mean"), variables = NULL, shocks = NULL,
                                            horizons = NULL, metric = c("l2", "weighted_l2"),
                                            standardize = c("none", "sd"), probability = 0.90, ...) {
  representative_cdm_impl(object, object, method = method, center = center, variables = variables,
                          shocks = shocks, horizons = horizons, metric = metric,
                          standardize = standardize, probability = probability, ...)
}

representative_cdm_model <- function(object, horizon = NULL, method = c("median_target", "most_likely_admissible"),
                                     center = c("median", "mean"), variables = NULL, shocks = NULL, horizons = NULL,
                                     metric = c("l2", "weighted_l2"), standardize = c("none", "sd"),
                                     probability = 0.90, scale_by = c("none", "shock_sd"), scale_var = NULL, ...) {
  draws <- get_cdm_draws(object, horizon = resolve_horizon(horizon), probability = probability, scale_by = scale_by, scale_var = scale_var, ...)
  representative_cdm_impl(object, draws, method = method, center = center, variables = variables,
                          shocks = shocks, horizons = horizons, metric = metric,
                          standardize = standardize, probability = probability, ...)
}

#' @rdname representative_cdm
#' @export
representative_cdm.PosteriorBSVAR <- representative_cdm_model
#' @export
representative_cdm.PosteriorBSVARMIX <- representative_cdm_model
#' @export
representative_cdm.PosteriorBSVARMSH <- representative_cdm_model
#' @export
representative_cdm.PosteriorBSVARSV <- representative_cdm_model
#' @export
representative_cdm.PosteriorBSVART <- representative_cdm_model
#' @export
representative_cdm.PosteriorBSVARSIGN <- representative_cdm_model

#' @rdname representative_irf
#' @export
median_target_irf <- function(object, ...) {
  representative_irf(object, method = "median_target", ...)
}

#' @rdname representative_cdm
#' @export
median_target_cdm <- function(object, ...) {
  representative_cdm(object, method = "median_target", ...)
}

#' @rdname representative_irf
#' @export
most_likely_admissible_irf <- function(object, ...) {
  representative_irf(object, method = "most_likely_admissible", ...)
}

#' @rdname representative_cdm
#' @export
most_likely_admissible_cdm <- function(object, ...) {
  representative_cdm(object, method = "most_likely_admissible", ...)
}

summary_representative <- function(object) {
  tbl <- as_tidy_response_array(
    object$representative_draw,
    object_type = object$object_type,
    probability = object$probability,
    draws = FALSE
  )
  tbl$draw_index <- object$draw_index
  tbl$method <- object$method
  tbl$score <- object$score
  new_bsvar_post_tbl(tbl, object_type = object$object_type, draws = FALSE)
}

#' @export
summary.RepresentativeIR <- function(object, ...) {
  summary_representative(object)
}

#' @export
summary.RepresentativeCDM <- function(object, ...) {
  summary_representative(object)
}

build_representative_plot <- function(x) {
  posterior_tbl <- as_tidy_response_array(
    x$posterior_draws,
    object_type = x$object_type,
    probability = x$probability,
    draws = FALSE
  )
  rep_tbl <- as_tidy_response_array(
    x$representative_draw,
    object_type = x$object_type,
    probability = x$probability,
    draws = FALSE
  )

  p <- ggplot2::ggplot(
    posterior_tbl,
    ggplot2::aes(x = horizon, y = median)
  ) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin = lower, ymax = upper), alpha = 0.18, fill = "#6baed6") +
    ggplot2::geom_line(colour = "#2171b5", linewidth = 0.6) +
    ggplot2::geom_line(data = rep_tbl, ggplot2::aes(y = median), colour = "#cb181d", linewidth = 0.8) +
    ggplot2::geom_hline(yintercept = 0, linetype = 2, colour = "grey50") +
    ggplot2::theme_minimal() +
    ggplot2::labs(x = "horizon", y = x$object_type)

  if ("shock" %in% names(posterior_tbl)) {
    p <- p + ggplot2::facet_grid(rows = ggplot2::vars(variable), cols = ggplot2::vars(shock), scales = "free_y")
  } else {
    p <- p + ggplot2::facet_wrap(ggplot2::vars(variable), scales = "free_y")
  }

  p
}

plot_representative <- function(x, ...) {
  print(build_representative_plot(x))
  invisible(x)
}

#' @export
plot.RepresentativeIR <- function(x, ...) {
  plot_representative(x, ...)
}

#' @export
plot.RepresentativeCDM <- function(x, ...) {
  plot_representative(x, ...)
}
