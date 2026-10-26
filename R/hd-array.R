get_hd_draws <- function(object, model = NULL) {
  if (inherits(object, "PosteriorHD")) {
    validate_draw_array(object, 4L, "historical decomposition")
    d <- dim(object)
    dimnames(object) <- resolve_array_dimnames(object, list(
      paste0("variable", seq_len(d[1])), paste0("shock", seq_len(d[2])),
      as.character(seq_len(d[3])), as.character(seq_len(d[4]))))
    return(object)
  }
  validate_posterior_object(object)
  if (inherits(object, "PosteriorBSVARSIGN")) validate_sign_posterior(object)
  out <- bsvars::compute_historical_decompositions(object, show_progress = FALSE)
  set_hd_dimnames(out, model = object)
}

sum_hd_array_components <- function(draws, components) {
  d <- dim(draws)
  dns <- dimnames(draws)
  labels <- unique(components)
  out <- array(0, c(d[1], length(labels), d[3], d[4]),
               dimnames = list(dns[[1]], labels, dns[[3]], dns[[4]]))
  for (j in seq_along(labels)) {
    selected <- which(components == labels[j])
    out[, j, , ] <- apply(draws[, selected, , , drop = FALSE], c(1L, 3L, 4L), sum)
  }
  class(out) <- "PosteriorHD"
  copy_posterior_attributes(out, draws)
}

prepare_hd_array_summary <- function(object, probability, variables, shocks, models,
                                     shock_groups, top_n, collapse_other, include_observed, model) {
  draws <- get_hd_draws(object)
  dns <- dimnames(draws)
  variables_keep <- if (is.null(variables)) seq_along(dns[[1]]) else which(dns[[1]] %in% variables)
  shocks_keep <- if (is.null(shocks)) seq_along(dns[[2]]) else which(dns[[2]] %in% shocks)
  if (!length(variables_keep) || !length(shocks_keep) || (!is.null(models) && !model %in% models)) {
    stop("No historical decomposition rows remain after filtering.", call. = FALSE)
  }
  selected <- copy_posterior_attributes(draws[variables_keep, shocks_keep, , , drop = FALSE], draws)
  class(selected) <- "PosteriorHD"
  components <- map_hd_component(dimnames(selected)[[2]], shock_groups, collapse_other)
  grouped <- sum_hd_array_components(selected, components)
  summary <- as_tidy_hd_array(grouped, model = model, probability = probability)
  summary$component <- summary$shock
  if (!is.null(top_n)) {
    summary$original_component <- summary$component
    ranked <- apply_hd_top_n(summary, top_n, collapse_other)
    mapping <- unique(as.data.frame(ranked[c("variable", "original_component", "component")]))
    rows <- lapply(seq_len(dim(grouped)[1]), function(i) {
      panel <- mapping[mapping$variable == dimnames(grouped)[[1]][i], , drop = FALSE]
      matched <- match(dimnames(grouped)[[2]], panel$original_component)
      keep <- !is.na(matched)
      panel_draws <- copy_posterior_attributes(grouped[i, keep, , , drop = FALSE], grouped)
      panel_draws <- sum_hd_array_components(panel_draws, panel$component[matched[keep]])
      out <- as_tidy_hd_array(panel_draws, model = model, probability = probability)
      out$component <- out$shock
      out
    })
    summary <- do.call(rbind, rows)
  }
  observed <- if (isTRUE(include_observed)) extract_hd_observed_data(object, model) else NULL
  if (!is.null(observed)) observed <- filter_hd_rows(observed, variables = variables, models = models)
  list(components = summary, component_draws = NULL, observed = observed)
}
