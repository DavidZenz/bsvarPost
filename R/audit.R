#' Create an impulse-response restriction specification
#'
#' @param variable Response variable.
#' @param shock Shock.
#' @param horizon Horizon.
#' @param sign Optional sign restriction, typically `1` or `-1`.
#' @param zero If `TRUE`, treat the restriction as a zero restriction.
#' @return A list of class \code{bsvar_post_irf_restriction} (inheriting from
#'   \code{bsvar_post_restriction}) with elements \code{variable},
#'   \code{shock}, \code{horizon}, \code{sign}, and \code{zero}.
#' @examples
#' r <- irf_restriction("gdp", "gdp", 0, sign = 1)
#' print(r)
#' @export
irf_restriction <- function(variable, shock, horizon, sign = NULL, zero = FALSE) {
  structure(
    list(variable = variable, shock = shock, horizon = horizon, sign = sign, zero = zero),
    class = c("bsvar_post_irf_restriction", "bsvar_post_restriction")
  )
}

#' Create a structural restriction specification
#'
#' @param variable Row index or variable label.
#' @param shock Column index or shock label.
#' @param sign Sign restriction, typically `1` or `-1`.
#' @return A list of class \code{bsvar_post_structural_restriction} (inheriting
#'   from \code{bsvar_post_restriction}) with elements \code{variable},
#'   \code{shock}, and \code{sign}.
#' @examples
#' r <- structural_restriction("gdp", "gdp", sign = 1)
#' print(r)
#' @export
structural_restriction <- function(variable, shock, sign) {
  structure(
    list(variable = variable, shock = shock, sign = sign),
    class = c("bsvar_post_structural_restriction", "bsvar_post_restriction")
  )
}

#' Create a narrative restriction specification
#'
#' @param start Start period index used by upstream `bsvarSIGNs` semantics.
#' @param periods Number of constrained periods.
#' @param type Narrative restriction type: `"S"`, `"A"`, or `"B"`.
#' @param sign Sign direction, `1` or `-1`.
#' @param shock Shock index.
#' @param var Variable index for `"A"` and `"B"` restrictions.
#' @return A list of class \code{bsvar_post_narrative_restriction} (inheriting
#'   from \code{bsvar_post_restriction}) with elements \code{start},
#'   \code{periods}, \code{type}, \code{sign}, \code{shock}, and \code{var}.
#' @examples
#' r <- narrative_restriction(start = 10, periods = 1, type = "S", sign = 1, shock = 1)
#' print(r)
#' @export
narrative_restriction <- function(start, periods = 1, type = c("S", "A", "B"), sign = 1, shock = 1, var = NA) {
  structure(
    list(start = start, periods = periods, type = match.arg(type), sign = sign, shock = shock, var = var),
    class = c("bsvar_post_narrative_restriction", "bsvar_post_restriction")
  )
}

restriction_label <- function(x) {
  if (inherits(x, "bsvar_post_irf_restriction")) {
    if (isTRUE(x$zero)) {
      return(sprintf("irf[%s,%s,%s]==0", x$variable, x$shock, x$horizon))
    }
    return(sprintf("irf[%s,%s,%s]%s0", x$variable, x$shock, x$horizon, if (x$sign >= 0) ">" else "<"))
  }
  if (inherits(x, "bsvar_post_structural_restriction")) {
    return(sprintf("B[%s,%s]%s0", x$variable, x$shock, if (x$sign >= 0) ">" else "<"))
  }
  if (inherits(x, "bsvar_post_narrative_restriction")) {
    return(sprintf("narrative[%s,%s,%s,%s,%s]", x$type, x$sign, x$shock, x$start, x$periods))
  }
  stop("Unknown restriction type.", call. = FALSE)
}

as_narrative_matrix <- function(restrictions, p = 0L) {
  get_type <- c(S = 1, A = 2, B = 3)
  out <- matrix(NA_real_, nrow = length(restrictions), ncol = 6)
  for (i in seq_along(restrictions)) {
    item <- restrictions[[i]]
    out[i, ] <- c(get_type[[item$type]], item$sign, item$var, item$shock, item$start - p, item$periods - 1)
  }
  out
}

