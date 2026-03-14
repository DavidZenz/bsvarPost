#' Plot full-sample historical decomposition components
#'
#' These helpers provide dedicated historical decomposition visualisations for
#' full-sample contribution paths and event-window composition summaries.
#'
#' @name plot_hd_lines
#'
#' @param object A posterior model object, `PosteriorHD`, or a tidy
#'   historical-decomposition table.
#' @param probability Equal-tailed interval probability used when \code{object}
#'   is not already a tidy table.
#' @param variables Optional variable filter.
#' @param shocks Optional shock filter applied before grouping.
#' @param models Optional model filter.
#' @param facet_scales Facet scales passed to \code{ggplot2}.
#' @param include_observed If \code{TRUE}, overlay the observed series when it
#'   can be recovered from a posterior model object.
#' @param include_residual If \code{TRUE}, include a residual/unexplained
#'   component whenever the observed path differs materially from the fitted
#'   contribution sum.
#' @param shock_groups Optional named character vector mapping shock names to
#'   display groups.
#' @param top_n Optional number of largest contributors to retain within each
#'   model-variable panel.
#' @param collapse_other If \code{TRUE}, contributors outside \code{top_n} (or
#'   unmapped shocks under \code{shock_groups}) are collapsed into `"Other"`.
#' @param by One of `"variable"` or `"shock"` for line-based displays.
#' @param stack One of `"signed"` or `"absolute"` for stacked plots.
#' @param start,end Event-window start and end indexes for event-specific plots.
#' @param share One of `"absolute"` or `"signed"` for event share plots.
#' @param ... Additional arguments passed to \code{tidy_hd()} or
#'   \code{tidy_hd_event()} when conversion is required.
#' @return A \code{ggplot} object.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' hd_tbl <- tidy_hd(post)
#' p_lines <- plot_hd_lines(hd_tbl, variables = "gdp")
#' p_overlay <- plot_hd_overlay(post, variables = "gdp")
#' p_stacked <- plot_hd_stacked(post, variables = "gdp")
#' p_total <- plot_hd_total(post, variables = "gdp", shocks = "gs")
#'
#' hd_times <- unique(as.character(tidy_hd(post, draws = TRUE)$time))
#' p_share <- plot_hd_event_share(post, start = hd_times[1], end = hd_times[2])
#' p_cum <- plot_hd_event_cumulative(post, start = hd_times[1], end = hd_times[2])
#' p_dist <- plot_hd_event_distribution(post, start = hd_times[1], end = hd_times[2])
NULL

validate_hd_plot_table <- function(object, caller, object_type = "hd", draws = NULL) {
  if (!inherits(object, "bsvar_post_tbl")) {
    stop("`", caller, "()` requires a bsvarPost tidy table or posterior object.", call. = FALSE)
  }
  if (!identical(attr(object, "object_type"), object_type)) {
    stop("`", caller, "()` requires a tidy table with object_type = '", object_type, "'.", call. = FALSE)
  }
  if (!is.null(draws) && !identical(isTRUE(attr(object, "draws")), draws)) {
    state <- if (draws) "draw-level" else "summary"
    stop("`", caller, "()` requires a ", state, " tidy table.", call. = FALSE)
  }
  invisible(object)
}

is_supported_posterior_model <- function(object) {
  inherits(object, c(
    "PosteriorBSVAR",
    "PosteriorBSVARMIX",
    "PosteriorBSVARMSH",
    "PosteriorBSVARSV",
    "PosteriorBSVART",
    "PosteriorBSVARSIGN"
  ))
}

resolve_hd_summary_table <- function(object, caller, probability = 0.90, model = "model1", ...) {
  if (inherits(object, "bsvar_post_tbl")) {
    validate_hd_plot_table(object, caller = caller, object_type = "hd", draws = FALSE)
    return(object)
  }
  if (inherits(object, "PosteriorHD")) {
    return(tidy_hd(object, probability = probability, draws = FALSE, model = model, ...))
  }
  if (is_supported_posterior_model(object)) {
    return(tidy_hd(object, probability = probability, draws = FALSE, model = model, ...))
  }
  stop(
    "`", caller, "()` requires a posterior model object, PosteriorHD, or a tidy historical decomposition table.",
    call. = FALSE
  )
}

resolve_hd_draw_table <- function(object, caller, probability = 0.90, model = "model1", ...) {
  if (inherits(object, "bsvar_post_tbl")) {
    validate_hd_plot_table(object, caller = caller, object_type = "hd", draws = TRUE)
    return(object)
  }
  if (inherits(object, "PosteriorHD")) {
    return(tidy_hd(object, probability = probability, draws = TRUE, model = model, ...))
  }
  if (is_supported_posterior_model(object)) {
    return(tidy_hd(object, probability = probability, draws = TRUE, model = model, ...))
  }
  stop(
    "`", caller, "()` requires a posterior model object, PosteriorHD, or a draw-level tidy historical decomposition table.",
    call. = FALSE
  )
}

