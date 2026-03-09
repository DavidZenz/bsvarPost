#' @keywords internal
pretty_restriction_label <- function(restriction_type, variable, shock, horizon, relation, raw_label) {
  if (startsWith(restriction_type, "irf_")) {
    return(sprintf("IRF: %s response to %s shock at h = %s %s", variable, shock, horizon, relation))
  }
  if (identical(restriction_type, "structural_sign")) {
    return(sprintf("Structural: %s on %s shock %s", variable, shock, relation))
  }
  if (startsWith(restriction_type, "narrative_")) {
    type <- sub("^narrative_", "", restriction_type)
    if (!is.na(variable) && nzchar(variable)) {
      return(sprintf("Narrative %s: %s, shock %s, window = %s, %s", type, variable, shock, horizon, relation))
    }
    return(sprintf("Narrative %s: shock %s, window = %s, %s", type, shock, horizon, relation))
  }
  raw_label
}

#' @keywords internal
resolve_restriction_plot_labels <- function(df, label_style = c("raw", "pretty"), labels = NULL) {
  label_style <- match.arg(label_style)
  display <- df$restriction

  if (identical(label_style, "pretty")) {
    display <- vapply(
      seq_len(nrow(df)),
      function(i) pretty_restriction_label(
        restriction_type = df$restriction_type[i],
        variable = df$variable[i],
        shock = df$shock[i],
        horizon = df$horizon[i],
        relation = df$relation[i],
        raw_label = df$restriction[i]
      ),
      character(1)
    )
  }

  if (!is.null(labels)) {
    if (is.null(names(labels)) || any(names(labels) == "")) {
      stop("`labels` must be a named character vector keyed by raw restriction labels.", call. = FALSE)
    }
    matched <- match(df$restriction, names(labels))
    has_match <- !is.na(matched)
    display[has_match] <- unname(labels[matched[has_match]])
  }

  display
}

#' Plot posterior probability statements for IRFs or CDMs
#'
#' @param object A hypothesis table, a magnitude-audit table, or an object
#'   accepted by `hypothesis_irf()` / `hypothesis_cdm()`.
#' @param type One of `"irf"` or `"cdm"` when `object` is not already a tidy
#'   posterior-statement table.
#' @param variable Optional left-hand-side response variable selection.
#' @param shock Optional left-hand-side shock selection.
#' @param horizon Optional left-hand-side horizon selection.
#' @param relation Comparison operator.
#' @param value Scalar comparison value for threshold statements.
#' @param compare_to Optional right-hand-side response specification.
#' @param absolute If `TRUE`, compare absolute responses.
#' @param probability Equal-tailed interval probability used for gap summaries.
#' @param models Optional model filter.
#' @param scale_by Optional scaling mode for CDMs.
#' @param scale_var Optional scaling variable specification.
#' @param ... Additional arguments passed to computation methods.
#' @export
plot_hypothesis <- function(object, type = c("irf", "cdm"),
                            variable = NULL, shock = NULL, horizon = NULL,
                            relation = c("<", "<=", ">", ">=", "=="), value = 0,
                            compare_to = NULL, absolute = FALSE, probability = 0.68,
                            models = NULL, scale_by = c("none", "shock_sd"),
                            scale_var = NULL, ...) {
  type <- match.arg(type)
  relation <- match.arg(relation)

  table_input <- inherits(object, "bsvar_post_tbl")
  if (table_input) {
    tbl <- object
  } else if (identical(type, "irf")) {
    tbl <- hypothesis_irf(
      object,
      variable = variable,
      shock = shock,
      horizon = horizon,
      relation = relation,
      value = value,
      compare_to = compare_to,
      absolute = absolute,
      probability = probability,
      ...
    )
  } else {
    tbl <- hypothesis_cdm(
      object,
      variable = variable,
      shock = shock,
      horizon = horizon,
      relation = relation,
      value = value,
      compare_to = compare_to,
      absolute = absolute,
      probability = probability,
      scale_by = scale_by,
      scale_var = scale_var,
      ...
    )
  }

  needed <- c("posterior_prob", "relation", "variable", "shock", "horizon")
  object_type <- attr(tbl, "object_type")
  is_magnitude <- "audit_type" %in% names(tbl) && identical(tbl$audit_type[1], "magnitude")
  valid_type <- identical(object_type, "irf") || identical(object_type, "cdm") || is_magnitude
  if (!inherits(tbl, "bsvar_post_tbl") || !all(needed %in% names(tbl)) || !valid_type) {
    stop("`plot_hypothesis()` requires a hypothesis or magnitude-audit table, or an object that can be converted to one.", call. = FALSE)
  }

  df <- tbl
  if (table_input && !is.null(variable)) df <- df[df$variable %in% variable, , drop = FALSE]
  if (table_input && !is.null(shock)) df <- df[df$shock %in% shock, , drop = FALSE]
  if (table_input && !is.null(horizon)) df <- df[df$horizon %in% horizon, , drop = FALSE]
  if (!is.null(models)) df <- df[df$model %in% models, , drop = FALSE]
  if (!nrow(df)) {
    stop("No posterior statements remain after filtering.", call. = FALSE)
  }

  p <- ggplot2::ggplot(
    df,
    ggplot2::aes(x = horizon, y = posterior_prob, colour = model, group = model)
  ) +
    ggplot2::geom_line(linewidth = 0.7) +
    ggplot2::geom_point(size = 1.8) +
    ggplot2::coord_cartesian(ylim = c(0, 1)) +
    ggplot2::facet_grid(rows = ggplot2::vars(variable), cols = ggplot2::vars(shock), scales = "free_x") +
    ggplot2::labs(
      x = "horizon",
      y = "posterior probability",
      colour = if (length(unique(df$model)) > 1L) "model" else NULL
    )

  template_bsvar_plot(p, family = "hypothesis")
}

