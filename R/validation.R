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
    stop("'", arg_name, "' cannot be NULL. Received: NULL", call. = FALSE)
  }
  if (!is.numeric(horizon) || length(horizon) != 1L) {
    stop("'", arg_name, "' must be a single numeric value. Received: ", deparse(horizon), call. = FALSE)
  }
  if (is.na(horizon)) {
    stop("'", arg_name, "' must be non-missing (not NA). Received: NA", call. = FALSE)
  }
  if (is.infinite(horizon)) {
    stop("'", arg_name, "' must be finite (not Inf). Received: ", horizon, call. = FALSE)
  }
  if (allow_zero) {
    if (horizon < 0) {
      stop("'", arg_name, "' must be non-negative. Received: ", horizon, call. = FALSE)
    }
  } else {
    if (horizon <= 0) {
      stop("'", arg_name, "' must be positive (> 0). Received: ", horizon, call. = FALSE)
    }
  }
  if (horizon != floor(horizon)) {
    stop("'", arg_name, "' must be an integer value. Received: ", horizon, call. = FALSE)
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
    stop("'", arg_name, "' cannot be NULL. Received: NULL", call. = FALSE)
  }
  if (!is.numeric(probability) || length(probability) != 1L) {
    stop("'", arg_name, "' must be a single numeric value. Received: ", deparse(probability), call. = FALSE)
  }
  if (is.na(probability)) {
    stop("'", arg_name, "' must be non-missing (not NA). Received: NA", call. = FALSE)
  }
  if (is.infinite(probability)) {
    stop("'", arg_name, "' must be finite (not Inf). Received: ", probability, call. = FALSE)
  }
  if (probability <= 0 || probability >= 1) {
    stop("'", arg_name, "' must be strictly between 0 and 1 (exclusive). Received: ", probability, call. = FALSE)
  }
  probability
}

#' Handle deprecated argument with warning
#'
#' Issues a deprecation warning when an old argument is used, and resolves
#' which value to return (new takes precedence over old).
#'
#' @param new_val Value provided for the new argument (may be NULL).
#' @param old_val Value provided for the deprecated argument (may be NULL).
#' @param old_name Name of the deprecated argument for the warning message.
#' @param new_name Name of the replacement argument for the warning message.
#' @param fn_name Name of the calling function for the warning message.
#' @return \code{new_val} if not NULL; \code{old_val} otherwise.
#' @keywords internal
deprecate_arg <- function(new_val, old_val, old_name, new_name, fn_name) {
  if (!is.null(old_val)) {
    warning(
      "In ", fn_name, "(): '", old_name, "' is deprecated and will be removed in a future version.\n",
      "Use '", new_name, "' instead.",
      call. = FALSE
    )
    if (is.null(new_val)) {
      return(old_val)
    }
  }
  new_val
}

#' Resolve horizon to a validated integer, defaulting to 20
#'
#' Converts NULL to the default horizon (20 periods, following the econometric
#' convention of covering business cycle dynamics). Non-NULL values are
#' validated via \code{validate_horizon()}.
#'
#' @param horizon Horizon value to resolve (NULL or numeric).
#' @param default Default integer horizon when \code{horizon} is NULL. Defaults
#'   to \code{20L} (econometric convention covering business cycle dynamics).
#' @param arg_name Name of the argument for error messages.
#' @return \code{as.integer(default)} if \code{horizon} is NULL; otherwise
#'   \code{validate_horizon(horizon, arg_name)} which returns
#'   \code{as.integer(horizon)}.
#' @keywords internal
resolve_horizon <- function(horizon, default = 20L, arg_name = "horizon") {
  if (is.null(horizon)) {
    return(as.integer(default))
  }
  validate_horizon(horizon, arg_name = arg_name)
}
