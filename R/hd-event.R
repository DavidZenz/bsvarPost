#' Summarises historical-decomposition contributions over selected periods
#'
#' Transforms posterior draws of historical decompositions into cumulative
#' structural-shock contributions over a selected historical period and reports
#' their posterior summaries.
#'
#' @param object A posterior model object, `PosteriorHD`, or a posterior-summary
#'   table of historical decompositions.
#' @param start First time index to include.
#' @param end Last time index to include. Defaults to `start`.
#' @param probability Probability mass of the equal-tailed credible interval.
#' @param draws If `TRUE`, return draw-level cumulative contributions.
#' @param model Label identifying the model specification.
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
#' hd_event <- tidy_hd_event(post, start = "1948.25", end = "1948.5")
#' head(hd_event)
#' @seealso [posterior_provenance]
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
  if (length(start) != 1L || length(end) != 1L || anyNA(start) || anyNA(end)) {
    stop("Event start and end must be single non-missing time labels.", call. = FALSE)
  }
  labels <- unique(as.character(times))
  start_chr <- as.character(start)
  end_chr <- as.character(end)
  start_idx <- match(start_chr, labels)
  end_idx <- match(end_chr, labels)
  if (is.na(start_idx) || is.na(end_idx)) {
    stop("No historical decomposition observations found in the requested event window.", call. = FALSE)
  }
  if (start_idx > end_idx) {
    stop("Event start must not follow event end.", call. = FALSE)
  }
  labels[seq.int(start_idx, end_idx)]
}

summarise_hd_event_tbl <- function(tbl, start, end = start, probability = 0.90, draws = FALSE) {
  window_labels <- event_window_labels(tbl$time, start = start, end = end)
  time_chr <- as.character(tbl$time)
  keep <- time_chr %in% window_labels
  df <- tbl[keep, , drop = FALSE]

  if (isTRUE(attr(tbl, "draws")) || "draw" %in% names(df)) {
    if (!"draw" %in% names(df)) {
      stop("Draw-level event summaries require a draw-level historical decomposition table.", call. = FALSE)
    }
    parts <- split(df, tuple_group(df$model, df$variable, df$shock, df$draw, drop = TRUE))
    rows <- lapply(parts, function(part) {
      tibble::tibble(
        model = part$model[1],
        object_type = "hd_event",
        variable = part$variable[1],
        shock = part$shock[1],
        event_start = as.character(start),
        event_end = as.character(end),
        draw = part$draw[1],
        draw_id = if ("draw_id" %in% names(part)) part$draw_id[1] else as.character(part$draw[1]),
        value = sum(part$value)
      )
    })
    return(with_post_provenance(new_bsvar_post_tbl(do.call(rbind, rows), object_type = "hd_event", draws = TRUE), source = tbl))
  }

  hd_draws <- tidy_hd(tbl, draws = TRUE)
  tidy_hd_event(hd_draws, start = start, end = end, probability = probability, draws = draws)
}

#' @rdname tidy_hd_event
#' @export
 tidy_hd_event.bsvar_post_tbl <- function(object, start, end = start, probability = 0.90, draws = FALSE, ...) {
  if (!identical(attr(object, "object_type"), "hd")) {
    stop("`tidy_hd_event.bsvar_post_tbl()` requires a tidy historical decomposition table.", call. = FALSE)
  }
  if (!isTRUE(attr(object, "draws")) && !"draw" %in% names(object)) {
    stop("`tidy_hd_event()` requires either a posterior model object, `PosteriorHD`, or a draw-level tidy HD table.", call. = FALSE)
  }
  required <- c("model", "variable", "shock", "time", "draw", "value")
  if (!all(required %in% names(object)) || !is.numeric(object$value) || any(!is.finite(object$value)) ||
      !is.numeric(object$draw) || anyNA(object$draw) ||
      any(object$draw < 1 | object$draw > .Machine$integer.max | object$draw != floor(object$draw))) {
    stop("Event summaries require finite draw-level values and positive integer draw identifiers.", call. = FALSE)
  }
  keys <- c("model", "variable", "shock", "time", "draw")
  if (anyDuplicated(vctrs::vec_group_id(as.data.frame(object[keys])))) {
    stop("Historical decomposition tables must have unique model-variable-shock-time-draw keys.", call. = FALSE)
  }
  event_tbl <- summarise_hd_event_tbl(object, start = start, end = end, probability = probability, draws = TRUE)
  if (draws) {
    return(event_tbl)
  }

  parts <- split(event_tbl, tuple_group(event_tbl$model, event_tbl$variable, event_tbl$shock, drop = TRUE))
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
  with_post_provenance(new_bsvar_post_tbl(do.call(rbind, rows), object_type = "hd_event", draws = FALSE), source = object, probability = probability)
 }