#' Plot restriction-audit summaries
#'
#' @param object A restriction-audit table or an object accepted by
#'   `restriction_audit()`.
#' @param restrictions Optional restriction helper list passed through to
#'   `restriction_audit()` when `object` is not already an audit table.
#' @param zero_tol Numerical tolerance for zero restrictions.
#' @param probability Equal-tailed interval probability used in summaries.
#' @param models Optional model filter.
#' @param label_style Restriction label style: `"raw"` or `"pretty"`.
#' @param labels Optional named character vector overriding restriction labels by
#'   raw restriction string.
#' @param restriction_types Optional restriction-type filter.
#' @param ... Additional arguments passed to `restriction_audit()`.
#' @export
plot_restriction_audit <- function(object, restrictions = NULL, zero_tol = 1e-8,
                                   probability = 0.68, models = NULL,
                                   label_style = c("raw", "pretty"),
                                   labels = NULL,
                                   restriction_types = NULL, ...) {
  label_style <- match.arg(label_style)
  if (inherits(object, "bsvar_post_tbl")) {
    tbl <- object
  } else {
    tbl <- restriction_audit(
      object,
      restrictions = restrictions,
      zero_tol = zero_tol,
      probability = probability,
      ...
    )
  }

  if (!identical(attr(tbl, "object_type"), "restriction_audit")) {
    stop("`plot_restriction_audit()` requires a restriction-audit table or an object that can be converted to one.", call. = FALSE)
  }

  df <- tbl
  if (!is.null(models)) df <- df[df$model %in% models, , drop = FALSE]
  if (!is.null(restriction_types)) {
    df <- df[df$restriction_type %in% restriction_types, , drop = FALSE]
  }
  if (!nrow(df)) {
    stop("No restriction-audit rows remain after filtering.", call. = FALSE)
  }
  df$restriction_display <- resolve_restriction_plot_labels(df, label_style = label_style, labels = labels)

  p <- ggplot2::ggplot(
    df,
    ggplot2::aes(x = stats::reorder(restriction_display, posterior_prob), y = posterior_prob, fill = model)
  ) +
    ggplot2::geom_col(position = "dodge") +
    ggplot2::coord_flip() +
    ggplot2::labs(
      x = NULL,
      y = "posterior satisfaction probability",
      fill = if (length(unique(df$model)) > 1L) "model" else NULL
    )

  template_bsvar_plot(p, family = "restriction_audit")
}
