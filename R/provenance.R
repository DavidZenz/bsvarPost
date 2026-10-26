#' Provenance columns in posterior tables
#'
#' Posterior tables retain the existing estimate and identifier columns and add
#' ordinary columns describing how the result was computed. These columns are
#' included in default reports and CSV exports; compact reports omit most of
#' them. Unknown or inapplicable values are typed `NA`.
#'
#' @section Columns:
#' * `analysis_type`: response, hypothesis, joint hypothesis, simultaneous band,
#'   representative selection, response timing, or diagnostic analysis.
#' * `interval_probability` and `interval_method`: the mass and construction of
#'   intervals actually reported, `equal_tailed` or `empirical_sup_norm`.
#' * `scale_by`, `scale_var`, and `scale_factor`: response normalisation. A
#'   `shock_sd` response is divided by the reported sample standard deviation.
#' * `units`: known units such as FEVD percentages or response-timing periods;
#'   economic units are left unknown when they cannot be recovered.
#' * `source_package` and `source_version`: the upstream package used for the
#'   current computation. They do not reconstruct estimation software history.
#' * `n_draws`: number of posterior draws used for the result.
#' * `draw_id`: original draw labels in draw-level tables. The integer `draw`
#'   column retains positional indexing.
#' * `selected_draw_id`: original label of a representative draw; `draw_index`
#'   remains its positional index.
#'
#' Existing `object_type`, `draws`, and `compare` attributes remain supported.
#' Legacy tables without provenance columns can still be plotted when their
#' analysis is unambiguous from the existing columns and attributes.
#'
#' @name posterior_provenance
#' @seealso [tidy_irf()], [report_table()], [write_bsvar_csv()]
NULL

# Provenance is stored in ordinary columns so it survives CSV and table exports.
post_metadata_defaults <- function(n) {
  list(analysis_type = rep(NA_character_, n),
       interval_probability = rep(NA_real_, n), interval_method = rep(NA_character_, n),
       scale_by = rep(NA_character_, n), scale_var = rep(NA_character_, n),
       scale_factor = rep(NA_real_, n), units = rep(NA_character_, n),
       source_package = rep(NA_character_, n), source_version = rep(NA_character_, n),
       n_draws = rep(NA_integer_, n))
}

draw_counts <- function(x) {
  groups <- vctrs::vec_group_id(as.data.frame(x["model"]))
  ids <- if ("draw_id" %in% names(x)) x$draw_id else x$draw
  pairs <- vctrs::vec_unique(data.frame(model_id = as.integer(groups), draw_id = ids))
  tabulate(pairs$model_id, nbins = attr(groups, "n"))[as.integer(groups)]
}

infer_analysis_type <- function(x, object_type) {
  if ("draw_index" %in% names(x)) return("representative")
  if (object_type %in% c("irf", "cdm") &&
      any(c("posterior_prob", "satisfied") %in% names(x))) return("hypothesis")
  if (grepl("^joint_", object_type)) return("joint_hypothesis")
  if (grepl("^simultaneous_", object_type)) return("simultaneous")
  for (type in c("peak", "duration", "half_life", "time_to_threshold")) {
    if (startsWith(object_type, paste0(type, "_"))) return(type)
  }
  if (object_type %in% c("hd_event", "shock_ranking", "restriction_audit", "acceptance_diagnostics")) return(object_type)
  "response"
}

# One family decision is shared by plotting, reporting and publication styling.
# Column-based inference keeps legacy tables usable without provenance columns.
posterior_plot_family <- function(object) {
  if (inherits(object, "ggplot")) return("comparison")
  if (inherits(object, "bsvar_report_bundle")) {
    return(object$plot_family %||% posterior_plot_family(object$plot))
  }
  if (inherits(object, "RepresentativeResponse")) return("representative")
  if (!inherits(object, "bsvar_post_tbl")) return(NULL)
  type <- attr(object, "object_type", exact = TRUE)
  if (is.null(type) && "object_type" %in% names(object) && length(unique(object$object_type)) == 1L) {
    type <- unique(object$object_type)
  }
  if (is.null(type)) return(NULL)
  if ("gap" %in% names(object) && "satisfied" %in% names(object)) return(NULL)
  if (identical(type, "hd_event") && "draw" %in% names(object)) return(NULL)
  analysis <- infer_analysis_type(object, type)
  if (identical(analysis, "hypothesis")) return("hypothesis")
  if (identical(analysis, "joint_hypothesis")) return("joint_hypothesis")
  if (identical(analysis, "simultaneous")) return("simultaneous")
  if (analysis %in% c("peak", "duration", "half_life", "time_to_threshold")) {
    return(if (isTRUE(attr(object, "compare"))) "response_comparison" else NULL)
  }
  if (identical(type, "restriction_audit") && isTRUE(attr(object, "compare"))) return("restriction_comparison")
  if (type %in% c("hd", "hd_event", "shock_ranking", "restriction_audit", "acceptance_diagnostics")) return(type)
  if (isTRUE(attr(object, "compare"))) return("comparison")
  if (type %in% c("irf", "cdm", "forecast", "fevd", "shocks")) return(type)
  NULL
}

