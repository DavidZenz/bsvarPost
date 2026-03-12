#' Tidy event-window historical decompositions
#'
#' Aggregate historical decomposition draws or summaries over a selected event
#' window.
#'
#' @param object A posterior model object, `PosteriorHD`, or tidy historical
#'   decomposition table.
#' @param start First time index to include.
#' @param end Last time index to include. Defaults to `start`.
#' @param probability Equal-tailed interval probability.
#' @param draws If `TRUE`, return draw-level cumulative contributions.
#' @param model Optional model identifier.
#' @param ... Additional arguments passed to computation methods.
#' @return A \code{bsvar_post_tbl} with columns \code{model},
#'   \code{object_type}, \code{variable}, \code{shock}, \code{event_start},
#'   \code{event_end}, \code{median}, \code{mean}, \code{sd}, \code{lower},
#'   and \code{upper}.  When \code{draws = TRUE}, columns \code{draw} and
#'   \code{value} replace the summary statistics.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' hd_event <- tidy_hd_event(post, start = 2, end = 3)
#' head(hd_event)
#' @export
 tidy_hd_event <- function(object, ...) UseMethod("tidy_hd_event")

#' @rdname tidy_hd_event
#' @export
 tidy_hd_event.default <- function(object, ...) {
  stop(
    "tidy_hd_event() requires a posterior model object, PosteriorHD array, or tidy HD table.\n",
    "Received object of class: ", paste(class(object), collapse = ", "),
    call. = FALSE
  )
 }

event_window_labels <- function(times, start, end = start) {
  labels <- unique(as.character(times))
  start_chr <- as.character(start)
  end_chr <- as.character(end)
  start_idx <- match(start_chr, labels)
  end_idx <- match(end_chr, labels)
  if (is.na(start_idx) || is.na(end_idx)) {
    stop("No historical decomposition observations found in the requested event window.", call. = FALSE)
  }
  labels[seq.int(start_idx, end_idx)]
}

summarise_hd_event_tbl <- function(tbl, start, end = start, probability = 0.68, draws = FALSE) {
  window_labels <- event_window_labels(tbl$time, start = start, end = end)
  time_chr <- as.character(tbl$time)
  keep <- time_chr %in% window_labels
  df <- tbl[keep, , drop = FALSE]

  if (isTRUE(attr(tbl, "draws")) || "draw" %in% names(df)) {
    if (!"draw" %in% names(df)) {
      stop("Draw-level event summaries require a draw-level historical decomposition table.", call. = FALSE)
    }
    parts <- split(df, interaction(df$model, df$variable, df$shock, df$draw, drop = TRUE))
    rows <- lapply(parts, function(part) {
      tibble::tibble(
        model = part$model[1],
        object_type = "hd_event",
        variable = part$variable[1],
        shock = part$shock[1],
        event_start = as.character(start),
        event_end = as.character(end),
        draw = part$draw[1],
        value = sum(part$value)
      )
    })
    return(new_bsvar_post_tbl(do.call(rbind, rows), object_type = "hd_event", draws = TRUE))
  }

  hd_draws <- tidy_hd(tbl, draws = TRUE)
  tidy_hd_event(hd_draws, start = start, end = end, probability = probability, draws = draws)
}

#' @rdname tidy_hd_event
#' @export
 tidy_hd_event.bsvar_post_tbl <- function(object, start, end = start, probability = 0.68, draws = FALSE, ...) {
  if (!identical(attr(object, "object_type"), "hd")) {
    stop("`tidy_hd_event.bsvar_post_tbl()` requires a tidy historical decomposition table.", call. = FALSE)
  }
  if (!isTRUE(attr(object, "draws")) && !"draw" %in% names(object)) {
    stop("`tidy_hd_event()` requires either a posterior model object, `PosteriorHD`, or a draw-level tidy HD table.", call. = FALSE)
  }
  event_tbl <- summarise_hd_event_tbl(object, start = start, end = end, probability = probability, draws = TRUE)
  if (draws) {
    return(event_tbl)
  }

  parts <- split(event_tbl, interaction(event_tbl$model, event_tbl$variable, event_tbl$shock, drop = TRUE))
  rows <- lapply(parts, function(part) {
    stats <- summarise_vec(part$value, probability)
    tibble::tibble(
      model = part$model[1],
      object_type = "hd_event",
      variable = part$variable[1],
      shock = part$shock[1],
      event_start = as.character(start),
      event_end = as.character(end),
      mean = stats[["mean"]],
      median = stats[["median"]],
      sd = stats[["sd"]],
      lower = stats[["lower"]],
      upper = stats[["upper"]]
    )
  })
  new_bsvar_post_tbl(do.call(rbind, rows), object_type = "hd_event", draws = FALSE)
 }