resolve_hd_event_summary_table <- function(object, caller, start = NULL, end = start, probability = 0.90,
                                           model = "model1", ...) {
  if (inherits(object, "bsvar_post_tbl")) {
    validate_hd_plot_table(object, caller = caller, object_type = "hd_event", draws = FALSE)
    return(object)
  }
  if (is.null(start)) {
    stop("`start` must be supplied unless `object` is already a tidy HD event table.", call. = FALSE)
  }
  tidy_hd_event(object, start = start, end = end, probability = probability, draws = FALSE, model = model, ...)
}

resolve_hd_event_draw_table <- function(object, caller, start = NULL, end = start, probability = 0.90,
                                        model = "model1", ...) {
  if (inherits(object, "bsvar_post_tbl")) {
    if (identical(attr(object, "object_type"), "hd_event")) {
      validate_hd_plot_table(object, caller = caller, object_type = "hd_event", draws = TRUE)
      return(object)
    }
    validate_hd_plot_table(object, caller = caller, object_type = "hd", draws = TRUE)
    if (is.null(start)) {
      stop("`start` must be supplied unless `object` is already a draw-level HD event table.", call. = FALSE)
    }
    return(tidy_hd_event(object, start = start, end = end, probability = probability, draws = TRUE))
  }
  if (is.null(start)) {
    stop("`start` must be supplied unless `object` is already a draw-level HD event table.", call. = FALSE)
  }
  tidy_hd_event(object, start = start, end = end, probability = probability, draws = TRUE, model = model, ...)
}

validate_shock_groups <- function(shock_groups, caller) {
  if (is.null(shock_groups)) {
    return(NULL)
  }
  if (!is.character(shock_groups) || is.null(names(shock_groups)) || any(names(shock_groups) == "")) {
    stop("`", caller, "()` requires `shock_groups` to be a named character vector.", call. = FALSE)
  }
  shock_groups
}

map_hd_component <- function(shock, shock_groups = NULL, collapse_other = TRUE) {
  if (is.null(shock_groups)) {
    return(as.character(shock))
  }
  mapped <- unname(shock_groups[as.character(shock)])
  missing <- is.na(mapped)
  mapped[missing] <- if (collapse_other) "Other" else as.character(shock[missing])
  mapped
}

filter_hd_rows <- function(df, variables = NULL, shocks = NULL, models = NULL) {
  if (!is.null(variables) && "variable" %in% names(df)) {
    df <- df[df$variable %in% variables, , drop = FALSE]
  }
  if (!is.null(shocks) && "shock" %in% names(df)) {
    df <- df[df$shock %in% shocks, , drop = FALSE]
  }
  if (!is.null(models) && "model" %in% names(df)) {
    df <- df[df$model %in% models, , drop = FALSE]
  }
  rownames(df) <- NULL
  df
}

normalise_hd_time_axis <- function(df, column = "time") {
  values <- unique(as.character(df[[column]]))
  suppressWarnings(numeric_values <- as.numeric(values))
  if (all(!is.na(numeric_values))) {
    ordered <- order(numeric_values)
    axis <- data.frame(
      label = values[ordered],
      position = numeric_values[ordered],
      stringsAsFactors = FALSE
    )
    df[[paste0(column, "_plot")]] <- numeric_values[match(as.character(df[[column]]), values)]
    return(list(data = df, axis = axis, numeric = TRUE))
  }

  axis <- data.frame(
    label = values,
    position = seq_along(values),
    stringsAsFactors = FALSE
  )
  df[[paste0(column, "_plot")]] <- axis$position[match(as.character(df[[column]]), axis$label)]
  list(data = df, axis = axis, numeric = FALSE)
}

apply_hd_time_scale <- function(plot, axis, numeric_axis) {
  if (isTRUE(numeric_axis)) {
    return(plot)
  }
  plot + ggplot2::scale_x_continuous(breaks = axis$position, labels = axis$label)
}

aggregate_hd_summary_rows <- function(df, group_cols = c("model", "variable", "time", "component")) {
  pieces <- split(df, interaction(df[group_cols], drop = TRUE))
  rows <- lapply(pieces, function(part) {
    tibble::tibble(
      model = part$model[1],
      object_type = attr(df, "object_type") %||% unique(part$object_type)[1],
      variable = part$variable[1],
      component = part$component[1],
      time = if ("time" %in% names(part)) part$time[1] else NULL,
      mean = sum(part$mean, na.rm = TRUE),
      median = sum(part$median, na.rm = TRUE),
      lower = sum(part$lower, na.rm = TRUE),
      upper = sum(part$upper, na.rm = TRUE)
    )
  })
  out <- do.call(rbind, rows)
  if (!"time" %in% group_cols && "time" %in% names(out)) {
    out$time <- NULL
  }
  out
}

aggregate_hd_draw_rows <- function(df, group_cols = c("model", "variable", "time", "component", "draw")) {
  pieces <- split(df, interaction(df[group_cols], drop = TRUE))
  rows <- lapply(pieces, function(part) {
    tibble::tibble(
      model = part$model[1],
      object_type = attr(df, "object_type") %||% unique(part$object_type)[1],
      variable = part$variable[1],
      component = part$component[1],
      time = if ("time" %in% names(part)) part$time[1] else NULL,
      draw = if ("draw" %in% names(part)) part$draw[1] else NULL,
      value = sum(part$value, na.rm = TRUE)
    )
  })
  out <- do.call(rbind, rows)
  if (!"time" %in% group_cols && "time" %in% names(out)) {
    out$time <- NULL
  }
  if (!"draw" %in% group_cols && "draw" %in% names(out)) {
    out$draw <- NULL
  }
  out
}

