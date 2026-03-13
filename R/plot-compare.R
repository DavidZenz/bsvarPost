#' Plot comparison summaries for response-shape tables
#'
#' @param object A comparison table returned by `compare_peak_response()`,
#'   `compare_duration_response()`, `compare_half_life_response()`, or
#'   `compare_time_to_threshold()`.
#' @param measure Which summary measure to plot. Defaults to the main comparison
#'   metric implied by `object`.
#' @param variables Optional variable filter.
#' @param shocks Optional shock filter.
#' @param models Optional model filter.
#' @param facet_scales Facet scales passed to `ggplot2`.
#' @return A \code{ggplot} object.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post1 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#' post2 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' comp <- compare_peak_response(m1 = post1, m2 = post2, horizon = 3)
#' p <- plot_compare_response(comp)
#' @export
plot_compare_response <- function(object, measure = NULL, variables = NULL, shocks = NULL,
                                  models = NULL, facet_scales = "free_y") {
  if (!inherits(object, "bsvar_post_tbl") || !isTRUE(attr(object, "compare"))) {
    stop("`plot_compare_response()` requires a bsvarPost comparison table.", call. = FALSE)
  }

  object_type <- attr(object, "object_type") %||% ""
  spec <- switch(
    object_type,
    peak_irf = list(center = "median_value", lower = "lower_value", upper = "upper_value", ylab = "peak response"),
    peak_cdm = list(center = "median_value", lower = "lower_value", upper = "upper_value", ylab = "peak response"),
    duration_irf = list(center = "median_duration", lower = "lower_duration", upper = "upper_duration", ylab = "duration"),
    duration_cdm = list(center = "median_duration", lower = "lower_duration", upper = "upper_duration", ylab = "duration"),
    half_life_irf = list(center = "median_half_life", lower = "lower_half_life", upper = "upper_half_life", ylab = "half-life"),
    half_life_cdm = list(center = "median_half_life", lower = "lower_half_life", upper = "upper_half_life", ylab = "half-life"),
    time_to_threshold_irf = list(center = "median_horizon", lower = "lower_horizon", upper = "upper_horizon", ylab = "time to threshold"),
    time_to_threshold_cdm = list(center = "median_horizon", lower = "lower_horizon", upper = "upper_horizon", ylab = "time to threshold"),
    NULL
  )

  if (is.null(spec)) {
    stop("`plot_compare_response()` supports compare tables for peak, duration, half-life, and time-to-threshold summaries only.", call. = FALSE)
  }

  if (!is.null(measure)) {
    lower_name <- sub("^median_", "lower_", measure)
    upper_name <- sub("^median_", "upper_", measure)
    if (!all(c(measure, lower_name, upper_name) %in% names(object))) {
      stop("Requested `measure` is not available in `object`.", call. = FALSE)
    }
    spec$center <- measure
    spec$lower <- lower_name
    spec$upper <- upper_name
    spec$ylab <- measure
  }

  df <- object
  if (!is.null(variables)) df <- df[df$variable %in% variables, , drop = FALSE]
  if (!is.null(shocks)) df <- df[df$shock %in% shocks, , drop = FALSE]
  if (!is.null(models)) df <- df[df$model %in% models, , drop = FALSE]
  if (!nrow(df)) {
    stop("No comparison rows remain after filtering.", call. = FALSE)
  }

  p <- ggplot2::ggplot(
    df,
    ggplot2::aes(
      x = .data[["model"]],
      y = .data[[spec$center]],
      ymin = .data[[spec$lower]],
      ymax = .data[[spec$upper]],
      colour = .data[["model"]]
    )
  ) +
    ggplot2::geom_pointrange(position = ggplot2::position_dodge(width = 0.35)) +
    ggplot2::labs(
      x = "model",
      y = spec$ylab,
      colour = if (length(unique(df$model)) > 1L) "model" else NULL
    )

  if ("shock" %in% names(df)) {
    p <- p + ggplot2::facet_grid(rows = ggplot2::vars(variable), cols = ggplot2::vars(shock), scales = facet_scales)
  } else {
    p <- p + ggplot2::facet_wrap(ggplot2::vars(variable), scales = facet_scales)
  }

  template_bsvar_plot(p, family = "comparison")
}

#' Plot comparison summaries for restriction-audit tables
#'
#' @param object A comparison table returned by `compare_restrictions()`.
#' @param models Optional model filter.
#' @param restriction_types Optional restriction-type filter.
#' @param top_n Optional number of highest-probability restrictions to keep
#'   within each model.
#' @return A \code{ggplot} object.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post1 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#' post2 <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' r <- list(irf_restriction("gdp", "gdp", 0, sign = 1))
#' comp <- compare_restrictions(m1 = post1, m2 = post2, restrictions = r)
#' p <- plot_compare_restrictions(comp)
#' @export
plot_compare_restrictions <- function(object, models = NULL, restriction_types = NULL, top_n = NULL) {
  if (!inherits(object, "bsvar_post_tbl") || !isTRUE(attr(object, "compare")) ||
      !identical(attr(object, "object_type"), "restriction_audit")) {
    stop("`plot_compare_restrictions()` requires a restriction-audit comparison table.", call. = FALSE)
  }

  df <- object
  if (!is.null(models)) df <- df[df$model %in% models, , drop = FALSE]
  if (!is.null(restriction_types)) {
    df <- df[df$restriction_type %in% restriction_types, , drop = FALSE]
  }
  if (!nrow(df)) {
    stop("No restriction comparison rows remain after filtering.", call. = FALSE)
  }

  if (!is.null(top_n)) {
    top_n <- validate_positive_count(top_n, "plot_compare_restrictions()", arg = "top_n")
    pieces <- split(df, interaction(df$model, drop = TRUE))
    df <- do.call(rbind, lapply(pieces, function(part) {
      ord <- order(part$posterior_prob, decreasing = TRUE)
      utils::head(part[ord, , drop = FALSE], top_n)
    }))
    rownames(df) <- NULL
  }

  p <- ggplot2::ggplot(
    df,
    ggplot2::aes(
      x = stats::reorder(.data[["restriction"]], .data[["posterior_prob"]]),
      y = .data[["posterior_prob"]],
      fill = .data[["model"]]
    )
  ) +
    ggplot2::geom_col(position = "dodge") +
    ggplot2::coord_flip() +
    ggplot2::labs(
      x = "restriction",
      y = "posterior probability",
      fill = if (length(unique(df$model)) > 1L) "model" else NULL
    )

  if ("restriction_type" %in% names(df)) {
    p <- p + ggplot2::facet_wrap(ggplot2::vars(restriction_type), scales = "free_y")
  }

  template_bsvar_plot(p, family = "comparison")
}