#' @rdname tidy_hd_event
#' @export
 tidy_hd_event.PosteriorHD <- function(object, start, end = start, probability = 0.68, draws = FALSE, model = "model1", ...) {
  tidy_hd_event(tidy_hd(object, probability = probability, draws = TRUE, model = model), start = start, end = end,
                probability = probability, draws = draws)
 }

 tidy_hd_event_model <- function(object, start, end = start, probability = 0.68, draws = FALSE, model = "model1", ...) {
  tidy_hd_event(tidy_hd(object, probability = probability, draws = TRUE, model = model, ...),
                start = start, end = end, probability = probability, draws = draws)
 }

#' @rdname tidy_hd_event
#' @export
 tidy_hd_event.PosteriorBSVAR <- tidy_hd_event_model
#' @rdname tidy_hd_event
#' @export
 tidy_hd_event.PosteriorBSVARMIX <- tidy_hd_event_model
#' @rdname tidy_hd_event
#' @export
 tidy_hd_event.PosteriorBSVARMSH <- tidy_hd_event_model
#' @rdname tidy_hd_event
#' @export
 tidy_hd_event.PosteriorBSVARSV <- tidy_hd_event_model
#' @rdname tidy_hd_event
#' @export
 tidy_hd_event.PosteriorBSVART <- tidy_hd_event_model
#' @rdname tidy_hd_event
#' @export
 tidy_hd_event.PosteriorBSVARSIGN <- tidy_hd_event_model

#' Rank shocks by event-window historical decomposition contributions
#'
#' @param object A posterior model object, `PosteriorHD`, or tidy historical
#'   decomposition table.
#' @param start First time index to include.
#' @param end Last time index to include. Defaults to `start`.
#' @param variables Optional variable filter.
#' @param models Optional model filter.
#' @param ranking One of `"absolute"` or `"signed"`.
#' @param probability Equal-tailed interval probability.
#' @param ... Additional arguments passed to `tidy_hd_event()`.
#' @return A \code{bsvar_post_tbl} with columns \code{model},
#'   \code{object_type}, \code{variable}, \code{shock}, \code{event_start},
#'   \code{event_end}, \code{median}, \code{mean}, \code{sd}, \code{lower},
#'   \code{upper}, \code{ranking}, \code{rank_score}, and \code{rank}.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' sr <- shock_ranking(post, start = 2, end = 3)
#' print(sr)
#' @export
shock_ranking <- function(object, start, end = start, variables = NULL, models = NULL,
                          ranking = c("absolute", "signed"), probability = 0.68, ...) {
  ranking <- match.arg(ranking)
  event_tbl <- tidy_hd_event(object, start = start, end = end, probability = probability, draws = FALSE, ...)

  if (!is.null(variables)) {
    event_tbl <- event_tbl[event_tbl$variable %in% variables, , drop = FALSE]
  }
  if (!is.null(models)) {
    event_tbl <- event_tbl[event_tbl$model %in% models, , drop = FALSE]
  }

  score <- if (identical(ranking, "absolute")) abs(event_tbl$median) else event_tbl$median
  event_tbl$ranking <- ranking
  event_tbl$rank_score <- score

  pieces <- split(event_tbl, interaction(event_tbl$model, event_tbl$variable, drop = TRUE))
  ranked <- lapply(pieces, function(part) {
    ord <- order(part$rank_score, decreasing = TRUE)
    part <- part[ord, , drop = FALSE]
    part$rank <- seq_len(nrow(part))
    part
  })

  out <- do.call(rbind, ranked)
  rownames(out) <- NULL
  new_bsvar_post_tbl(out, object_type = "shock_ranking", draws = FALSE)
}
