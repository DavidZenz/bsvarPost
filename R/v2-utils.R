bsvarsigns_native_cache <- new.env(parent = emptyenv())

bsvarsigns_native_symbol <- function(symbol) {
  cached <- bsvarsigns_native_cache[[symbol]]
  if (!is.null(cached)) {
    return(cached)
  }
  resolved <- getNativeSymbolInfo(symbol, PACKAGE = "bsvarSIGNs")
  bsvarsigns_native_cache[[symbol]] <- resolved$address
  resolved$address
}

bsvarsigns_native <- function(symbol, ...) {
  do.call(base::.Call, c(list(bsvarsigns_native_symbol(symbol)), list(...)))
}

bsvarsigns_match_sign <- function(A, sign) {
  bsvarsigns_native("_bsvarSIGNs_match_sign", A, sign)
}

bsvarsigns_match_sign_irf <- function(Q, sign_irf, irf) {
  bsvarsigns_native("_bsvarSIGNs_match_sign_irf", Q, sign_irf, irf)
}

bsvarsigns_match_sign_narrative <- function(epsilon, sign_narrative, irf) {
  bsvarsigns_native("_bsvarSIGNs_match_sign_narrative", epsilon, sign_narrative, irf)
}

bsvarsigns_weight_narrative <- function(T, sign_narrative, irf) {
  bsvarsigns_native("_bsvarSIGNs_weight_narrative", as.integer(T), sign_narrative, irf)
}

bsvarsigns_weight_zero <- function(Z, B, h_inv, Q) {
  bsvarsigns_native("_bsvarSIGNs_weight_zero", Z, B, h_inv, Q)
}

bsvarsigns_hd1 <- function(var_i, t, h, epsilon, irf) {
  bsvarsigns_native("_bsvarSIGNs_hd1_cpp", as.integer(var_i), as.integer(t), as.integer(h), epsilon, irf)
}

get_irf_draws <- function(object, horizon = 10, ...) {
  if (inherits(object, "PosteriorIR")) {
    return(object)
  }
  bsvars::compute_impulse_responses(object, horizon = horizon, ...)
}

get_cdm_draws <- function(object, horizon = 10, probability = 0.68,
                          scale_by = c("none", "shock_sd"), scale_var = NULL, ...) {
  if (inherits(object, "PosteriorCDM")) {
    return(object)
  }
  cdm(object, horizon = horizon, probability = probability, scale_by = scale_by, scale_var = scale_var, ...)
}

resolve_selection <- function(values, labels) {
  if (is.null(values)) {
    return(seq_along(labels))
  }
  if (is.character(values)) {
    idx <- match(values, labels)
    if (anyNA(idx)) {
      stop("Unknown selection label(s): ", paste(values[is.na(idx)], collapse = ", "), call. = FALSE)
    }
    return(idx)
  }
  idx <- as.integer(values)
  if (anyNA(idx) || any(idx < 1L) || any(idx > length(labels))) {
    stop("Selection indices are out of bounds.", call. = FALSE)
  }
  idx
}

subset_response_draws <- function(draws, variables = NULL, shocks = NULL, horizons = NULL) {
  dns <- resolve_array_dimnames(draws, list(
    paste0("variable", seq_len(dim(draws)[1])),
    paste0("shock", seq_len(dim(draws)[2])),
    as.character(seq_len(dim(draws)[3]) - 1L),
    as.character(seq_len(dim(draws)[4]))
  ))

  var_idx <- resolve_selection(variables, dns[[1]])
  shock_idx <- resolve_selection(shocks, dns[[2]])
  hor_idx <- resolve_selection(if (is.null(horizons)) NULL else as.character(horizons), dns[[3]])

  out <- draws[var_idx, shock_idx, hor_idx, , drop = FALSE]
  dimnames(out) <- list(dns[[1]][var_idx], dns[[2]][shock_idx], dns[[3]][hor_idx], dns[[4]])

  list(
    draws = out,
    indices = list(variable = var_idx, shock = shock_idx, horizon = hor_idx),
    labels = list(variable = dns[[1]][var_idx], shock = dns[[2]][shock_idx], horizon = dns[[3]][hor_idx])
  )
}

