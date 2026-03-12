#' Acceptance and admissibility diagnostics for bsvarSIGNs
#'
#' Summarise stored-draw diagnostics for sign-restricted posterior objects.
#' These diagnostics do not reconstruct the full proposal/rejection history of
#' the sampler. Instead, they report what can be recovered from the saved
#' posterior state, identification pattern, and admissibility weights.
#'
#' @param object A `PosteriorBSVARSIGN` object.
#' @param kernel_tol Numerical tolerance used to classify near-zero admissibility
#'   weights.
#' @param ess_threshold Effective-sample-size threshold below which a warning
#'   flag is raised.
#' @param sparse_threshold Share of near-zero admissibility weights above which a
#'   sparse-support warning flag is raised.
#' @param model Optional model identifier.
#' @param ... Reserved for future extensions.
#' @return A \code{bsvar_post_tbl} with columns \code{model},
#'   \code{object_type}, \code{metric}, \code{value}, \code{flag}, and
#'   \code{message}.  Each row reports one diagnostic metric.
#' @examples
#' \donttest{
#' data(optimism, package = "bsvarSIGNs")
#' sign_irf <- matrix(c(1, rep(NA, 5)), 2, 3)
#' spec_s <- suppressMessages(
#'   bsvarSIGNs::specify_bsvarSIGN$new(optimism[, 1:2], p = 1,
#'                                      sign_irf = sign_irf)
#' )
#' post_s <- bsvars::estimate(spec_s, S = 5, show_progress = FALSE)
#'
#' diag <- acceptance_diagnostics(post_s)
#' print(diag)
#' }
#' @export
acceptance_diagnostics <- function(object, ...) {
  UseMethod("acceptance_diagnostics")
}

count_sign_restrictions <- function(sign_irf) {
  if (is.null(sign_irf) || !length(sign_irf)) return(0L)
  sum(!is.na(sign_irf) & sign_irf != 0)
}

count_zero_restrictions <- function(sign_irf) {
  if (is.null(sign_irf) || length(dim(sign_irf)) < 3L) return(0L)
  impact <- sign_irf[, , 1, drop = TRUE]
  sum(!is.na(impact) & impact == 0)
}

count_structural_restrictions <- function(sign_structural) {
  if (is.null(sign_structural) || !length(sign_structural)) return(0L)
  sum(!is.na(sign_structural) & sign_structural != 0)
}

diag_row <- function(model, metric, value, flag = FALSE, message = "") {
  tibble::tibble(
    model = model,
    object_type = "acceptance_diagnostics",
    metric = metric,
    value = value,
    flag = isTRUE(flag),
    message = message
  )
}

#' @rdname acceptance_diagnostics
#' @export
acceptance_diagnostics.PosteriorBSVARSIGN <- function(object, kernel_tol = 1e-12,
                                                      ess_threshold = 20,
                                                      sparse_threshold = 0.1,
                                                      model = "model1", ...) {
  identification <- object$last_draw$identification
  posterior <- object$posterior
  scores <- compute_posterior_kernel(object)

  ess <- posterior$ess
  if (length(ess) != 1L || is.na(ess)) ess <- NA_real_

  zero_share <- mean(scores <= kernel_tol)
  kernel_mean <- mean(scores)
  kernel_sd <- stats::sd(scores)
  kernel_cv <- if (isTRUE(all.equal(kernel_mean, 0))) NA_real_ else kernel_sd / kernel_mean

  rows <- list(
    diag_row(model, "posterior_draws", dim(posterior$Q)[3]),
    diag_row(model, "effective_sample_size", ess, flag = !is.na(ess) && ess < ess_threshold,
             message = if (!is.na(ess) && ess < ess_threshold) "ESS below threshold." else ""),
    diag_row(model, "max_tries", identification$max_tries,
             flag = is.finite(identification$max_tries),
             message = if (is.finite(identification$max_tries)) "Finite max_tries may bind identification search." else ""),
    diag_row(model, "irf_sign_restrictions", count_sign_restrictions(identification$sign_irf)),
    diag_row(model, "zero_restrictions", count_zero_restrictions(identification$sign_irf)),
    diag_row(model, "structural_sign_restrictions", count_structural_restrictions(identification$sign_structural)),
    diag_row(model, "narrative_restrictions", length(identification$sign_narrative)),
    diag_row(model, "kernel_mean", kernel_mean),
    diag_row(model, "kernel_median", stats::median(scores)),
    diag_row(model, "kernel_min", min(scores)),
    diag_row(model, "kernel_max", max(scores)),
    diag_row(model, "kernel_zero_share", zero_share, flag = zero_share > sparse_threshold,
             message = if (zero_share > sparse_threshold) "Large share of near-zero admissibility weights." else ""),
    diag_row(model, "kernel_cv", kernel_cv)
  )

  new_bsvar_post_tbl(do.call(rbind, rows), object_type = "acceptance_diagnostics", draws = FALSE)
}

