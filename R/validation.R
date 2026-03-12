#' Validate a posterior model object
#'
#' Check that \code{object} inherits from one of the supported posterior classes
#' from the \pkg{bsvars} or \pkg{bsvarSIGNs} packages.
#'
#' @param object Object to validate.
#' @param arg_name Name of the argument for error messages.
#' @return \code{invisible(object)} if valid.
#' @keywords internal
validate_posterior_object <- function(object, arg_name = "object") {
  valid_classes <- c(
    "PosteriorBSVAR",
    "PosteriorBSVARMIX",
    "PosteriorBSVARMSH",
    "PosteriorBSVARSV",
    "PosteriorBSVART",
    "PosteriorBSVARSIGN"
  )
  if (!inherits(object, valid_classes)) {
    stop(
      "'", arg_name, "' must be a posterior model object from bsvars or bsvarSIGNs.\n",
      "Expected one of: ", paste(valid_classes, collapse = ", "), "\n",
      "Received class: ", paste(class(object), collapse = ", "),
      call. = FALSE
    )
  }
  invisible(object)
}

#' Validate a horizon parameter
#'
#' Check that \code{horizon} is a single non-negative (or positive) integer
#' value.
#'
#' @param horizon Value to validate.
#' @param arg_name Name of the argument for error messages.
#' @param allow_zero If \code{TRUE} (default), zero is a valid value. If
#'   \code{FALSE}, the horizon must be strictly positive.
#' @return \code{as.integer(horizon)} if valid.
#' @keywords internal
validate_horizon <- function(horizon, arg_name = "horizon", allow_zero = TRUE) {
  if (is.null(horizon)) {
    stop("'", arg_name, "' cannot be NULL.", call. = FALSE)
  }
  if (!is.numeric(horizon) || length(horizon) != 1L) {
    stop("'", arg_name, "' must be a single numeric value.", call. = FALSE)
  }
  if (is.na(horizon)) {
    stop("'", arg_name, "' must be non-missing (not NA).", call. = FALSE)
  }
  if (is.infinite(horizon)) {
    stop("'", arg_name, "' must be finite (not Inf).", call. = FALSE)
  }
  if (allow_zero) {
    if (horizon < 0) {
      stop("'", arg_name, "' must be non-negative.", call. = FALSE)
    }
  } else {
    if (horizon <= 0) {
      stop("'", arg_name, "' must be positive (> 0).", call. = FALSE)
    }
  }
  if (horizon != floor(horizon)) {
    stop("'", arg_name, "' must be an integer value.", call. = FALSE)
  }
  as.integer(horizon)
}

#' Validate a probability parameter
#'
#' Check that \code{probability} is a single numeric value strictly between 0
#' and 1.
#'
#' @param probability Value to validate.
#' @param arg_name Name of the argument for error messages.
#' @return \code{probability} if valid.
#' @keywords internal
validate_probability <- function(probability, arg_name = "probability") {
  if (is.null(probability)) {
    stop("'", arg_name, "' cannot be NULL.", call. = FALSE)
  }
  if (!is.numeric(probability) || length(probability) != 1L) {
    stop("'", arg_name, "' must be a single numeric value.", call. = FALSE)
  }
  if (is.na(probability)) {
    stop("'", arg_name, "' must be non-missing (not NA).", call. = FALSE)
  }
  if (is.infinite(probability)) {
    stop("'", arg_name, "' must be finite (not Inf).", call. = FALSE)
  }
  if (probability <= 0 || probability >= 1) {
    stop("'", arg_name, "' must be strictly between 0 and 1 (exclusive).", call. = FALSE)
  }
  probability
}
