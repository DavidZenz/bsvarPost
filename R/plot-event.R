#' Plot event-window historical decomposition summaries
#'
#' @param object A posterior model object, `PosteriorHD`, or tidy HD event table.
#' @param start First time index to include when `object` is not already an HD
#'   event table.
#' @param end Last time index to include. Defaults to `start`.
#' @param probability Equal-tailed interval probability.
#' @param draws If `TRUE`, plot draw-level event contributions.
#' @param variables Optional variable filter.
#' @param shocks Optional shock filter.
#' @param models Optional model filter.
#' @param facet_scales Facet scales passed to `ggplot2`.
#' @param ... Additional arguments passed to `tidy_hd_event()`.
#' @return A \code{ggplot} object.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' p <- plot_hd_event(post, start = "1948.25", end = "1948.5")
#' @export
plot_hd_event <- function(object, start = NULL, end = start, probability = 0.68, draws = FALSE,
                          variables = NULL, shocks = NULL, models = NULL,
                          facet_scales = "free_y", ...) {
  if (inherits(object, "bsvar_post_tbl")) {
    event_tbl <- object
  } else {
    if (is.null(start)) {
      stop("`start` must be supplied unless `object` is already a tidy HD event table.", call. = FALSE)
    }
    event_tbl <- tidy_hd_event(object, start = start, end = end, probability = probability, draws = draws, ...)
  }

  if (!identical(attr(event_tbl, "object_type"), "hd_event")) {
    stop("`plot_hd_event()` requires an HD event table or an object that can be converted to one.", call. = FALSE)
  }

  ggplot2::autoplot(event_tbl, variables = variables, shocks = shocks, models = models, facet_scales = facet_scales)
}

#' Plot ranked event-window shock contributions
#'
#' @param object A posterior model object, `PosteriorHD`, or tidy shock-ranking table.
#' @param start First time index to include when `object` is not already a shock
#'   ranking table.
#' @param end Last time index to include. Defaults to `start`.
#' @param variables Optional variable filter.
#' @param models Optional model filter.
#' @param ranking One of `"absolute"` or `"signed"`.
#' @param top_n Optional number of top-ranked shocks to keep per model-variable panel.
#' @param probability Equal-tailed interval probability.
#' @param ... Additional arguments passed to `shock_ranking()`.
#' @return A \code{ggplot} object.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' p <- plot_shock_ranking(post, start = "1948.25", end = "1948.5")
#' @export
plot_shock_ranking <- function(object, start = NULL, end = start, variables = NULL, models = NULL,
                               ranking = c("absolute", "signed"), top_n = NULL,
                               probability = 0.68, ...) {
  ranking <- match.arg(ranking)

  if (inherits(object, "bsvar_post_tbl")) {
    rank_tbl <- object
  } else {
    if (is.null(start)) {
      stop("`start` must be supplied unless `object` is already a tidy shock-ranking table.", call. = FALSE)
    }
    rank_tbl <- shock_ranking(object, start = start, end = end, variables = variables, models = models,
                              ranking = ranking, probability = probability, ...)
  }

  if (!identical(attr(rank_tbl, "object_type"), "shock_ranking")) {
    stop("`plot_shock_ranking()` requires a shock-ranking table or an object that can be converted to one.", call. = FALSE)
  }

  df <- rank_tbl
  if (!is.null(variables)) df <- df[df$variable %in% variables, , drop = FALSE]
  if (!is.null(models)) df <- df[df$model %in% models, , drop = FALSE]
  if (!is.null(top_n)) df <- df[df$rank <= as.integer(top_n), , drop = FALSE]

  ggplot2::ggplot(df, ggplot2::aes(x = stats::reorder(shock, rank_score), y = median, fill = model)) +
    ggplot2::geom_col(position = "dodge") +
    ggplot2::geom_hline(yintercept = 0, linetype = 2, colour = "grey50") +
    ggplot2::coord_flip() +
    ggplot2::facet_wrap(ggplot2::vars(variable), scales = "free_y") +
    ggplot2::theme_minimal() +
    ggplot2::labs(x = "shock", y = "median contribution", fill = if (length(unique(df$model)) > 1L) "model" else NULL)
}
