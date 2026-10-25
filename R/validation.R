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
  if (horizon != floor(horizon) || horizon > .Machine$integer.max) {
    stop("'", arg_name, "' must be an integer value. Received: ", horizon, call. = FALSE)
  }
  as.integer(horizon)
}

validate_flag <- function(value, arg_name) {
  if (!is.logical(value) || length(value) != 1L || is.na(value)) {
    stop("`", arg_name, "` must be a single non-missing logical value.", call. = FALSE)
  }
  invisible(value)
}

validate_scalar_number <- function(value, arg_name, lower = -Inf, upper = Inf) {
  if (!is.numeric(value) || length(value) != 1L || is.na(value) ||
      !is.finite(value) || value < lower || value > upper) {
    stop("`", arg_name, "` must be a finite scalar between ", lower, " and ", upper, ".", call. = FALSE)
  }
  invisible(value)
}

validate_draw_array <- function(x, dimensions, caller) {
  if (!is.array(x) || !is.numeric(x) || length(dim(x)) != dimensions ||
      any(dim(x) < 1L) || any(!is.finite(x))) {
    stop("`", caller, "` requires a finite numeric ", dimensions,
         "-dimensional posterior array with nonempty dimensions.", call. = FALSE)
  }
  for (ids in dimnames(x)) {
    if (anyNA(ids) || any(!nzchar(ids)) || anyDuplicated(ids)) {
      stop("Posterior dimension and draw labels must be non-missing, nonempty, and unique.", call. = FALSE)
    }
  }
  invisible(x)
}

validate_selector <- function(value, arg_name) {
  if (length(value) != 1L || anyNA(value) ||
      !(is.character(value) || is.numeric(value))) {
    stop("`", arg_name, "` must be a single label or positive integer index.", call. = FALSE)
  }
  if (is.character(value)) {
    if (!nzchar(value)) stop("`", arg_name, "` must not be empty.", call. = FALSE)
  } else {
    validate_horizon(value, arg_name, allow_zero = FALSE)
  }
  invisible(value)
}

validate_restriction_sign <- function(sign) {
  if (!is.numeric(sign) || length(sign) != 1L || is.na(sign) || !sign %in% c(-1, 1)) {
    stop("`sign` must be either -1 or 1.", call. = FALSE)
  }
  invisible(sign)
}

validate_narrative_bounds <- function(item, object) {
  do.call(narrative_restriction, item[c("start", "periods", "type", "sign", "shock", "var")])
  y <- object$last_draw$data_matrices$Y
  p <- object$last_draw$p
  if (!is.matrix(y) || !length(p) || !is.finite(p)) {
    stop("Narrative restrictions require valid model data matrices and lag order.", call. = FALSE)
  }
  start <- as.double(item$start) - p
  end <- start + as.double(item$periods) - 1
  if (start < 1 || end > ncol(y) || item$shock > nrow(y) ||
      (!is.na(item$var) && item$var > nrow(y))) {
    stop("Narrative restriction indices are outside the model's variables or effective sample.", call. = FALSE)
  }
  invisible(item)
}

validate_sign_posterior <- function(object) {
  if (is.null(object$posterior) || is.null(object$last_draw$identification) ||
      is.null(object$last_draw$data_matrices)) {
    stop("Malformed sign posterior: missing posterior, identification, or data matrices.", call. = FALSE)
  }
  posterior <- object$posterior
  fields <- c("Q", "A", "B", "Theta0", "shocks")
  for (field in fields) validate_draw_array(posterior[[field]], 3L, paste0("posterior$", field))
  n <- dim(posterior$Q)[1]
  s <- dim(posterior$Q)[3]
  y <- object$last_draw$data_matrices$Y
  x <- object$last_draw$data_matrices$X
  validate_horizon(object$last_draw$p, "lag order", allow_zero = FALSE)
  if (!is.matrix(y) || !is.matrix(x) || !is.numeric(y) || !is.numeric(x) ||
      nrow(y) != n || ncol(y) < 1L || ncol(x) != ncol(y) || any(!is.finite(y)) || any(!is.finite(x))) {
    stop("Malformed sign posterior: incompatible or non-finite model data matrices.", call. = FALSE)
  }
  expected <- list(Q = c(n, n, s), B = c(n, n, s), Theta0 = c(n, n, s),
                   A = c(n, nrow(x), s), shocks = c(n, ncol(y), s))
  for (field in fields) {
    if (!identical(dim(posterior[[field]]), as.integer(expected[[field]]))) {
      stop("Malformed sign posterior: incompatible dimensions for `posterior$", field, "`.", call. = FALSE)
    }
  }
  identification <- object$last_draw$identification
  sign <- identification$sign_irf
  if (!is.array(sign) || length(dim(sign)) != 3L ||
      any(dim(sign)[1:2] != n) || dim(sign)[3] < 1L ||
      any(!is.na(sign) & !sign %in% c(-1, 0, 1))) {
    stop("Malformed sign posterior: incompatible impulse-response restrictions.", call. = FALSE)
  }
  for (item in identification$sign_narrative) validate_narrative_bounds(item, object)
  invisible(object)
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