draw_matrix <- function(draws) {
  d <- dim(draws)
  matrix(as.numeric(draws), nrow = prod(d[1:3]), ncol = d[4])
}

selection_target <- function(draws, center = c("median", "mean")) {
  center <- match.arg(center)
  mat <- draw_matrix(draws)
  if (identical(center, "mean")) {
    rowMeans(mat)
  } else {
    apply(mat, 1, stats::median)
  }
}

selection_scales <- function(draws, standardize = c("none", "sd")) {
  standardize <- match.arg(standardize)
  mat <- draw_matrix(draws)
  scales <- rep(1, nrow(mat))
  if (identical(standardize, "sd")) {
    scales <- apply(mat, 1, stats::sd)
    scales[is.na(scales) | scales == 0] <- 1
  }
  scales
}

selection_weights <- function(draws, metric = c("l2", "weighted_l2")) {
  metric <- match.arg(metric)
  mat <- draw_matrix(draws)
  weights <- rep(1, nrow(mat))
  if (identical(metric, "weighted_l2")) {
    sds <- apply(mat, 1, stats::sd)
    sds[is.na(sds) | sds == 0] <- 1
    weights <- 1 / (sds^2)
  }
  weights
}

distance_to_target <- function(draws, target, metric = c("l2", "weighted_l2"), standardize = c("none", "sd")) {
  metric <- match.arg(metric)
  standardize <- match.arg(standardize)
  mat <- draw_matrix(draws)
  scales <- selection_scales(draws, standardize = standardize)
  weights <- selection_weights(draws, metric = metric)
  diffs <- (mat - target) / scales
  colSums((diffs^2) * weights)
}

normalise_sign_restrictions <- function(sign_irf) {
  sign <- sign_irf
  sign[is.na(sign)] <- 0
  sign
}

get_zero_restriction_Z <- function(sign_irf) {
  if (!inherits(sign_irf, "array")) {
    sign_irf <- array(sign_irf, dim = c(dim(sign_irf), 1L))
  }

  h <- dim(sign_irf)[3]
  if (h >= 2L) {
    test <- sign_irf[, , 2:h, drop = FALSE]
    test_values <- test[!is.na(test)]
    if (length(test_values) > 0L && any(test_values == 0)) {
      stop("Zero restrictions are not allowed for horizons >= 1", call. = FALSE)
    }
  }

  zero_irf <- sign_irf[, , 1, drop = TRUE] == 0
  zero_irf[is.na(zero_irf)] <- FALSE
  if (sum(zero_irf) == 0L) {
    return(NULL)
  }

  n_shocks <- dim(zero_irf)[2]
  Z <- vector("list", n_shocks)
  for (j in seq_len(n_shocks)) {
    z_j <- diag(zero_irf[, j])
    nonzero_rows <- rowSums(z_j) > 0
    z_j <- as.matrix(z_j[nonzero_rows, , drop = FALSE])
    if (ncol(z_j) == 1L) {
      z_j <- as.matrix(t(z_j))
    }
    if (nrow(z_j) > n_shocks - j) {
      stop("Too many zero restrictions for shock ", j, call. = FALSE)
    }
    Z[[j]] <- z_j
  }

  Z
}

reduced_irf_from_structural <- function(structural_irf, Q) {
  d <- dim(structural_irf)
  out <- array(NA_real_, d)
  for (h in seq_len(d[3])) {
    out[, , h] <- structural_irf[, , h] %*% t(Q)
  }
  out
}