summarise_hd_draw_table <- function(df, probability = 0.90, time_col = "time") {
  pieces <- split(df, interaction(df$model, df$variable, df$component, df[[time_col]], drop = TRUE))
  rows <- lapply(pieces, function(part) {
    stats <- summarise_vec(part$value, probability)
    tibble::tibble(
      model = part$model[1],
      object_type = unique(part$object_type)[1],
      variable = part$variable[1],
      component = part$component[1],
      time = part[[time_col]][1],
      mean = stats[["mean"]],
      median = stats[["median"]],
      sd = stats[["sd"]],
      lower = stats[["lower"]],
      upper = stats[["upper"]]
    )
  })
  do.call(rbind, rows)
}

summarise_hd_contributors <- function(df, time_col = "time", value_col = "median") {
  split_cols <- interaction(df$model, df$variable, df$component, drop = TRUE)
  pieces <- split(df, split_cols)
  rows <- lapply(pieces, function(part) {
    tibble::tibble(
      model = part$model[1],
      variable = part$variable[1],
      component = part$component[1],
      score = stats::median(abs(part[[value_col]]), na.rm = TRUE)
    )
  })
  do.call(rbind, rows)
}

apply_hd_top_n <- function(df, top_n = NULL, collapse_other = TRUE, value_col = "median") {
  if (is.null(top_n)) {
    return(df)
  }
  top_n <- validate_positive_count(top_n, "HD plotting helper", arg = "top_n")
  scores <- summarise_hd_contributors(df, value_col = value_col)
  pieces <- split(scores, interaction(scores$model, scores$variable, drop = TRUE))
  keepers <- do.call(rbind, lapply(pieces, function(part) {
    part <- part[order(part$score, decreasing = TRUE), , drop = FALSE]
    part$keep <- seq_len(nrow(part)) <= top_n
    part
  }))
  key <- paste(keepers$model, keepers$variable, keepers$component, sep = "\r")
  keep_map <- keepers$keep
  names(keep_map) <- key
  df_key <- paste(df$model, df$variable, df$component, sep = "\r")
  keep <- unname(keep_map[df_key])
  keep[is.na(keep)] <- FALSE

  if (collapse_other) {
    df$component[!keep] <- "Other"
    return(df)
  }

  df[keep, , drop = FALSE]
}

prepare_hd_component_summary <- function(df, shock_groups = NULL, top_n = NULL, collapse_other = TRUE,
                                         probability = 0.90) {
  df$component <- map_hd_component(df$shock, shock_groups = shock_groups, collapse_other = collapse_other)
  df <- apply_hd_top_n(df, top_n = top_n, collapse_other = collapse_other)
  aggregate_hd_summary_rows(df)
}

prepare_hd_component_draws <- function(df, shock_groups = NULL, top_n = NULL, collapse_other = TRUE) {
  df$component <- map_hd_component(df$shock, shock_groups = shock_groups, collapse_other = collapse_other)
  summary_like <- aggregate_hd_draw_rows(df, group_cols = c("model", "variable", "time", "component", "draw"))
  summary_like <- apply_hd_top_n(summary_like, top_n = top_n, collapse_other = collapse_other, value_col = "value")
  aggregate_hd_draw_rows(summary_like, group_cols = c("model", "variable", "time", "component", "draw"))
}

extract_hd_observed_data <- function(object, model = "model1") {
  if (!is_supported_posterior_model(object)) {
    return(NULL)
  }

  y_matrix <- tryCatch(object$last_draw$data_matrices$Y, error = function(e) NULL)
  if (is.null(y_matrix)) {
    return(NULL)
  }

  variable_names <- rownames(y_matrix) %||% paste0("variable", seq_len(nrow(y_matrix)))
  time_names <- colnames(y_matrix) %||% as.character(seq_len(ncol(y_matrix)))

  rows <- vector("list", nrow(y_matrix))
  for (i in seq_len(nrow(y_matrix))) {
    rows[[i]] <- tibble::tibble(
      model = model,
      variable = variable_names[i],
      time = time_names,
      observed = as.numeric(y_matrix[i, ])
    )
  }
  do.call(rbind, rows)
}

build_hd_totals <- function(component_tbl, observed_tbl = NULL, include_residual = TRUE) {
  totals <- split(component_tbl, interaction(component_tbl$model, component_tbl$variable, component_tbl$time, drop = TRUE))
  fitted <- do.call(rbind, lapply(totals, function(part) {
    tibble::tibble(
      model = part$model[1],
      variable = part$variable[1],
      time = part$time[1],
      fitted = sum(part$median, na.rm = TRUE)
    )
  }))

  if (is.null(observed_tbl)) {
    return(list(fitted = fitted, observed = NULL, residual = NULL))
  }

  merged <- merge(fitted, observed_tbl, by = c("model", "variable", "time"), all.x = TRUE, all.y = FALSE, sort = FALSE)
  residual <- merged
  residual$residual <- residual$observed - residual$fitted

  if (!isTRUE(include_residual) || !any(abs(residual$residual) > 1e-8, na.rm = TRUE)) {
    residual <- NULL
  }

  list(
    fitted = fitted,
    observed = observed_tbl,
    residual = residual
  )
}

