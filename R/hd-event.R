#' Summarises historical-decomposition contributions over selected periods
#'
#' Transforms posterior draws of historical decompositions into cumulative
#' structural-shock contributions over a selected historical period and reports
#' their posterior summaries.
#'
#' @param object A posterior model object, `PosteriorHD`, or a draw-level
#'   table of historical decompositions.
#' @section Event windows:
#' Periods are ordered chronologically, independently of row order. Numeric
#' times, ISO dates/UTC timestamps, Date and POSIXt values are supported. Other
#' labels require an ordered factor with chronological levels. Different labels
#' for the same period are rejected as ambiguous. Bounds are inclusive.
#' Each model-variable-shock series must have the same draws within its model,
#' and every draw must cover every observed period in the requested window.
#' Missing cells and duplicate keys are errors; zero contributions remain valid.
#' A period absent from every series cannot be inferred without an explicit
#' time axis. Otherwise, the result sums observed periods only, which can
#' understate a complete-window contribution. Declare ordered factor levels
#' from the known full time axis before filtering; levels inferred from an
#' already incomplete table cannot recover omitted periods.
#' POSIXt periods are matched as instants; cumulative plots label them in UTC.
#' Ambiguous local clock-time bounds during daylight-saving fallback are
#' rejected; supply POSIXt bounds or UTC timestamps ending in `Z` instead.
#'
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

# Resolve an intrinsic period order, independent of table row order. Arbitrary
# text needs ordered factor levels; guessing lexical or arrival order is unsafe.
hd_time_labels <- function(times) {
  if (inherits(times, "POSIXt"))
    format(times, "%Y-%m-%dT%H:%M:%OS6Z", tz = "UTC")
  else as.character(times)
}

