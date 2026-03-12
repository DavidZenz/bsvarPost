#' Autoplot tidy posterior outputs
#'
#' @param object A `bsvar_post_tbl` returned by the tidy or comparison helpers.
#' @param variables Optional variable filter.
#' @param shocks Optional shock filter.
#' @param models Optional model filter.
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

  object_type <- attr(object, "object_type") %||% "value"
  multi_model <- length(unique(df$model)) > 1L

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
    df$group_id <- interaction(df$model, df$draw, drop = TRUE)
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