#' @rdname acceptance_diagnostics
#' @export
acceptance_diagnostics.default <- function(object, ...) {
  stop("`acceptance_diagnostics()` is currently implemented for 'PosteriorBSVARSIGN' only.", call. = FALSE)
}

diagnostic_value <- function(object, metric) {
  row <- object[object$metric == metric, , drop = FALSE]
  if (!nrow(row)) return(NA)
  row$value[[1]]
}

#' @export
summary.bsvar_post_tbl <- function(object, ...) {
  if (!identical(attr(object, "object_type"), "acceptance_diagnostics")) {
    return(object)
  }

  warnings <- object[isTRUE(object$flag), c("metric", "value", "message"), drop = FALSE]
  if (!nrow(warnings)) {
    warnings <- tibble::tibble(metric = character(), value = numeric(), message = character())
  }

  out <- list(
    model = unique(object$model),
    posterior_draws = diagnostic_value(object, "posterior_draws"),
    effective_sample_size = diagnostic_value(object, "effective_sample_size"),
    irf_sign_restrictions = diagnostic_value(object, "irf_sign_restrictions"),
    zero_restrictions = diagnostic_value(object, "zero_restrictions"),
    structural_sign_restrictions = diagnostic_value(object, "structural_sign_restrictions"),
    narrative_restrictions = diagnostic_value(object, "narrative_restrictions"),
    kernel_zero_share = diagnostic_value(object, "kernel_zero_share"),
    kernel_cv = diagnostic_value(object, "kernel_cv"),
    warnings = warnings,
    diagnostics = object
  )
  class(out) <- "SummaryAcceptanceDiagnostics"
  out
}

#' @export
print.SummaryAcceptanceDiagnostics <- function(x, ...) {
  cat("Acceptance diagnostics\n")
  cat("  model: ", paste(x$model, collapse = ", "), "\n", sep = "")
  cat("  posterior draws: ", x$posterior_draws, "\n", sep = "")
  cat("  effective sample size: ", format(x$effective_sample_size, digits = 4), "\n", sep = "")
  cat("  IRF sign restrictions: ", x$irf_sign_restrictions, "\n", sep = "")
  cat("  zero restrictions: ", x$zero_restrictions, "\n", sep = "")
  cat("  structural sign restrictions: ", x$structural_sign_restrictions, "\n", sep = "")
  cat("  narrative restrictions: ", x$narrative_restrictions, "\n", sep = "")
  cat("  kernel zero share: ", format(x$kernel_zero_share, digits = 4), "\n", sep = "")
  cat("  kernel CV: ", format(x$kernel_cv, digits = 4), "\n", sep = "")

  if (nrow(x$warnings) > 0) {
    cat("\nWarnings\n")
    for (i in seq_len(nrow(x$warnings))) {
      cat("  - ", x$warnings$metric[i], ": ", x$warnings$message[i], "\n", sep = "")
    }
  }

  invisible(x)
}
