#' Convert bsvarPost tidy outputs to tsibble
#'
#' @param object A `bsvar_post_tbl`.
#' @param key Optional key columns. By default, `bsvarPost` chooses a key from
#'   `model`, `variable`, `shock`, and `draw` when present.
#' @param index Optional index column. By default, `horizon` is used if present,
#'   otherwise `time`.
#' @param regular Optional regularity flag passed to `tsibble::as_tsibble()`.
#' @param validate Passed to `tsibble::as_tsibble()`.
#' @export
as_tsibble_post <- function(object, key = NULL, index = NULL, regular = NULL, validate = TRUE) {
  if (!inherits(object, "bsvar_post_tbl")) {
    stop("`object` must inherit from 'bsvar_post_tbl'.", call. = FALSE)
  }
  if (!requireNamespace("tsibble", quietly = TRUE)) {
    stop("Package `tsibble` must be installed to use `as_tsibble_post()`.", call. = FALSE)
  }

  if (is.null(index)) {
    index <- if ("horizon" %in% names(object)) "horizon" else if ("time" %in% names(object)) "time" else NULL
  }
  if (is.null(index)) {
    stop("Could not infer an index column. Provide `index` explicitly.", call. = FALSE)
  }

  if (is.null(key)) {
    key <- intersect(c("model", "variable", "shock", "draw"), names(object))
  }

  args <- list(object, key = key, index = index, validate = validate)
  if (!is.null(regular)) {
    args$regular <- regular
  }

  do.call(tsibble::as_tsibble, args)
}