compute_posterior_kernel <- function(object) {
  if (!inherits(object, "PosteriorBSVARSIGN")) {
    stop("Posterior-kernel ranking is only implemented for 'PosteriorBSVARSIGN'.", call. = FALSE)
  }

  posterior <- object$posterior
  identification <- object$last_draw$identification
  Y <- t(object$last_draw$data_matrices$Y)
  X <- t(object$last_draw$data_matrices$X)
  p <- object$last_draw$p
  T_obs <- nrow(Y)
  S <- dim(posterior$Q)[3]

  sign_irf <- normalise_sign_restrictions(identification$sign_irf)
  sign_structural <- identification$sign_structural
  sign_structural[is.na(sign_structural)] <- 0
  Z <- get_zero_restriction_Z(identification$sign_irf)

  if (length(identification$sign_narrative) > 0) {
    get_type <- c(S = 1, A = 2, B = 3)
    sign_narrative <- matrix(NA_real_, length(identification$sign_narrative), 6)
    for (i in seq_along(identification$sign_narrative)) {
      item <- identification$sign_narrative[[i]]
      sign_narrative[i, ] <- c(get_type[[item$type]], item$sign, item$var, item$shock, item$start - p, item$periods - 1)
    }
  } else {
    sign_narrative <- matrix(c(0, 1, 1, 1, 1, 1), nrow = 1)
  }

  irf <- get_irf_draws(object, horizon = max(dim(sign_irf)[3] - 1L, sign_narrative[, 6], 0), standardise = FALSE)
  scores <- rep(1, S)

  has_narrative <- sign_narrative[1, 1] != 0
  has_zero <- length(Z) > 0

  for (s in seq_len(S)) {
    Q <- posterior$Q[, , s]
    A_t <- t(posterior$A[, , s])
    B0 <- posterior$B[, , s]
    h_inv <- Q %*% B0
    reduced_irf <- reduced_irf_from_structural(irf[, , , s, drop = FALSE][, , , 1], Q)

    score <- 1
    if (has_narrative) {
      score <- score * bsvarsigns_weight_narrative(T_obs, sign_narrative, reduced_irf)
    }
    if (has_zero) {
      score <- score * bsvarsigns_weight_zero(Z, A_t, h_inv, Q)
    }
    scores[s] <- score
  }

  scores
}

compute_representative_draw <- function(draws, method = c("median_target", "most_likely_admissible"),
                                        center = c("median", "mean"), variables = NULL, shocks = NULL, horizons = NULL,
                                        metric = c("l2", "weighted_l2"), standardize = c("none", "sd"),
                                        object = NULL, object_type = c("irf", "cdm")) {
  method <- match.arg(method)
  center <- match.arg(center)
  metric <- match.arg(metric)
  standardize <- match.arg(standardize)
  object_type <- match.arg(object_type)

  subset <- subset_response_draws(draws, variables = variables, shocks = shocks, horizons = horizons)
  target <- selection_target(subset$draws, center = center)
  distances <- distance_to_target(subset$draws, target, metric = metric, standardize = standardize)

  if (identical(method, "median_target")) {
    scores <- -distances
    draw_index <- which.min(distances)
  } else {
    scores <- compute_posterior_kernel(object)
    top_score <- max(scores)
    candidates <- which(scores == top_score)
    if (length(candidates) > 1L) {
      draw_index <- candidates[which.min(distances[candidates])]
    } else {
      draw_index <- candidates
    }
  }

  representative_draw <- draws[, , , draw_index, drop = FALSE]
  dns <- resolve_array_dimnames(draws, list(
    paste0("variable", seq_len(dim(draws)[1])),
    paste0("shock", seq_len(dim(draws)[2])),
    as.character(seq_len(dim(draws)[3]) - 1L),
    as.character(seq_len(dim(draws)[4]))
  ))
  dimnames(representative_draw) <- list(dns[[1]], dns[[2]], dns[[3]], dns[[4]][draw_index])

  list(
    representative_draw = representative_draw,
    draw_index = draw_index,
    score = scores[draw_index],
    scores = scores,
    target_summary = as_tidy_response_array(subset$draws, object_type = object_type, probability = 0.68, draws = FALSE),
    selection_spec = list(
      variables = subset$labels$variable,
      shocks = subset$labels$shock,
      horizons = as.numeric(subset$labels$horizon),
      metric = metric,
      standardize = standardize,
      center = center,
      method = method
    )
  )
}

make_comparison_key <- function(variable, shock, horizon) {
  paste(variable, shock, horizon, sep = "\r")
}