hd_panel_labels <- function(model, variable) {
  if (length(unique(model)) > 1L) {
    paste0(model, ": ", variable)
  } else {
    as.character(variable)
  }
}

prepare_hd_plot_data <- function(object, probability = 0.90, variables = NULL, shocks = NULL, models = NULL,
                                 include_observed = TRUE, include_residual = TRUE, shock_groups = NULL,
                                 top_n = NULL, collapse_other = TRUE, model = "model1", ...) {
  shock_groups <- validate_shock_groups(shock_groups, "prepare_hd_plot_data")
  summary_tbl <- resolve_hd_summary_table(object, caller = "plot_hd", probability = probability, model = model, ...)
  summary_tbl <- filter_hd_rows(summary_tbl, variables = variables, shocks = shocks, models = models)
  if (!nrow(summary_tbl)) {
    stop("No historical decomposition rows remain after filtering.", call. = FALSE)
  }

  component_tbl <- prepare_hd_component_summary(
    summary_tbl,
    shock_groups = shock_groups,
    top_n = top_n,
    collapse_other = collapse_other,
    probability = probability
  )

  observed_tbl <- NULL
  if (isTRUE(include_observed) && is_supported_posterior_model(object)) {
    observed_tbl <- extract_hd_observed_data(object, model = model)
    observed_tbl <- filter_hd_rows(observed_tbl, variables = variables, models = models)
  }
  totals <- build_hd_totals(component_tbl, observed_tbl = observed_tbl, include_residual = include_residual)
  if (!is.null(totals$residual)) {
    residual_component <- tibble::tibble(
      model = totals$residual$model,
      object_type = "hd",
      variable = totals$residual$variable,
      component = "Residual",
      time = totals$residual$time,
      mean = totals$residual$residual,
      median = totals$residual$residual,
      lower = totals$residual$residual,
      upper = totals$residual$residual
    )
    component_tbl <- rbind(component_tbl, residual_component)
  }

  list(
    components = component_tbl,
    observed = totals$observed,
    fitted = totals$fitted,
    residual = totals$residual
  )
}

prepare_hd_event_plot_data <- function(object, start = NULL, end = start, probability = 0.90, variables = NULL,
                                       shocks = NULL, models = NULL, shock_groups = NULL, top_n = NULL,
                                       collapse_other = TRUE, model = "model1", ...) {
  shock_groups <- validate_shock_groups(shock_groups, "prepare_hd_event_plot_data")
  event_tbl <- resolve_hd_event_summary_table(
    object,
    caller = "plot_hd_event_share",
    start = start,
    end = end,
    probability = probability,
    model = model,
    ...
  )
  event_tbl <- filter_hd_rows(event_tbl, variables = variables, shocks = shocks, models = models)
  if (!nrow(event_tbl)) {
    stop("No event-window historical decomposition rows remain after filtering.", call. = FALSE)
  }
  event_tbl$component <- map_hd_component(event_tbl$shock, shock_groups = shock_groups, collapse_other = collapse_other)
  event_tbl <- apply_hd_top_n(event_tbl, top_n = top_n, collapse_other = collapse_other)

  pieces <- split(event_tbl, interaction(event_tbl$model, event_tbl$variable, event_tbl$component, drop = TRUE))
  rows <- lapply(pieces, function(part) {
    tibble::tibble(
      model = part$model[1],
      object_type = "hd_event",
      variable = part$variable[1],
      component = part$component[1],
      event_start = part$event_start[1],
      event_end = part$event_end[1],
      mean = sum(part$mean, na.rm = TRUE),
      median = sum(part$median, na.rm = TRUE),
      lower = sum(part$lower, na.rm = TRUE),
      upper = sum(part$upper, na.rm = TRUE)
    )
  })
  do.call(rbind, rows)
}

compute_hd_event_shares <- function(event_tbl, share = c("absolute", "signed")) {
  share <- match.arg(share)
  pieces <- split(event_tbl, interaction(event_tbl$model, event_tbl$variable, drop = TRUE))
  rows <- lapply(pieces, function(part) {
    if (identical(share, "absolute")) {
      denom <- sum(abs(part$median), na.rm = TRUE)
      part$share_value <- if (denom > 0) abs(part$median) / denom else 0
    } else {
      denom <- sum(abs(part$median), na.rm = TRUE)
      part$share_value <- if (denom > 0) part$median / denom else 0
    }
    part
  })
  do.call(rbind, rows)
}

