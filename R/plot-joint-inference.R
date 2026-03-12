#' Plot simultaneous posterior bands
#'
#' @param object A simultaneous-band table or an object accepted by
#'   `simultaneous_irf()` / `simultaneous_cdm()`.
#' @param type One of `"irf"` or `"cdm"` when `object` is not already a
#'   simultaneous-band table.
#' @param horizon Maximum horizon used when `object` is a posterior model
#'   object.
#' @param probability Coverage probability for the simultaneous band.
#' @param variable Optional response-variable subset.
#' @param shock Optional shock subset.
#' @param models Optional model filter.
#' @param facet_scales Facet scales passed to `ggplot2`.
#' @param scale_by Optional scaling mode for CDMs.
#' @param scale_var Optional scaling variable specification.
#' @param ... Additional arguments passed to computation methods.
#' @return A \code{ggplot} object.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' p <- plot_simultaneous(post, horizon = 3)
#' @export
plot_simultaneous <- function(object, type = c("irf", "cdm"), horizon = 10, probability = 0.68,
                              variable = NULL, shock = NULL, models = NULL, facet_scales = "free_y",
                              scale_by = c("none", "shock_sd"), scale_var = NULL, ...) {
  type <- match.arg(type)
  if (inherits(object, "bsvar_post_tbl")) {
    tbl <- object
  } else if (identical(type, "irf")) {
    tbl <- simultaneous_irf(object, horizon = horizon, probability = probability,
                            variable = variable, shock = shock, ...)
  } else {
    tbl <- simultaneous_cdm(object, horizon = horizon, probability = probability,
                            variable = variable, shock = shock,
                            scale_by = scale_by, scale_var = scale_var, ...)
  }

  if (!grepl("^simultaneous_", attr(tbl, "object_type"))) {
    stop("`plot_simultaneous()` requires a simultaneous-band table or an object that can be converted to one.", call. = FALSE)
  }

  ggplot2::autoplot(tbl, variables = variable, shocks = shock, models = models, facet_scales = facet_scales)
}

#' Plot joint posterior probability statements
#'
#' @param object A joint-hypothesis table or an object accepted by
#'   `joint_hypothesis_irf()` / `joint_hypothesis_cdm()`.
#' @param type One of `"irf"` or `"cdm"` when `object` is not already a joint
#'   hypothesis table.
#' @param variable Response variable selection on the left-hand side.
#' @param shock Shock selection on the left-hand side.
#' @param horizon Horizon selection on the left-hand side.
#' @param relation Comparison operator.
#' @param value Scalar comparison value for threshold statements.
#' @param compare_to Optional right-hand-side response specification with
#'   elements `variable`, `shock`, and `horizon`.
#' @param absolute If `TRUE`, compare absolute responses.
#' @param scale_by Optional scaling mode for CDMs.
#' @param scale_var Optional scaling variable specification.
#' @param ... Additional arguments passed to computation methods.
#' @return A \code{ggplot} object.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' jh <- joint_hypothesis_irf(post, variable = "gdp", shock = "gdp",
#'                            horizon = 0:2, relation = ">", value = 0)
#' p <- plot_joint_hypothesis(jh)
#' @export
plot_joint_hypothesis <- function(object, type = c("irf", "cdm"),
                                  variable = NULL, shock = NULL, horizon = NULL,
                                  relation = c("<", "<=", ">", ">=", "=="), value = 0,
                                  compare_to = NULL, absolute = FALSE,
                                  scale_by = c("none", "shock_sd"), scale_var = NULL, ...) {
  type <- match.arg(type)
  relation <- match.arg(relation)

  if (inherits(object, "bsvar_post_tbl")) {
    tbl <- object
  } else if (identical(type, "irf")) {
    tbl <- joint_hypothesis_irf(object, variable = variable, shock = shock, horizon = horizon,
                                relation = relation, value = value, compare_to = compare_to,
                                absolute = absolute, ...)
  } else {
    tbl <- joint_hypothesis_cdm(object, variable = variable, shock = shock, horizon = horizon,
                                relation = relation, value = value, compare_to = compare_to,
                                absolute = absolute, scale_by = scale_by, scale_var = scale_var, ...)
  }

  if (!grepl("^joint_", attr(tbl, "object_type"))) {
    stop("`plot_joint_hypothesis()` requires a joint-hypothesis table or an object that can be converted to one.", call. = FALSE)
  }

  ggplot2::ggplot(tbl, ggplot2::aes(x = model, y = posterior_prob, fill = model)) +
    ggplot2::geom_col() +
    ggplot2::geom_hline(yintercept = 0, linetype = 2, colour = "grey50") +
    ggplot2::ylim(0, 1) +
    ggplot2::theme_minimal() +
    ggplot2::labs(x = "model", y = "joint posterior probability", fill = if (length(unique(tbl$model)) > 1L) "model" else NULL)
}