extract_default_restrictions <- function(object) {
  if (!inherits(object, "PosteriorBSVARSIGN")) {
    stop("`restrictions` must be provided unless `object` inherits from 'PosteriorBSVARSIGN'.", call. = FALSE)
  }

  identification <- object$last_draw$identification
  restrictions <- list()

  sign_irf <- identification$sign_irf
  if (length(dim(sign_irf)) == 2L) {
    sign_irf <- array(sign_irf, dim = c(dim(sign_irf), 1L))
  }
  model_names <- infer_model_variable_names(object, n = dim(sign_irf)[1])
  if (is.null(model_names) || length(model_names) != dim(sign_irf)[1]) {
    model_names <- paste0("variable", seq_len(dim(sign_irf)[1]))
  }
  dns <- resolve_array_dimnames(sign_irf, list(
    model_names,
    model_names[seq_len(min(length(model_names), dim(sign_irf)[2]))],
    as.character(seq_len(dim(sign_irf)[3]) - 1L)
  ))
  for (i in seq_len(dim(sign_irf)[1])) {
    for (j in seq_len(dim(sign_irf)[2])) {
      for (h in seq_len(dim(sign_irf)[3])) {
        value <- sign_irf[i, j, h]
        if (!is.na(value)) {
          restrictions[[length(restrictions) + 1L]] <- irf_restriction(
            variable = dns[[1]][i],
            shock = dns[[2]][j],
            horizon = as.numeric(dns[[3]][h]),
            sign = if (identical(value, 0)) NULL else value,
            zero = identical(value, 0)
          )
        }
      }
    }
  }

  sign_structural <- identification$sign_structural
  if (length(sign_structural) > 0) {
    dns_b <- resolve_array_dimnames(sign_structural, list(dns[[1]], dns[[2]]))
    for (i in seq_len(nrow(sign_structural))) {
      for (j in seq_len(ncol(sign_structural))) {
        value <- sign_structural[i, j]
        if (!is.na(value) && value != 0) {
          restrictions[[length(restrictions) + 1L]] <- structural_restriction(dns_b[[1]][i], dns_b[[2]][j], value)
        }
      }
    }
  }

  if (length(identification$sign_narrative) > 0) {
    for (item in identification$sign_narrative) {
      restrictions[[length(restrictions) + 1L]] <- narrative_restriction(
        start = item$start,
        periods = item$periods,
        type = item$type,
        sign = item$sign,
        shock = item$shock,
        var = item$var
      )
    }
  }

  restrictions
}

normalise_restrictions <- function(object, restrictions = NULL) {
  restrictions <- restrictions %||% extract_default_restrictions(object)
  if (!is.list(restrictions) || !all(vapply(restrictions, inherits, logical(1), what = "bsvar_post_restriction"))) {
    stop("`restrictions` must be a list of bsvarPost restriction helper objects.", call. = FALSE)
  }
  restrictions
}

restriction_max_horizon <- function(restrictions) {
  vals <- unlist(lapply(restrictions, function(x) {
    if (inherits(x, "bsvar_post_irf_restriction")) return(as.numeric(x$horizon))
    if (inherits(x, "bsvar_post_narrative_restriction")) return(as.numeric(x$periods - 1))
    numeric(0)
  }))
  if (!length(vals)) return(1)
  max(1, vals, na.rm = TRUE)
}

prepare_audit_context <- function(object, restrictions, probability = 0.90) {
  needs_irf <- any(vapply(restrictions, inherits, logical(1), what = "bsvar_post_irf_restriction")) ||
    any(vapply(restrictions, inherits, logical(1), what = "bsvar_post_narrative_restriction"))
  needs_structural <- any(vapply(restrictions, inherits, logical(1), what = "bsvar_post_structural_restriction"))
  needs_narrative <- any(vapply(restrictions, inherits, logical(1), what = "bsvar_post_narrative_restriction"))

  out <- list(probability = probability)
  if (needs_irf) {
    out$irf <- get_irf_draws(object, horizon = restriction_max_horizon(restrictions), standardise = FALSE)
  }
  if (needs_structural) {
    out$structural <- object$posterior$B
  }
  if (needs_narrative) {
    if (!inherits(object, "PosteriorBSVARSIGN")) {
      stop("Narrative restriction auditing is implemented for 'PosteriorBSVARSIGN' objects only.", call. = FALSE)
    }
    out$shocks <- object$posterior$shocks
    out$p <- object$last_draw$p
    out$Q <- object$posterior$Q
    out$reduced_irf <- array(NA_real_, dim(out$irf))
    for (s in seq_len(dim(out$irf)[4])) {
      out$reduced_irf[, , , s] <- reduced_irf_from_structural(out$irf[, , , s], out$Q[, , s])
    }
  }
  out
}