compute_hd_event_cumulative <- function(object, start, end = start, probability = 0.90, variables = NULL,
                                        shocks = NULL, models = NULL, shock_groups = NULL, top_n = NULL,
                                        collapse_other = TRUE, model = "model1", ...) {
  draw_tbl <- resolve_hd_draw_table(object, caller = "plot_hd_event_cumulative", probability = probability, model = model, ...)
  draw_tbl <- filter_hd_rows(draw_tbl, variables = variables, shocks = shocks, models = models)
  if (!nrow(draw_tbl)) {
    stop("No historical decomposition draw rows remain after filtering.", call. = FALSE)
  }

  window_labels <- event_window_labels(draw_tbl$time, start = start, end = end)
  draw_tbl <- draw_tbl[as.character(draw_tbl$time) %in% window_labels, , drop = FALSE]
  draw_tbl <- prepare_hd_component_draws(
    draw_tbl,
    shock_groups = shock_groups,
    top_n = top_n,
    collapse_other = collapse_other
  )

  time_order <- match(as.character(draw_tbl$time), window_labels)
  draw_tbl$time_order <- time_order
  pieces <- split(draw_tbl, interaction(draw_tbl$model, draw_tbl$variable, draw_tbl$component, draw_tbl$draw, drop = TRUE))
  cumulative_draws <- do.call(rbind, lapply(pieces, function(part) {
    part <- part[order(part$time_order), , drop = FALSE]
    part$value <- cumsum(part$value)
    part
  }))
  cumulative_draws$time <- factor(as.character(cumulative_draws$time), levels = window_labels, ordered = TRUE)

  summary_tbl <- summarise_hd_draw_table(cumulative_draws, probability = probability)
  list(draws = cumulative_draws, summary = summary_tbl)
}

event_distribution_data <- function(object, start = NULL, end = start, probability = 0.90, variables = NULL,
                                    shocks = NULL, models = NULL, shock_groups = NULL, top_n = NULL,
                                    collapse_other = TRUE, model = "model1", ...) {
  summary_tbl <- prepare_hd_event_plot_data(
    object,
    start = start,
    end = end,
    probability = probability,
    variables = variables,
    shocks = shocks,
    models = models,
    shock_groups = shock_groups,
    top_n = top_n,
    collapse_other = collapse_other,
    model = model,
    ...
  )

  draws_tbl <- tryCatch(
    resolve_hd_event_draw_table(
      object,
      caller = "plot_hd_event_distribution",
      start = start,
      end = end,
      probability = probability,
      model = model,
      ...
    ),
    error = function(e) NULL
  )

  if (is.null(draws_tbl)) {
    return(list(summary = summary_tbl, draws = NULL))
  }

  draws_tbl <- filter_hd_rows(draws_tbl, variables = variables, shocks = shocks, models = models)
  draws_tbl$component <- map_hd_component(draws_tbl$shock, shock_groups = shock_groups, collapse_other = collapse_other)
  draws_tbl <- apply_hd_top_n(draws_tbl, top_n = top_n, collapse_other = collapse_other, value_col = "value")
  draws_tbl <- aggregate_hd_draw_rows(draws_tbl, group_cols = c("model", "variable", "component", "draw"))
  list(summary = summary_tbl, draws = draws_tbl)
}

#' @rdname plot_hd_lines
#' @export
plot_hd_lines <- function(object, probability = 0.90, variables = NULL, shocks = NULL, models = NULL,
                          facet_scales = "free_y", include_observed = TRUE, include_residual = TRUE,
                          shock_groups = NULL, top_n = NULL, collapse_other = TRUE,
                          by = c("variable", "shock"), model = "model1", ...) {
  by <- match.arg(by)
  prepared <- prepare_hd_plot_data(
    object,
    probability = probability,
    variables = variables,
    shocks = shocks,
    models = models,
    include_observed = include_observed,
    include_residual = include_residual,
    shock_groups = shock_groups,
    top_n = top_n,
    collapse_other = collapse_other,
    model = model,
    ...
  )

  df <- normalise_hd_time_axis(prepared$components)
  plot_data <- df$data
  plot_data$component <- factor(plot_data$component, levels = unique(plot_data$component))
  plot_data$panel_variable <- hd_panel_labels(plot_data$model, plot_data$variable)

  p <- ggplot2::ggplot(
    plot_data,
    ggplot2::aes(x = .data[["time_plot"]], y = .data[["median"]], group = 1L)
  ) +
    ggplot2::geom_ribbon(
      ggplot2::aes(ymin = .data[["lower"]], ymax = .data[["upper"]]),
      alpha = 0.14,
      fill = "#a6cee3",
      colour = NA
    ) +
    ggplot2::geom_line(colour = "#1f78b4", linewidth = 0.7) +
    ggplot2::geom_hline(yintercept = 0, linetype = 2, colour = "grey50") +
    ggplot2::theme_minimal() +
    ggplot2::labs(x = "time", y = "contribution")

  if (!is.null(prepared$observed)) {
    observed_df <- normalise_hd_time_axis(prepared$observed)
    observed_data <- observed_df$data
    observed_data$panel_variable <- hd_panel_labels(observed_data$model, observed_data$variable)
    p <- p + ggplot2::geom_line(
      data = observed_data,
      ggplot2::aes(x = .data[["time_plot"]], y = .data[["observed"]]),
      inherit.aes = FALSE,
      colour = "black",
      linewidth = 0.5,
      alpha = 0.7
    )
  }

  if (identical(by, "variable")) {
    p <- p + ggplot2::facet_grid(rows = ggplot2::vars(panel_variable), cols = ggplot2::vars(component), scales = facet_scales)
  } else {
    p <- p + ggplot2::facet_grid(rows = ggplot2::vars(component), cols = ggplot2::vars(panel_variable), scales = facet_scales)
  }

  apply_hd_time_scale(p, df$axis, df$numeric)
}