#' @rdname tidy_hd_event
#' @export
 tidy_hd_event.PosteriorHD <- function(object, start, end = start, probability = 0.90, draws = FALSE, model = "model1", ...) {
  validate_draw_array(object, 4L, "tidy_hd_event()")
  validate_probability(probability)
  validate_flag(draws, "draws")
  d <- dim(object)
  dns <- resolve_array_dimnames(object, list(paste0("variable", seq_len(d[1])),
    paste0("shock", seq_len(d[2])), as.character(seq_len(d[3])), as.character(seq_len(d[4]))))
  window <- event_window_labels(dns[[3]], start, end)
  selected <- match(window, dns[[3]])
  totals <- apply(object[, , selected, , drop = FALSE], c(1L, 2L, 4L), sum)
  totals <- array(totals, dim = c(d[1], d[2], 1L, d[4]),
                  dimnames = list(dns[[1]], dns[[2]], "event", dns[[4]]))
  totals <- copy_posterior_attributes(totals, object)
  out <- as_tidy_hd_array(totals, model = model, probability = probability, draws = draws)
  out$time <- NULL
  out$event_start <- as.character(start)
  out$event_end <- as.character(end)
  out$object_type <- "hd_event"
  new_bsvar_post_tbl(out, object_type = "hd_event", draws = draws)
 }

 tidy_hd_event_model <- function(object, start, end = start, probability = 0.90, draws = FALSE, model = "model1", ...) {
  hd <- get_hd_draws(object)
  tidy_hd_event(hd, start = start, end = end,
                probability = probability, draws = draws, model = model)
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

#' Ranks structural shocks by contributions over selected periods
#'
#' Summarises posterior historical decompositions over a selected period and
#' ranks structural shocks by the absolute or signed magnitude of their
#' contributions.
#'
#' @param object A posterior model object, `PosteriorHD`, or a posterior-summary
#'   table of historical decompositions.
#' @param start First time index to include.
#' @param end Last time index to include. Defaults to `start`.
#' @param variables Variables whose historical decompositions are included.
#' @param models Model specifications to include.
#' @param ranking One of `"absolute"` or `"signed"`.
#' @param probability Probability mass of the equal-tailed credible interval.
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
#' sr <- shock_ranking(post, start = "1948.25", end = "1948.5")
#' print(sr)
#' @export
shock_ranking <- function(object, start, end = start, variables = NULL, models = NULL,
                          ranking = c("absolute", "signed"), probability = 0.90, ...) {
  ranking <- match.arg(ranking)
  event_tbl <- tidy_hd_event(object, start = start, end = end, probability = probability, draws = FALSE, ...)

  if (!is.null(variables)) {
    event_tbl <- event_tbl[event_tbl$variable %in% variables, , drop = FALSE]
  }
  if (!is.null(models)) {
    event_tbl <- event_tbl[event_tbl$model %in% models, , drop = FALSE]
  }
  if (!nrow(event_tbl)) stop("No event contributions remain after filtering.", call. = FALSE)

  score <- if (identical(ranking, "absolute")) abs(event_tbl$median) else event_tbl$median
  event_tbl$ranking <- ranking
  event_tbl$rank_score <- score

  pieces <- split(event_tbl, tuple_group(event_tbl$model, event_tbl$variable, drop = TRUE))
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
