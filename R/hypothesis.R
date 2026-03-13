#' Posterior probability statements for impulse responses
#'
#' Evaluate threshold or pairwise posterior probability statements on impulse
#' response draws.
#'
#' @param object A posterior model object or a `PosteriorIR` object.
#' @param variable Response variable selection on the left-hand side.
#' @param shock Shock selection on the left-hand side.
#' @param horizon Horizon selection on the left-hand side.
#' @param relation Comparison operator.
#' @param value Scalar comparison value for threshold statements.
#' @param compare_to Optional right-hand-side response specification with elements
#'   `variable`, `shock`, and `horizon`.
#' @param absolute If `TRUE`, compare absolute responses.
#' @param probability Equal-tailed interval probability used for gap summaries.
#' @param draws If `TRUE`, return draw-level gaps and indicators.
#' @param model Optional model identifier.
#' @param ... Additional arguments passed to computation methods.
#' @return A \code{bsvar_post_tbl} with columns \code{model},
#'   \code{object_type}, \code{variable}, \code{shock}, \code{horizon},
#'   \code{relation}, \code{posterior_prob}, \code{mean_gap},
#'   \code{median_gap}, \code{lower_gap}, and \code{upper_gap}.  When
#'   \code{draws = TRUE}, columns \code{draw}, \code{gap}, and
#'   \code{satisfied} replace the summary statistics.  Additional columns
#'   \code{rhs_variable}, \code{rhs_shock}, \code{rhs_horizon},
#'   \code{rhs_value}, and \code{absolute} describe the right-hand side.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' h <- hypothesis_irf(post, variable = "gdp", shock = "gdp",
#'                     horizon = 0:2, relation = ">", value = 0)
#' print(h)
#' @export
hypothesis_irf <- function(object, ...) {
  UseMethod("hypothesis_irf")
}

#' @rdname hypothesis_irf
#' @export
hypothesis_irf.default <- function(object, ...) {
  stop(
    "hypothesis_irf() requires a posterior model object or PosteriorIR array.\n",
    "Received object of class: ", paste(class(object), collapse = ", "),
    call. = FALSE
  )
}

response_max_horizon <- function(horizon, compare_to = NULL) {
  rhs_horizon <- if (is.null(compare_to)) numeric(0) else as.numeric(compare_to$horizon)
  max(c(as.numeric(horizon), rhs_horizon), na.rm = TRUE)
}

response_fetch_horizon <- function(horizon, compare_to = NULL) {
  max(1, response_max_horizon(horizon, compare_to))
}

normalise_compare_to <- function(compare_to) {
  if (is.null(compare_to)) {
    return(NULL)
  }
  needed <- c("variable", "shock", "horizon")
  if (!is.list(compare_to) || !all(needed %in% names(compare_to))) {
    stop("`compare_to` must be a list with elements `variable`, `shock`, and `horizon`.", call. = FALSE)
  }
  compare_to[needed]
}

append_hypothesis_rhs <- function(tbl, compare_to, value, absolute) {
  if (!is.null(compare_to)) {
    if (is.data.frame(compare_to)) {
      rhs_variable <- compare_to$variable
      rhs_shock <- compare_to$shock
      rhs_horizon <- compare_to$horizon
    } else {
      rhs_variable <- compare_to$variable
      rhs_shock <- compare_to$shock
      rhs_horizon <- compare_to$horizon
    }

    if (length(rhs_variable) == 1L) rhs_variable <- rep(rhs_variable, nrow(tbl))
    if (length(rhs_shock) == 1L) rhs_shock <- rep(rhs_shock, nrow(tbl))
    if (length(rhs_horizon) == 1L) rhs_horizon <- rep(rhs_horizon, nrow(tbl))

    tbl$rhs_variable <- rhs_variable
    tbl$rhs_shock <- rhs_shock
    tbl$rhs_horizon <- as.numeric(rhs_horizon)
    tbl$rhs_value <- NA_real_
  } else {
    tbl$rhs_variable <- NA_character_
    tbl$rhs_shock <- NA_character_
    tbl$rhs_horizon <- NA_real_
    tbl$rhs_value <- value
  }
  tbl$absolute <- absolute
  tbl
}

hypothesis_response_impl <- function(object, draws, object_type, variable, shock, horizon,
                                     relation = c("<", "<=", ">", ">=", "=="), value = 0,
                                     compare_to = NULL, absolute = FALSE, probability = 0.90,
                                     draws_out = FALSE, model = "model1") {
  relation <- match.arg(relation)
  compare_to <- normalise_compare_to(compare_to)

  predicate <- evaluate_draw_predicate(
    draws = draws,
    variable = variable,
    shock = shock,
    horizon = horizon,
    relation = relation,
    value = value,
    compare_to = compare_to,
    absolute = absolute
  )

  out <- summarise_gap_matrix(
    gap = predicate$gap,
    indicator = predicate$indicator,
    labels = predicate$labels,
    object_type = object_type,
    relation = relation,
    model = model,
    draws = draws_out,
    probability = probability
  )

  append_hypothesis_rhs(out, predicate$rhs_labels, value = value, absolute = absolute)
}