#' Overlay historical decomposition component paths
#'
#' @inheritParams plot_hd_lines
#' @export
plot_hd_overlay <- function(object, probability = 0.90, variables = NULL, shocks = NULL, models = NULL,
                            facet_scales = "free_y", include_observed = TRUE, include_residual = TRUE,
                            shock_groups = NULL, top_n = NULL, collapse_other = TRUE,
                            by = c("variable", "shock"), model = "model1", ...) {
  by <- match.arg(by)
  prepared <- prepare_hd_plot_data(
    object,
    probability = probability,
    variables = variables,
    shocks = shocks,
    models = models,
    include_observed = include_observed,
    include_residual = include_residual,
    shock_groups = shock_groups,
    top_n = top_n,
    collapse_other = collapse_other,
    model = model,
    ...
  )

  df <- normalise_hd_time_axis(prepared$components)
  plot_data <- df$data
  plot_data$panel_variable <- hd_panel_labels(plot_data$model, plot_data$variable)
  if (identical(by, "variable")) {
    plot_data$panel <- plot_data$panel_variable
    plot_data$series <- plot_data$component
  } else {
    plot_data$panel <- plot_data$component
    plot_data$series <- plot_data$panel_variable
  }

  p <- ggplot2::ggplot(
    plot_data,
    ggplot2::aes(
      x = .data[["time_plot"]],
      y = .data[["median"]],
      colour = .data[["series"]],
      fill = .data[["series"]],
      group = .data[["series"]]
    )
  ) +
    ggplot2::geom_ribbon(
      ggplot2::aes(ymin = .data[["lower"]], ymax = .data[["upper"]]),
      alpha = 0.08,
      colour = NA
    ) +
    ggplot2::geom_line(linewidth = 0.7) +
    ggplot2::geom_hline(yintercept = 0, linetype = 2, colour = "grey50") +
    ggplot2::facet_wrap(ggplot2::vars(panel), scales = facet_scales) +
    ggplot2::theme_minimal() +
    ggplot2::labs(x = "time", y = "contribution", colour = if (identical(by, "variable")) "shock" else "variable",
                  fill = if (identical(by, "variable")) "shock" else "variable")

  if (!is.null(prepared$observed)) {
    observed_df <- normalise_hd_time_axis(prepared$observed)
    observed_data <- observed_df$data
    observed_data$panel_variable <- hd_panel_labels(observed_data$model, observed_data$variable)
    observed_data$panel <- observed_data$panel_variable
    if (identical(by, "variable")) {
      p <- p + ggplot2::geom_line(
        data = observed_data,
        ggplot2::aes(x = .data[["time_plot"]], y = .data[["observed"]]),
        inherit.aes = FALSE,
        colour = "black",
        linewidth = 0.7
      )
    }
  }

  apply_hd_time_scale(p, df$axis, df$numeric)
}

#' Stacked historical decomposition contributions over time
#'
#' @inheritParams plot_hd_lines
#' @export
plot_hd_stacked <- function(object, probability = 0.90, variables = NULL, shocks = NULL, models = NULL,
                            facet_scales = "free_y", include_observed = TRUE, include_residual = TRUE,
                            shock_groups = NULL, top_n = NULL, collapse_other = TRUE,
                            stack = c("signed", "absolute"), model = "model1", ...) {
  stack <- match.arg(stack)
  prepared <- prepare_hd_plot_data(
    object,
    probability = probability,
    variables = variables,
    shocks = shocks,
    models = models,
    include_observed = include_observed,
    include_residual = include_residual,
    shock_groups = shock_groups,
    top_n = top_n,
    collapse_other = collapse_other,
    model = model,
    ...
  )

  df <- normalise_hd_time_axis(prepared$components)
  plot_data <- df$data
  plot_data$panel_variable <- hd_panel_labels(plot_data$model, plot_data$variable)
  plot_data$value <- if (identical(stack, "absolute")) abs(plot_data$median) else plot_data$median

  p <- ggplot2::ggplot(
    plot_data,
    ggplot2::aes(
      x = .data[["time_plot"]],
      y = .data[["value"]],
      fill = .data[["component"]],
      group = .data[["component"]]
    )
  ) +
    ggplot2::geom_area(position = "stack", alpha = 0.82, colour = "white", linewidth = 0.12) +
    ggplot2::facet_wrap(ggplot2::vars(panel_variable), scales = facet_scales) +
    ggplot2::theme_minimal() +
    ggplot2::labs(x = "time", y = if (identical(stack, "absolute")) "absolute contribution" else "contribution",
                  fill = "shock")

  if (!is.null(prepared$observed)) {
    observed_df <- normalise_hd_time_axis(prepared$observed)
    observed_data <- observed_df$data
    observed_data$panel_variable <- hd_panel_labels(observed_data$model, observed_data$variable)
    p <- p + ggplot2::geom_line(
      data = observed_data,
      ggplot2::aes(x = .data[["time_plot"]], y = .data[["observed"]]),
      inherit.aes = FALSE,
      colour = "black",
      linewidth = 0.7
    )
  }

  if (identical(stack, "signed")) {
    p <- p + ggplot2::geom_hline(yintercept = 0, linetype = 2, colour = "grey50")
  }

  apply_hd_time_scale(p, df$axis, df$numeric)
}