audit_irf_restriction <- function(restriction, irf_draws, zero_tol = 1e-8, probability = 0.90) {
  subset <- subset_response_draws(irf_draws, variables = restriction$variable, shocks = restriction$shock, horizons = restriction$horizon)
  values <- as.numeric(subset$draws[1, 1, 1, ])
  if (isTRUE(restriction$zero)) {
    satisfied <- abs(values) <= zero_tol
    relation <- "==0"
  } else {
    satisfied <- if (restriction$sign >= 0) values > 0 else values < 0
    relation <- if (restriction$sign >= 0) ">0" else "<0"
  }
  stats <- summarise_vec(values, probability)
  tibble::tibble(
    restriction_type = if (isTRUE(restriction$zero)) "irf_zero" else "irf_sign",
    restriction = restriction_label(restriction),
    variable = subset$labels$variable[1],
    shock = subset$labels$shock[1],
    horizon = as.numeric(subset$labels$horizon[1]),
    relation = relation,
    posterior_prob = mean(satisfied),
    mean = stats[["mean"]],
    median = stats[["median"]],
    lower = stats[["lower"]],
    upper = stats[["upper"]]
  )
}

audit_structural_restriction <- function(restriction, structural_draws, probability = 0.90) {
  dns <- resolve_array_dimnames(structural_draws, list(
    paste0("variable", seq_len(dim(structural_draws)[1])),
    paste0("shock", seq_len(dim(structural_draws)[2])),
    as.character(seq_len(dim(structural_draws)[3]))
  ))
  i <- resolve_selection(restriction$variable, dns[[1]])
  j <- resolve_selection(restriction$shock, dns[[2]])
  values <- as.numeric(structural_draws[i, j, ])
  satisfied <- if (restriction$sign >= 0) values > 0 else values < 0
  stats <- summarise_vec(values, probability)
  relation_value <- if (restriction$sign >= 0) ">0" else "<0"
  restriction_name <- restriction_label(restriction)
  tibble::tibble(
    restriction_type = "structural_sign",
    restriction = restriction_name,
    variable = dns[[1]][i],
    shock = dns[[2]][j],
    horizon = NA_real_,
    relation = relation_value,
    posterior_prob = mean(satisfied),
    mean = stats[["mean"]],
    median = stats[["median"]],
    lower = stats[["lower"]],
    upper = stats[["upper"]]
  )
}

audit_narrative_restriction <- function(restriction, shocks, reduced_irf, p = 0L) {
  sign_narrative <- as_narrative_matrix(list(restriction), p = p)
  satisfied <- vapply(seq_len(dim(shocks)[3]), function(s) {
    shock_draw <- matrix(shocks[, , s], nrow = dim(shocks)[1], ncol = dim(shocks)[2])
    irf_draw <- array(reduced_irf[, , , s], dim = dim(reduced_irf)[1:3])
    isTRUE(bsvarsigns_match_sign_narrative(shock_draw, sign_narrative, irf_draw))
  }, logical(1))
  relation_value <- if (restriction$sign >= 0) ">0" else "<0"
  restriction_name <- restriction_label(restriction)
  variable_value <- if (is.na(restriction$var)) NA_character_ else as.character(restriction$var)
  shock_value <- as.character(restriction$shock)
  horizon_value <- restriction$periods - 1
  tibble::tibble(
    restriction_type = paste0("narrative_", restriction$type),
    restriction = restriction_name,
    variable = variable_value,
    shock = shock_value,
    horizon = horizon_value,
    relation = relation_value,
    posterior_prob = mean(satisfied),
    mean = NA_real_,
    median = NA_real_,
    lower = NA_real_,
    upper = NA_real_
  )
}