#' @rdname hypothesis_irf
#' @export
hypothesis_irf.PosteriorIR <- function(object, variable, shock, horizon,
                                       relation = c("<", "<=", ">", ">=", "=="), value = 0,
                                       compare_to = NULL, absolute = FALSE, probability = 0.90,
                                       draws = FALSE, model = "model1", ...) {
  hypothesis_response_impl(
    object = object,
    draws = object,
    object_type = "irf",
    variable = variable,
    shock = shock,
    horizon = horizon,
    relation = relation,
    value = value,
    compare_to = compare_to,
    absolute = absolute,
    probability = probability,
    draws_out = draws,
    model = model
  )
}

hypothesis_irf_model <- function(object, variable, shock, horizon,
                                 relation = c("<", "<=", ">", ">=", "=="), value = 0,
                                 compare_to = NULL, absolute = FALSE, probability = 0.90,
                                 draws = FALSE, model = "model1", ...) {
  irf_draws <- get_irf_draws(object, horizon = response_fetch_horizon(horizon, compare_to), ...)
  hypothesis_irf(
    irf_draws,
    variable = variable,
    shock = shock,
    horizon = horizon,
    relation = relation,
    value = value,
    compare_to = compare_to,
    absolute = absolute,
    probability = probability,
    draws = draws,
    model = model
  )
}

#' @rdname hypothesis_irf
#' @export
hypothesis_irf.PosteriorBSVAR <- hypothesis_irf_model
#' @export
hypothesis_irf.PosteriorBSVARMIX <- hypothesis_irf_model
#' @export
hypothesis_irf.PosteriorBSVARMSH <- hypothesis_irf_model
#' @export
hypothesis_irf.PosteriorBSVARSV <- hypothesis_irf_model
#' @export
hypothesis_irf.PosteriorBSVART <- hypothesis_irf_model
#' @export
hypothesis_irf.PosteriorBSVARSIGN <- hypothesis_irf_model

#' Posterior probability statements for cumulative dynamic multipliers
#'
#' @inheritParams hypothesis_irf
#' @param scale_by Optional scaling mode for CDMs.
#' @param scale_var Optional scaling variable specification.
#' @return A \code{bsvar_post_tbl} with columns \code{model},
#'   \code{object_type}, \code{variable}, \code{shock}, \code{horizon},
#'   \code{relation}, \code{posterior_prob}, \code{mean_gap},
#'   \code{median_gap}, \code{lower_gap}, and \code{upper_gap}.  When
#'   \code{draws = TRUE}, columns \code{draw}, \code{gap}, and
#'   \code{satisfied} replace the summary statistics.  Additional columns
#'   \code{rhs_variable}, \code{rhs_shock}, \code{rhs_horizon},
#'   \code{rhs_value}, and \code{absolute} describe the right-hand side.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' h <- hypothesis_cdm(post, variable = "gdp", shock = "gdp",
#'                     horizon = 0:2, relation = ">", value = 0)
#' print(h)
#' @export
hypothesis_cdm <- function(object, ...) {
  UseMethod("hypothesis_cdm")
}

#' @rdname hypothesis_cdm
#' @export
hypothesis_cdm.default <- function(object, ...) {
  stop(
    "hypothesis_cdm() requires a posterior model object or PosteriorCDM array.\n",
    "Received object of class: ", paste(class(object), collapse = ", "),
    call. = FALSE
  )
}

#' @rdname hypothesis_cdm
#' @export
hypothesis_cdm.PosteriorCDM <- function(object, variable, shock, horizon,
                                        relation = c("<", "<=", ">", ">=", "=="), value = 0,
                                        compare_to = NULL, absolute = FALSE, probability = 0.90,
                                        draws = FALSE, model = "model1", ...) {
  hypothesis_response_impl(
    object = object,
    draws = object,
    object_type = "cdm",
    variable = variable,
    shock = shock,
    horizon = horizon,
    relation = relation,
    value = value,
    compare_to = compare_to,
    absolute = absolute,
    probability = probability,
    draws_out = draws,
    model = model
  )
}

hypothesis_cdm_model <- function(object, variable, shock, horizon,
                                 relation = c("<", "<=", ">", ">=", "=="), value = 0,
                                 compare_to = NULL, absolute = FALSE, probability = 0.90,
                                 draws = FALSE, model = "model1",
                                 scale_by = c("none", "shock_sd"), scale_var = NULL, ...) {
  cdm_horizon <- response_fetch_horizon(horizon, compare_to)
  cdm_draws <- get_cdm_draws(
    object,
    horizon = cdm_horizon,
    probability = probability,
    scale_by = scale_by,
    scale_var = scale_var,
    ...
  )
  hypothesis_cdm(
    cdm_draws,
    variable = variable,
    shock = shock,
    horizon = horizon,
    relation = relation,
    value = value,
    compare_to = compare_to,
    absolute = absolute,
    probability = probability,
    draws = draws,
    model = model
  )
}

#' @rdname hypothesis_cdm
#' @export
hypothesis_cdm.PosteriorBSVAR <- hypothesis_cdm_model
#' @export
hypothesis_cdm.PosteriorBSVARMIX <- hypothesis_cdm_model
#' @export
hypothesis_cdm.PosteriorBSVARMSH <- hypothesis_cdm_model
#' @export
hypothesis_cdm.PosteriorBSVARSV <- hypothesis_cdm_model
#' @export
hypothesis_cdm.PosteriorBSVART <- hypothesis_cdm_model
#' @export
hypothesis_cdm.PosteriorBSVARSIGN <- hypothesis_cdm_model