#' Plot observed, fitted, and selected decomposition totals
#'
#' @inheritParams plot_hd_lines
#' @export
plot_hd_total <- function(object, probability = 0.90, variables = NULL, shocks = NULL, models = NULL,
                          facet_scales = "free_y", include_observed = TRUE, include_residual = TRUE,
                          shock_groups = NULL, top_n = NULL, collapse_other = TRUE,
                          model = "model1", ...) {
  prepared <- prepare_hd_plot_data(
    object,
    probability = probability,
    variables = variables,
    shocks = shocks,
    models = models,
    include_observed = include_observed,
    include_residual = include_residual,
    shock_groups = shock_groups,
    top_n = top_n,
    collapse_other = collapse_other,
    model = model,
    ...
  )

  if (is.null(prepared$observed)) {
    totals <- prepared$fitted
    totals$observed <- NA_real_
  } else {
    totals <- merge(prepared$fitted, prepared$observed, by = c("model", "variable", "time"), all = TRUE, sort = FALSE)
  }
  totals$series <- "Fitted"
  totals$value <- totals$fitted

  series_rows <- list(totals[, c("model", "variable", "time", "series", "value")])
  if (!all(is.na(totals$observed))) {
    observed_rows <- totals[, c("model", "variable", "time", "observed")]
    names(observed_rows)[names(observed_rows) == "observed"] <- "value"
    observed_rows$series <- "Observed"
    series_rows[[length(series_rows) + 1L]] <- observed_rows[, c("model", "variable", "time", "series", "value")]
  }
  if (!is.null(prepared$residual)) {
    residual_rows <- prepared$residual[, c("model", "variable", "time", "residual")]
    names(residual_rows)[names(residual_rows) == "residual"] <- "value"
    residual_rows$series <- "Residual"
    series_rows[[length(series_rows) + 1L]] <- residual_rows[, c("model", "variable", "time", "series", "value")]
  }
  if (!is.null(shocks) || !is.null(top_n) || !is.null(shock_groups)) {
    component_rows <- prepared$components[, c("model", "variable", "time", "component", "median")]
    names(component_rows)[names(component_rows) == "median"] <- "value"
    component_rows$series <- paste0("Contribution: ", component_rows$component)
    series_rows[[length(series_rows) + 1L]] <- component_rows[, c("model", "variable", "time", "series", "value")]
  }

  plot_data <- do.call(rbind, series_rows)
  time_info <- normalise_hd_time_axis(plot_data)
  plot_data <- time_info$data
  plot_data$panel_variable <- hd_panel_labels(plot_data$model, plot_data$variable)

  manual_cols <- c(Observed = "black", Fitted = "#2166ac", Residual = "#7f7f7f")
  extra_series <- setdiff(unique(plot_data$series), names(manual_cols))
  if (length(extra_series)) {
    manual_cols <- c(manual_cols, setNames(grDevices::hcl.colors(length(extra_series), "Dark 3"), extra_series))
  }

  p <- ggplot2::ggplot(
    plot_data,
    ggplot2::aes(
      x = .data[["time_plot"]],
      y = .data[["value"]],
      colour = .data[["series"]],
      group = .data[["series"]]
    )
  ) +
    ggplot2::geom_line(linewidth = 0.8) +
    ggplot2::scale_colour_manual(values = manual_cols) +
    ggplot2::geom_hline(yintercept = 0, linetype = 2, colour = "grey50") +
    ggplot2::facet_wrap(ggplot2::vars(panel_variable), scales = facet_scales) +
    ggplot2::theme_minimal() +
    ggplot2::labs(x = "time", y = "level", colour = NULL)

  apply_hd_time_scale(p, time_info$axis, time_info$numeric)
}

#' Plot event contribution shares
#'
#' @inheritParams plot_hd_lines
#' @export
plot_hd_event_share <- function(object, start = NULL, end = start, probability = 0.90, variables = NULL,
                                shocks = NULL, models = NULL, shock_groups = NULL, top_n = NULL,
                                collapse_other = TRUE, share = c("absolute", "signed"),
                                facet_scales = "free_y", model = "model1", ...) {
  share <- match.arg(share)
  event_tbl <- prepare_hd_event_plot_data(
    object,
    start = start,
    end = end,
    probability = probability,
    variables = variables,
    shocks = shocks,
    models = models,
    shock_groups = shock_groups,
    top_n = top_n,
    collapse_other = collapse_other,
    model = model,
    ...
  )
  event_tbl <- compute_hd_event_shares(event_tbl, share = share)
  event_tbl$event_label <- ifelse(
    event_tbl$event_start == event_tbl$event_end,
    event_tbl$event_start,
    paste0(event_tbl$event_start, " to ", event_tbl$event_end)
  )
  x_var <- if (length(unique(event_tbl$model)) > 1L) "model" else "event_label"

  p <- ggplot2::ggplot(
    event_tbl,
    ggplot2::aes(x = .data[[x_var]], y = .data[["share_value"]], fill = .data[["component"]])
  ) +
    ggplot2::geom_col(position = "stack") +
    ggplot2::facet_wrap(ggplot2::vars(variable), scales = facet_scales) +
    ggplot2::theme_minimal() +
    ggplot2::labs(x = if (identical(x_var, "model")) "model" else "event window",
                  y = if (identical(share, "absolute")) "absolute share" else "signed share",
                  fill = "shock")

  if (identical(share, "signed")) {
    p <- p + ggplot2::geom_hline(yintercept = 0, linetype = 2, colour = "grey50")
  }

  p
}