#' Audit sign, zero, structural, and narrative restrictions
#'
#' @param object A posterior model object.
#' @param restrictions Optional list of restriction helper objects. If omitted
#'   for `PosteriorBSVARSIGN`, restrictions are extracted from the fitted
#'   identification scheme.
#' @param zero_tol Numerical tolerance for zero restrictions.
#' @param probability Equal-tailed interval probability used in summaries.
#' @param model Optional model identifier.
#' @param ... Reserved for future extensions.
#' @return A \code{bsvar_post_tbl} with columns \code{model},
#'   \code{restriction_type}, \code{restriction}, \code{variable}, \code{shock},
#'   \code{horizon}, \code{relation}, \code{posterior_prob}, \code{mean},
#'   \code{median}, \code{lower}, and \code{upper}.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' r <- list(irf_restriction("gdp", "gdp", 0, sign = 1))
#' audit <- restriction_audit(post, restrictions = r)
#' print(audit)
#' @export
restriction_audit <- function(object, restrictions = NULL, zero_tol = 1e-8,
                              probability = 0.90, model = "model1", ...) {
  restrictions <- normalise_restrictions(object, restrictions)
  ctx <- prepare_audit_context(object, restrictions, probability = probability)

  rows <- lapply(restrictions, function(restriction) {
    out <- if (inherits(restriction, "bsvar_post_irf_restriction")) {
      audit_irf_restriction(restriction, ctx$irf, zero_tol = zero_tol, probability = probability)
    } else if (inherits(restriction, "bsvar_post_structural_restriction")) {
      audit_structural_restriction(restriction, ctx$structural, probability = probability)
    } else if (inherits(restriction, "bsvar_post_narrative_restriction")) {
      audit_narrative_restriction(restriction, ctx$shocks, ctx$reduced_irf, p = ctx$p)
    } else {
      stop("Unknown restriction type.", call. = FALSE)
    }
    out$model <- model
    out
  })

  out <- do.call(rbind, rows)
  out <- out[, c("model", "restriction_type", "restriction", "variable", "shock", "horizon", "relation", "posterior_prob", "mean", "median", "lower", "upper")]
  new_bsvar_post_tbl(out, object_type = "restriction_audit", draws = FALSE)
}

#' Audit magnitude statements for IRFs or CDMs
#'
#' @param object A posterior model object or response object.
#' @param type Response object type to audit.
#' @inheritParams hypothesis_irf
#' @inheritParams hypothesis_cdm
#' @return A \code{bsvar_post_tbl} with hypothesis test results including
#'   \code{posterior_prob}, \code{mean}, \code{median}, \code{lower}, and
#'   \code{upper} columns.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' mag <- magnitude_audit(post, variable = "gdp", shock = "gdp",
#'                        horizon = 0, relation = ">")
#' print(mag)
#' @export
magnitude_audit <- function(object, type = c("irf", "cdm"), variable, shock, horizon,
                            relation = c("<", "<=", ">", ">=", "=="), value = 0,
                            compare_to = NULL, absolute = FALSE, probability = 0.90,
                            draws = FALSE, model = "model1", scale_by = c("none", "shock_sd"),
                            scale_var = NULL, ...) {
  type <- match.arg(type)
  out <- if (identical(type, "irf")) {
    hypothesis_irf(
      object,
      variable = variable,
      shock = shock,
      horizon = horizon,
      relation = relation,
      value = value,
      compare_to = compare_to,
      absolute = absolute,
      probability = probability,
      draws = draws,
      model = model,
      ...
    )
  } else {
    hypothesis_cdm(
      object,
      variable = variable,
      shock = shock,
      horizon = horizon,
      relation = relation,
      value = value,
      compare_to = compare_to,
      absolute = absolute,
      probability = probability,
      draws = draws,
      model = model,
      scale_by = scale_by,
      scale_var = scale_var,
      ...
    )
  }
  out$audit_type <- "magnitude"
  out
}