selection_combinations <- function(labels) {
  expand.grid(
    variable = labels$variable,
    shock = labels$shock,
    horizon = as.numeric(labels$horizon),
    stringsAsFactors = FALSE
  )
}

evaluate_draw_predicate <- function(draws, variable, shock, horizon, relation = c("<", "<=", ">", ">=", "=="),
                                    value = 0, compare_to = NULL, absolute = FALSE) {
  relation <- match.arg(relation)
  dns <- resolve_array_dimnames(draws, list(
    paste0("variable", seq_len(dim(draws)[1])),
    paste0("shock", seq_len(dim(draws)[2])),
    as.character(seq_len(dim(draws)[3]) - 1L),
    as.character(seq_len(dim(draws)[4]))
  ))

  lhs_subset <- subset_response_draws(draws, variables = variable, shocks = shock, horizons = horizon)
  lhs_mat <- draw_matrix(lhs_subset$draws)

  if (!is.null(compare_to)) {
    rhs_subset <- subset_response_draws(
      draws,
      variables = compare_to$variable,
      shocks = compare_to$shock,
      horizons = compare_to$horizon
    )
    rhs_mat <- draw_matrix(rhs_subset$draws)

    if (nrow(rhs_mat) == 1L && nrow(lhs_mat) > 1L) {
      rhs_mat <- rhs_mat[rep(1L, nrow(lhs_mat)), , drop = FALSE]
      rhs_labels <- list(
        variable = rep(rhs_subset$labels$variable[1], nrow(lhs_mat)),
        shock = rep(rhs_subset$labels$shock[1], nrow(lhs_mat)),
        horizon = rep(rhs_subset$labels$horizon[1], nrow(lhs_mat))
      )
    } else if (nrow(rhs_mat) == nrow(lhs_mat)) {
      rhs_labels <- selection_combinations(rhs_subset$labels)
    } else {
      stop("`compare_to` must select either one response element or the same number of elements as the left-hand side.", call. = FALSE)
    }
    rhs_value <- rhs_mat
  } else {
    rhs_labels <- NULL
    rhs_value <- matrix(value, nrow = nrow(lhs_mat), ncol = ncol(lhs_mat))
  }

  lhs_eval <- if (absolute) abs(lhs_mat) else lhs_mat
  rhs_eval <- if (absolute) abs(rhs_value) else rhs_value
  gap <- lhs_eval - rhs_eval

  indicator <- switch(
    relation,
    "<" = gap < 0,
    "<=" = gap <= 0,
    ">" = gap > 0,
    ">=" = gap >= 0,
    "==" = gap == 0
  )

  list(
    gap = gap,
    indicator = indicator,
    labels = lhs_subset$labels,
    rhs_labels = rhs_labels
  )
}

summarise_gap_matrix <- function(gap, indicator, labels, object_type, relation, compare_to = NULL, model = "model1", draws = FALSE, probability = 0.68) {
  rows <- vector("list", nrow(gap))
  idx <- 1L

  combos <- selection_combinations(labels)

  for (i in seq_len(nrow(gap))) {
    if (draws) {
      rows[[idx]] <- tibble::tibble(
        model = model,
        object_type = object_type,
        variable = combos$variable[i],
        shock = combos$shock[i],
        horizon = combos$horizon[i],
        relation = relation,
        draw = seq_len(ncol(gap)),
        gap = as.numeric(gap[i, ]),
        satisfied = as.logical(indicator[i, ])
      )
    } else {
      stats <- summarise_vec(as.numeric(gap[i, ]), probability)
      rows[[idx]] <- tibble::tibble(
        model = model,
        object_type = object_type,
        variable = combos$variable[i],
        shock = combos$shock[i],
        horizon = combos$horizon[i],
        relation = relation,
        posterior_prob = mean(indicator[i, ]),
        mean_gap = stats[["mean"]],
        median_gap = stats[["median"]],
        lower_gap = stats[["lower"]],
        upper_gap = stats[["upper"]]
      )
    }
    idx <- idx + 1L
  }

  new_bsvar_post_tbl(do.call(rbind, rows), object_type = object_type, draws = draws)
}