#' Plot cumulative event-window contribution paths
#'
#' @inheritParams plot_hd_lines
#' @export
plot_hd_event_cumulative <- function(object, start, end = start, probability = 0.90, variables = NULL,
                                     shocks = NULL, models = NULL, shock_groups = NULL, top_n = NULL,
                                     collapse_other = TRUE, facet_scales = "free_y",
                                     model = "model1", ...) {
  cumulative <- compute_hd_event_cumulative(
    object,
    start = start,
    end = end,
    probability = probability,
    variables = variables,
    shocks = shocks,
    models = models,
    shock_groups = shock_groups,
    top_n = top_n,
    collapse_other = collapse_other,
    model = model,
    ...
  )

  df <- normalise_hd_time_axis(cumulative$summary)
  plot_data <- df$data
  plot_data$panel_variable <- hd_panel_labels(plot_data$model, plot_data$variable)
  p <- ggplot2::ggplot(
    plot_data,
    ggplot2::aes(
      x = .data[["time_plot"]],
      y = .data[["median"]],
      colour = .data[["component"]],
      fill = .data[["component"]],
      group = .data[["component"]]
    )
  ) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin = .data[["lower"]], ymax = .data[["upper"]]), alpha = 0.08, colour = NA) +
    ggplot2::geom_line(linewidth = 0.7) +
    ggplot2::geom_hline(yintercept = 0, linetype = 2, colour = "grey50") +
    ggplot2::facet_wrap(ggplot2::vars(panel_variable), scales = facet_scales) +
    ggplot2::theme_minimal() +
    ggplot2::labs(x = "time", y = "cumulative contribution", colour = "shock", fill = "shock")

  apply_hd_time_scale(p, df$axis, df$numeric)
}

#' Plot event-window contribution uncertainty by shock
#'
#' @inheritParams plot_hd_lines
#' @export
plot_hd_event_distribution <- function(object, start = NULL, end = start, probability = 0.90, variables = NULL,
                                       shocks = NULL, models = NULL, shock_groups = NULL, top_n = NULL,
                                       collapse_other = TRUE, facet_scales = "free_y",
                                       model = "model1", ...) {
  data_parts <- event_distribution_data(
    object,
    start = start,
    end = end,
    probability = probability,
    variables = variables,
    shocks = shocks,
    models = models,
    shock_groups = shock_groups,
    top_n = top_n,
    collapse_other = collapse_other,
    model = model,
    ...
  )

  summary_tbl <- data_parts$summary
  summary_tbl$component <- stats::reorder(summary_tbl$component, summary_tbl$median)
  summary_tbl$panel_variable <- hd_panel_labels(summary_tbl$model, summary_tbl$variable)
  p <- ggplot2::ggplot(
    summary_tbl,
    ggplot2::aes(x = .data[["component"]], y = .data[["median"]], colour = .data[["model"]])
  )

  if (!is.null(data_parts$draws) && any(table(interaction(data_parts$draws$model, data_parts$draws$variable, data_parts$draws$component, drop = TRUE)) >= 10L)) {
    violin_data <- data_parts$draws
    violin_data$component <- factor(violin_data$component, levels = levels(summary_tbl$component))
    p <- p + ggplot2::geom_violin(
      data = violin_data,
      ggplot2::aes(x = .data[["component"]], y = .data[["value"]], fill = .data[["model"]]),
      alpha = 0.15,
      colour = NA,
      inherit.aes = FALSE
    )
  }

  p +
    ggplot2::geom_linerange(
      ggplot2::aes(ymin = .data[["lower"]], ymax = .data[["upper"]]),
      position = ggplot2::position_dodge(width = 0.35),
      linewidth = 0.6
    ) +
    ggplot2::geom_point(position = ggplot2::position_dodge(width = 0.35), size = 2) +
    ggplot2::geom_hline(yintercept = 0, linetype = 2, colour = "grey50") +
    ggplot2::coord_flip() +
    ggplot2::facet_wrap(ggplot2::vars(panel_variable), scales = facet_scales) +
    ggplot2::theme_minimal() +
    ggplot2::labs(x = "shock", y = "event contribution", colour = if (length(unique(summary_tbl$model)) > 1L) "model" else NULL,
                  fill = if (length(unique(summary_tbl$model)) > 1L) "model" else NULL)
}
