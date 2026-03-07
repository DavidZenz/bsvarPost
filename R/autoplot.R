#' Autoplot tidy posterior outputs
#'
#' @param object A `bsvar_post_tbl` returned by the tidy or comparison helpers.
#' @param variables Optional variable filter.
#' @param shocks Optional shock filter.
#' @param models Optional model filter.
#' @param facet_scales Facet scales passed to `ggplot2`.
#' @param ... Unused.
#' @export
autoplot.bsvar_post_tbl <- function(object, variables = NULL, shocks = NULL, models = NULL,
                                    facet_scales = "free_y", ...) {
  df <- object
  if (!is.null(variables) && "variable" %in% names(df)) df <- df[df$variable %in% variables, , drop = FALSE]
  if (!is.null(shocks) && "shock" %in% names(df)) df <- df[df$shock %in% shocks, , drop = FALSE]
  if (!is.null(models) && "model" %in% names(df)) df <- df[df$model %in% models, , drop = FALSE]

  x_var <- if ("horizon" %in% names(df)) "horizon" else "time"
  has_shock <- "shock" %in% names(df)
  has_draws <- isTRUE(attr(object, "draws")) || "draw" %in% names(df)
  multi_model <- length(unique(df$model)) > 1L

  if (has_draws) {
    df$group_id <- interaction(df$model, df$draw, drop = TRUE)
    p <- ggplot2::ggplot(df, ggplot2::aes_string(x = x_var, y = "value",
                                                 group = "group_id",
                                                 colour = "model")) +
      ggplot2::geom_line(alpha = 0.15)
  } else {
    p <- ggplot2::ggplot(df, ggplot2::aes_string(x = x_var, y = "median",
                                                 colour = "model", fill = "model")) +
      ggplot2::geom_ribbon(ggplot2::aes_string(ymin = "lower", ymax = "upper"), alpha = 0.18, colour = NA) +
      ggplot2::geom_line(linewidth = 0.7)
  }

  p <- p +
    ggplot2::geom_hline(yintercept = 0, linetype = 2, colour = "grey50") +
    ggplot2::theme_minimal() +
    ggplot2::labs(x = x_var, y = attr(object, "object_type") %||% "value",
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
