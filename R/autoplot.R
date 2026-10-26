#' Plots posterior summaries or draw-level response paths
#'
#' Plots posterior medians and credible intervals from summary tables, or
#' individual paths from supported draw-level response tables. Panels are
#' determined by variables, structural shocks, and model specifications.
#'
#' @param object A `bsvar_post_tbl` containing posterior summaries, supported
#'   draw-level responses, or model comparisons.
#' @param variables Response variables to include.
#' @param shocks Structural shocks to include.
#' @param models Model specifications to include.
#' @param facet_scales Facet scales passed to `ggplot2`.
#' @param ... Unused.
#' @return A \code{ggplot} object.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' irf_tbl <- tidy_irf(post, horizon = 3)
#' p <- ggplot2::autoplot(irf_tbl)
#' @export
autoplot.bsvar_post_tbl <- function(object, variables = NULL, shocks = NULL, models = NULL,
                                    facet_scales = "free_y", ...) {
  df <- object
  if (!is.null(variables) && "variable" %in% names(df)) df <- df[df$variable %in% variables, , drop = FALSE]
  if (!is.null(shocks) && "shock" %in% names(df)) df <- df[df$shock %in% shocks, , drop = FALSE]
  if (!is.null(models) && "model" %in% names(df)) df <- df[df$model %in% models, , drop = FALSE]
  if (!nrow(df)) stop("No posterior rows remain after filtering.", call. = FALSE)

  object_type <- attr(object, "object_type") %||% "value"
  multi_model <- length(unique(df$model)) > 1L
  family <- posterior_plot_family(object)
  if (identical(family, "hypothesis")) return(plot_hypothesis(df))
  if (identical(family, "joint_hypothesis")) return(plot_joint_hypothesis(df))
  if (identical(family, "acceptance_diagnostics")) return(plot_acceptance_diagnostics(df))
  if (identical(family, "restriction_audit")) return(plot_restriction_audit(df))
  if (identical(family, "restriction_comparison")) return(plot_compare_restrictions(df))
  if (identical(family, "response_comparison")) return(plot_compare_response(df, facet_scales = facet_scales))
  if ("gap" %in% names(df) && "satisfied" %in% names(df)) {
    stop("Draw-level hypotheses do not have a supported automatic plot. Summarise them first.", call. = FALSE)
  }
  if (is.null(family)) {
    stop("This posterior table has no supported automatic plot; use a family-specific plot or a summary table.", call. = FALSE)
  }
  has_draws <- isTRUE(attr(object, "draws")) || "draw" %in% names(df)
  required <- c("model", "variable", if (has_draws) "value" else c("median", "lower", "upper"))
  if (!all(required %in% names(df))) {
    stop("Posterior plot input is missing required response columns.", call. = FALSE)
  }

  if (identical(object_type, "hd_event")) {
    x_var <- if ("event_start" %in% names(df)) "event_start" else names(df)[1]
    p <- ggplot2::ggplot(
      df,
      ggplot2::aes(
        x = .data[[x_var]],
        y = .data[["median"]],
        colour = .data[["model"]]
      )
    ) +
      ggplot2::geom_hline(yintercept = 0, linetype = 2, colour = "grey50") +
      ggplot2::geom_linerange(
        ggplot2::aes(ymin = .data[["lower"]], ymax = .data[["upper"]]),
        linewidth = 0.6,
        position = ggplot2::position_dodge(width = 0.35)
      ) +
      ggplot2::geom_point(
        size = 2,
        position = ggplot2::position_dodge(width = 0.35)
      ) +
      ggplot2::theme_minimal() +
      ggplot2::labs(
        x = "event window",
        y = "hd_event",
        colour = if (multi_model) "model" else NULL
      )

    if ("shock" %in% names(df)) {
      p <- p + ggplot2::facet_grid(rows = ggplot2::vars(variable), cols = ggplot2::vars(shock), scales = facet_scales)
    } else {
      p <- p + ggplot2::facet_wrap(ggplot2::vars(variable), scales = facet_scales)
    }

    return(p)
  }

  x_var <- if ("horizon" %in% names(df)) {
    "horizon"
  } else if ("time" %in% names(df)) {
    "time"
  } else if ("event_start" %in% names(df)) {
    "event_start"
  } else {
    names(df)[1]
  }
  has_shock <- "shock" %in% names(df)
  has_draws <- isTRUE(attr(object, "draws")) || "draw" %in% names(df)

  if (has_draws) {
    df$group_id <- tuple_group(df$model, df$draw, drop = TRUE)
    p <- ggplot2::ggplot(
      df,
      ggplot2::aes(
        x = .data[[x_var]],
        y = .data[["value"]],
        group = .data[["group_id"]],
        colour = .data[["model"]]
      )
    ) +
      ggplot2::geom_line(alpha = 0.15)
  } else {
    p <- ggplot2::ggplot(
      df,
      ggplot2::aes(
        x = .data[[x_var]],
        y = .data[["median"]],
        colour = .data[["model"]],
        fill = .data[["model"]]
      )
    ) +
      ggplot2::geom_ribbon(
        ggplot2::aes(ymin = .data[["lower"]], ymax = .data[["upper"]]),
        alpha = 0.18,
        colour = NA
      ) +
      ggplot2::geom_line(linewidth = 0.7)
  }

  p <- p +
    ggplot2::geom_hline(yintercept = 0, linetype = 2, colour = "grey50") +
    ggplot2::theme_minimal() +
    ggplot2::labs(x = x_var, y = object_type,
                  colour = if (multi_model) "model" else NULL,
                  fill = if (multi_model) "model" else NULL)

  if (has_shock) {
    p <- p + ggplot2::facet_grid(rows = ggplot2::vars(variable), cols = ggplot2::vars(shock), scales = facet_scales)
  } else {
    p <- p + ggplot2::facet_wrap(ggplot2::vars(variable), scales = facet_scales)
  }

  p
}

#' @export
plot.bsvar_post_tbl <- function(x, ...) {
  print(ggplot2::autoplot(x, ...))
  invisible(x)
}