canonical_hd_time <- function(times) {
  labels <- hd_time_labels(times)
  if (!length(labels) || anyNA(labels) || any(!nzchar(labels)))
    stop("HD periods must be non-missing and nonempty.", call. = FALSE)
  # Retain explicitly declared periods even when all their rows are missing.
  if (is.ordered(times)) labels <- levels(times)
  if (anyNA(labels) || any(!nzchar(labels)))
    stop("HD periods must be non-missing and nonempty.", call. = FALSE)
  if (inherits(times, "Date")) {
    values <- as.numeric(times)
    kind <- "date"
  } else if (inherits(times, "POSIXt")) {
    values <- as.numeric(as.POSIXct(times))
    kind <- "datetime"
  } else {
    suppressWarnings(values <- as.numeric(labels))
    kind <- "numeric"
    if (!all(is.finite(values))) {
      if (all(grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", labels))) {
        parsed <- suppressWarnings(as.Date(labels, format = "%Y-%m-%d"))
        if (anyNA(parsed) || any(format(parsed, "%Y-%m-%d") != labels))
          stop("HD periods contain invalid ISO dates.", call. = FALSE)
        values <- as.numeric(parsed)
        kind <- "date"
      } else if (all(grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}[ T][0-9]{2}:[0-9]{2}:[0-9]{2}(\\.[0-9]+)?Z?$", labels))) {
        normalized <- sub("Z$", "", gsub("T", " ", labels, fixed = TRUE))
        parsed <- suppressWarnings(as.POSIXct(normalized,
          format = "%Y-%m-%d %H:%M:%OS", tz = "UTC"))
        if (anyNA(parsed) || any(format(parsed, "%Y-%m-%d %H:%M:%S", tz = "UTC") != substr(normalized, 1, 19)))
          stop("HD periods contain invalid ISO timestamps.", call. = FALSE)
        values <- as.numeric(parsed)
        kind <- "datetime"
      } else if (is.ordered(times)) {
        values <- seq_along(labels)
        kind <- "ordered"
      } else {
        stop("Cannot determine chronological HD periods; use numeric times, ISO dates/timestamps, or an ordered factor.", call. = FALSE)
      }
    }
  }
  if (any(!is.finite(values))) stop("HD periods must be finite and valid.", call. = FALSE)
  pairs <- unique(data.frame(label = labels, value = values))
  if (anyDuplicated(pairs$label) || anyDuplicated(pairs$value))
    stop("Ambiguous HD periods: distinct labels and chronological periods must correspond one-to-one.", call. = FALSE)
  pairs <- pairs[order(pairs$value), , drop = FALSE]
  list(labels = pairs$label, values = pairs$value, kind = kind)
}

event_window_labels <- function(times, start, end = start) {
  if (length(start) != 1L || length(end) != 1L || anyNA(start) || anyNA(end))
    stop("Event start and end must be single non-missing time labels.", call. = FALSE)
  axis <- canonical_hd_time(times)
  locate <- function(value) {
    # Exact labels retain compatibility with numeric and ISO string bounds.
    index <- match(hd_time_labels(value), axis$labels)
    if (!is.na(index)) return(index)
    coordinate <- if (axis$kind == "numeric") suppressWarnings(as.numeric(as.character(value))) else
      if (axis$kind == "date" && inherits(value, "Date")) as.numeric(value) else
      if (axis$kind == "datetime") {
        if (inherits(value, "POSIXt")) as.numeric(as.POSIXct(value)) else {
          tz <- if (inherits(times, "POSIXt")) attr(as.POSIXct(times), "tzone") else "UTC"
          if (!length(tz)) tz <- ""
          label <- gsub("T", " ", as.character(value), fixed = TRUE)
          utc <- grepl("Z$", label)
          if (utc) tz <- "UTC"
          label <- sub("Z$", "", label)
          date_only <- grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", label)
          if (!date_only && !grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}(\\.[0-9]+)?$", label))
            return(NA_integer_)
          time_format <- if (date_only) "%Y-%m-%d" else "%Y-%m-%d %H:%M:%OS"
          # Parse civil fields in UTC, then match local labels to observed
          # instants. Local DST parsing is platform dependent at transitions.
          parsed <- suppressWarnings(as.POSIXct(label, format = time_format, tz = "UTC"))
          check_format <- if (date_only) "%Y-%m-%d" else "%Y-%m-%d %H:%M:%S"
          if (is.na(parsed) || format(parsed, check_format, tz = "UTC") != substr(label, 1, if (date_only) 10 else 19))
            return(NA_integer_)
          if (inherits(times, "POSIXt") && !utc) {
            # Both occurrences of a repeated local clock time are valid
            # instants. Do not let the platform's DST parser pick one.
            instants <- as.POSIXct(axis$values, origin = "1970-01-01", tz = tz[1])
            local <- format(instants, "%Y-%m-%d %H:%M:%OS6", tz = tz[1])
            candidates <- which(local == format(parsed, "%Y-%m-%d %H:%M:%OS6", tz = "UTC"))
            if (length(candidates) > 1L)
              stop("Ambiguous HD time bound during daylight-saving fallback; use a POSIXt value or UTC timestamp ending in Z.", call. = FALSE)
            return(if (length(candidates)) candidates else NA_integer_)
          }
          as.numeric(parsed)
        }
      } else NA_real_
    match(coordinate, axis$values)
  }
  start_idx <- locate(start)
  end_idx <- locate(end)
  if (is.na(start_idx) || is.na(end_idx))
    stop("No historical decomposition observations found in the requested event window.", call. = FALSE)
  if (start_idx > end_idx) stop("Event start must not follow event end.", call. = FALSE)
  axis$labels[seq.int(start_idx, end_idx)]
}

validate_hd_event_table <- function(object, start, end) {
  required <- c("model", "variable", "shock", "time", "draw", "value")
  if (!all(required %in% names(object)) || !nrow(object) ||
      !is.numeric(object$value) || any(!is.finite(object$value)) ||
      !is.numeric(object$draw) || anyNA(object$draw) ||
      any(object$draw < 1 | object$draw > .Machine$integer.max | object$draw != floor(object$draw)))
    stop("Event summaries require finite draw-level values and positive integer draw identifiers.", call. = FALSE)
  for (name in c("model", "variable", "shock")) {
    if (anyNA(object[[name]]) || any(!nzchar(as.character(object[[name]]))))
      stop("HD model, variable and shock labels must be non-missing and nonempty.", call. = FALSE)
  }
  window <- if (is.null(start)) canonical_hd_time(object$time)$labels else event_window_labels(object$time, start, end)
  keys <- c("model", "variable", "shock", "time", "draw")
  duplicate <- anyDuplicated(vctrs::vec_group_id(as.data.frame(object[keys])))
  if (duplicate)
    stop("Historical decomposition tables must have unique model-variable-shock-time-draw keys (duplicate periods found): model '",
      object$model[duplicate], "', variable '", object$variable[duplicate], "', shock '", object$shock[duplicate],
      "', time '", hd_time_labels(object$time[duplicate]), "', draw ", object$draw[duplicate], ".", call. = FALSE)
  groups <- vctrs::vec_group_id(as.data.frame(object[c("model", "variable", "shock", "draw")]))
  first <- match(seq_len(attr(groups, "n")), groups)
  counts <- tabulate(groups[hd_time_labels(object$time) %in% window], nbins = length(first))
  bad <- which(counts != length(window))
  if (length(bad)) {
    i <- bad[1]
    row <- first[i]
    missing <- setdiff(window, hd_time_labels(object$time[groups == i]))
    stop("Incomplete HD event window for model '", object$model[row], "', variable '",
      object$variable[row], "', shock '", object$shock[row], "', draw ", object$draw[row],
      ": missing period(s) ", paste(missing, collapse = ", "), ".", call. = FALSE)
  }
  # A completely absent draw/series combination must not disappear either.
  series <- vctrs::vec_group_id(as.data.frame(object[c("model", "variable", "shock")]))
  series_first <- match(seq_len(attr(series, "n")), series)
  model_draws <- unique(as.data.frame(object[c("model", "draw")]))
  expected <- table(as.character(model_draws$model))[as.character(object$model[series_first])]
  bad_series <- which(tabulate(series[first], nbins = length(series_first)) != as.integer(expected))
  if (length(bad_series)) {
    row <- series_first[bad_series[1]]
    missing <- setdiff(object$draw[object$model == object$model[row]], object$draw[series == bad_series[1]])
    stop("Incomplete HD draw coverage for model '", object$model[row], "', variable '", object$variable[row],
      "', shock '", object$shock[row], "': missing draw(s) ", paste(unique(missing), collapse = ", "), ".", call. = FALSE)
  }
  window
}

validate_hd_draw_grid <- function(object) {
  # Validate before components are merged: duplicates would otherwise become
  # sums, and missing shocks would otherwise look like zero contributions.
  if (!all(c("model", "variable", "shock", "time", "draw", "value") %in% names(object)))
    stop("HD draw tables require model, variable, shock, time, draw and value columns.", call. = FALSE)
  parts <- split(object, tuple_group(object$model))
  for (part in parts) {
    validate_hd_event_table(part, start = NULL, end = NULL)
    series <- unique(as.data.frame(part[c("variable", "shock")]))
    expected <- expand.grid(variable = unique(as.character(part$variable)),
      shock = unique(as.character(part$shock)), stringsAsFactors = FALSE)
    missing <- which(is.na(vctrs::vec_match(expected, series)))
    if (length(missing)) {
      row <- expected[missing[1], ]
      stop("Incomplete HD cell grid for model '", part$model[1], "': missing variable '", row$variable,
        "', shock '", row$shock, "' for all periods and draws.", call. = FALSE)
    }
    if ("draw_id" %in% names(part)) {
      ids <- as.character(part$draw_id)
      pairs <- unique(data.frame(draw = part$draw, draw_id = ids))
      if (anyNA(ids) || any(!nzchar(ids)) || anyDuplicated(pairs$draw) || anyDuplicated(pairs$draw_id))
        stop("HD draw and draw_id identifiers must correspond one-to-one within model '", part$model[1], "'.", call. = FALSE)
    }
  }
  invisible(object)
}

summarise_hd_event_tbl <- function(tbl, start, end = start, probability = 0.90, draws = FALSE) {
  window_labels <- event_window_labels(tbl$time, start = start, end = end)
  time_chr <- hd_time_labels(tbl$time)
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
        value = sum(part$value[order(match(hd_time_labels(part$time), window_labels))])
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
  validate_probability(probability)
  validate_flag(draws, "draws")
  validate_hd_event_table(object, start, end)
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
#' @param object A posterior model object, `PosteriorHD`, or a draw-level
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