mark_posterior_source <- function(x, model) {
  if (is.null(model) || !is_supported_posterior_model(model)) return(x)
  pkg <- if (inherits(model, "PosteriorBSVARSIGN")) "bsvarSIGNs" else "bsvars"
  attr(x, "source_package") <- pkg
  attr(x, "source_version") <- as.character(utils::packageVersion(pkg))
  x
}

copy_posterior_attributes <- function(x, source) {
  for (field in c("source_package", "source_version", "scale_by", "scale_var", "scale_factors", "probability")) {
    value <- attr(source, field, exact = TRUE)
    if (!is.null(value)) attr(x, field) <- value
  }
  x
}

with_post_provenance <- function(x, source = NULL, probability = NULL, n_draws = NULL) {
  n <- nrow(x)
  if (is.data.frame(source)) {
    if ("draw" %in% names(source)) source$n_draws <- as.integer(draw_counts(source))
    keys <- intersect(c("model", "variable", "shock"), intersect(names(x), names(source)))
    if (length(keys) && nrow(source)) {
      matched <- vctrs::vec_match(as.data.frame(x[keys]), as.data.frame(source[keys]))
      for (field in setdiff(names(post_metadata_defaults(0)), "analysis_type")) {
        if (field %in% names(source)) x[[field]] <- source[[field]][matched]
      }
    }
  } else if (!is.null(source)) {
    pkg <- attr(source, "source_package", exact = TRUE)
    version <- attr(source, "source_version", exact = TRUE)
    if (is_supported_posterior_model(source)) {
      pkg <- if (inherits(source, "PosteriorBSVARSIGN")) "bsvarSIGNs" else "bsvars"
      version <- as.character(utils::packageVersion(pkg))
      posterior <- source$posterior
      array <- posterior$Q %||% posterior$A %||% posterior$B
      if (is.null(n_draws) && length(dim(array)) == 3L) n_draws <- dim(array)[3]
    } else if (is.array(source)) {
      if (is.null(n_draws)) n_draws <- utils::tail(dim(source), 1L)
      scale_by <- attr(source, "scale_by", exact = TRUE) %||% "none"
      x$scale_by <- rep(scale_by, n)
      x$scale_factor <- rep(1, n)
      factors <- attr(source, "scale_factors", exact = TRUE)
      variables <- attr(source, "scale_var", exact = TRUE)
      if (!is.null(factors) && "shock" %in% names(x)) {
        labels <- dimnames(source)[[2]] %||% paste0("shock", seq_len(dim(source)[2]))
        shock_index <- match(x$shock, labels)
        x$scale_factor <- as.numeric(factors[shock_index])
        if (!is.null(variables)) {
          variables <- rep(variables, length.out = length(labels))
          x$scale_var <- as.character(variables[shock_index])
        } else if (identical(scale_by, "shock_sd")) {
          variable_labels <- dimnames(source)[[1]]
          x$scale_var <- if (!is.null(variable_labels) && length(variable_labels) == length(labels)) {
            as.character(variable_labels[shock_index])
          } else rep(NA_character_, n)
        }
      }
    }
    if (!is.null(pkg)) x$source_package <- rep(pkg, n)
    if (!is.null(version)) x$source_version <- rep(version, n)
  }
  if (!is.null(n_draws)) x$n_draws <- rep(as.integer(n_draws), n)
  if (!is.null(probability)) {
    validate_probability(probability)
    lower <- intersect(c("lower", "lower_gap", "lower_value", "lower_duration", "lower_half_life", "lower_horizon"), names(x))
    has_interval <- if (length(lower)) !is.na(x[[lower[1]]]) else rep(FALSE, n)
    x$interval_probability <- ifelse(has_interval, probability, NA_real_)
    method <- if (identical(unique(x$analysis_type), "simultaneous")) "empirical_sup_norm" else "equal_tailed"
    x$interval_method <- ifelse(has_interval, method, NA_character_)
  }
  x
}
