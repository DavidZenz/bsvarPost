#' Build a publication-ready bsvarPost plot
#'
#' This helper detects a supported `bsvarPost` output family, constructs the
#' corresponding plot when needed, and applies the matching plot template plus
#' optional annotations.
#'
#' @param object A `ggplot` object, `bsvar_post_tbl`, representative-response
#'   object, or report bundle.
#' @param family Optional output family override.
#' @param preset One of `"default"`, `"paper"`, or `"slides"`.
#' @param title Optional plot title.
#' @param subtitle Optional plot subtitle.
#' @param caption Optional plot caption.
#' @param base_size Base font size for the applied theme.
#' @param base_family Base font family for the applied theme.
#' @param ... Additional arguments passed to the underlying plot constructor
#'   when `object` is not already a `ggplot`.
#' @return A \code{ggplot} object.
#' @examples
#' data(us_fiscal_lsuw, package = "bsvars")
#' spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
#' post <- bsvars::estimate(spec, S = 5, show_progress = FALSE)
#'
#' irf_tbl <- tidy_irf(post, horizon = 3)
#' p <- publish_bsvar_plot(irf_tbl)
#' @export
publish_bsvar_plot <- function(object, family = NULL,
                               preset = c("default", "paper", "slides"),
                               title = NULL, subtitle = NULL, caption = NULL,
                               base_size = 11, base_family = "", ...) {
  preset <- match.arg(preset)

  detected_family <- family %||% infer_publication_family(object)
  if (is.null(detected_family)) {
    stop("`publish_bsvar_plot()` could not infer a supported output family.", call. = FALSE)
  }

  plot <- build_publication_plot(object, detected_family, ...)
  plot <- template_bsvar_plot(
    plot,
    family = detected_family,
    preset = preset,
    base_size = base_size,
    base_family = base_family
  )

  annotate_bsvar_plot(
    plot,
    title = title %||% default_publication_title(object, detected_family),
    subtitle = subtitle %||% default_publication_subtitle(object, detected_family),
    caption = caption
  )
}

infer_publication_family <- function(object) {
  if (inherits(object, "ggplot")) return("comparison")
  if (inherits(object, "bsvar_report_bundle")) return(infer_publication_family(object$plot))
  if (inherits(object, "RepresentativeResponse")) return("representative")
  if (!inherits(object, "bsvar_post_tbl")) return(NULL)

  object_type <- attr(object, "object_type") %||% ""
  if (identical(object_type, "hd")) return("hd")
  if (identical(object_type, "acceptance_diagnostics")) return("acceptance_diagnostics")
  if (identical(object_type, "hd_event")) return("hd_event")
  if (identical(object_type, "shock_ranking")) return("shock_ranking")
  if (identical(object_type, "restriction_audit")) return("restriction_audit")
  if (grepl("^simultaneous_", object_type)) return("simultaneous")
  if (grepl("^joint_", object_type)) return("joint_hypothesis")
  if (isTRUE(attr(object, "compare"))) return("comparison")
  if (object_type %in% c("irf", "cdm", "forecast")) return(object_type)
  if ("posterior_prob" %in% names(object)) return("hypothesis")
  NULL
}

build_publication_plot <- function(object, family, ...) {
  if (inherits(object, "bsvar_report_bundle")) {
    return(object$plot)
  }
  if (inherits(object, "ggplot")) {
    return(object)
  }
  if (inherits(object, "RepresentativeResponse")) {
    return(build_representative_plot(object))
  }

  switch(
    family,
    hd = plot_hd_overlay(object, ...),
    acceptance_diagnostics = plot_acceptance_diagnostics(object, ...),
    hd_event = plot_hd_event(object, ...),
    shock_ranking = plot_shock_ranking(object, ...),
    restriction_audit = plot_restriction_audit(object, ...),
    simultaneous = plot_simultaneous(object, ...),
    joint_hypothesis = plot_joint_hypothesis(object, ...),
    hypothesis = plot_hypothesis(object, ...),
    comparison = if (inherits(object, "bsvar_post_tbl") &&
      identical(attr(object, "object_type"), "restriction_audit")) {
      plot_compare_restrictions(object, ...)
    } else if (inherits(object, "bsvar_post_tbl") && isTRUE(attr(object, "compare"))) {
      plot_compare_response(object, ...)
    } else {
      ggplot2::autoplot(object, ...)
    },
    ggplot2::autoplot(object, ...)
  )
}

default_publication_title <- function(object, family) {
  if (inherits(object, "bsvar_report_bundle")) {
    return(object$caption %||% NULL)
  }
  switch(
    family,
    irf = "Impulse responses",
    cdm = "Cumulative dynamic multipliers",
    forecast = "Forecast summary",
    hd = "Historical decomposition",
    hd_event = "Event-window historical decomposition",
    shock_ranking = "Shock ranking by event contribution",
    hypothesis = "Posterior probability statement",
    restriction_audit = "Restriction audit",
    simultaneous = "Simultaneous posterior bands",
    joint_hypothesis = "Joint posterior statement",
    acceptance_diagnostics = "Acceptance diagnostics",
    representative = "Representative structural response",
    comparison = "Model comparison",
    NULL
  )
}

default_publication_subtitle <- function(object, family) {
  if (inherits(object, "RepresentativeResponse")) {
    return(paste("Method:", object$method))
  }
  if (!inherits(object, "bsvar_post_tbl")) {
    return(NULL)
  }

  object_type <- attr(object, "object_type") %||% ""
  if (identical(object_type, "acceptance_diagnostics")) {
    return("Stored-draw admissibility diagnostics")
  }
  if (identical(object_type, "hd")) {
    return("Full-sample contribution paths")
  }
  if (identical(object_type, "hd_event") && all(c("event_start", "event_end") %in% names(object))) {
    return(sprintf("Window: %s to %s", object$event_start[1], object$event_end[1]))
  }
  if (identical(object_type, "shock_ranking") && all(c("event_start", "event_end") %in% names(object))) {
    return(sprintf("Window: %s to %s", object$event_start[1], object$event_end[1]))
  }
  if (grepl("^joint_", object_type) && "relation" %in% names(object)) {
    return(sprintf("Relation: %s", object$relation[1]))
  }
  if (grepl("^simultaneous_", object_type) && "simultaneous_prob" %in% names(object)) {
    return(sprintf("Coverage: %.2f", object$simultaneous_prob[1]))
  }
  if (identical(object_type, "restriction_audit")) {
    return("Posterior restriction satisfaction")
  }
  NULL
}
