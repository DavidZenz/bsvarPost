#' @importFrom utils globalVariables head
utils::globalVariables(c("restriction_type", "restriction_display"))

new_bsvar_post_tbl <- function(x, object_type, draws = FALSE, compare = FALSE) {
  class(x) <- c("bsvar_post_tbl", class(x))
  attr(x, "object_type") <- object_type
  attr(x, "draws") <- draws
  attr(x, "compare") <- compare
  x
}

summary_probs <- function(probability) {
  alpha <- (1 - probability) / 2
  c(alpha, 1 - alpha)
}

ensure_model_names <- function(models) {
  nms <- names(models)
  if (is.null(nms)) {
    nms <- rep("", length(models))
  }
  missing <- nms == ""
  nms[missing] <- paste0("model", seq_along(models))[missing]
  names(models) <- nms
  models
}

collect_models <- function(...) {
  dots <- list(...)
  if (length(dots) == 1 && is.list(dots[[1]]) && !inherits(dots[[1]], c("PosteriorIR", "PosteriorFEVD", "PosteriorShocks", "PosteriorHD", "Forecasts", "PosteriorCDM"))) {
    models <- dots[[1]]
  } else {
    models <- dots
  }
  ensure_model_names(models)
}

resolve_array_dimnames <- function(x, defaults) {
  dns <- dimnames(x)
  if (is.null(dns)) dns <- vector("list", length(dim(x)))
  for (i in seq_along(defaults)) {
    if (is.null(dns[[i]])) dns[[i]] <- defaults[[i]]
  }
  dns
}

infer_model_variable_names <- function(model, n = NULL) {
  y_matrix <- tryCatch(model$last_draw$data_matrices$Y, error = function(e) NULL)
  if (is.null(y_matrix)) {
    return(NULL)
  }

  candidates <- rownames(y_matrix)
  if (is.null(candidates) || anyNA(candidates) || any(candidates == "")) {
    candidates <- colnames(y_matrix)
  }
  if (is.null(candidates) || anyNA(candidates) || any(candidates == "")) {
    return(NULL)
  }

  if (!is.null(n)) {
    candidates <- candidates[seq_len(min(length(candidates), n))]
  }
  unname(candidates)
}

set_response_dimnames <- function(x, model = NULL) {
  d <- dim(x)
  var_names <- infer_model_variable_names(model, n = d[1])
  if (is.null(var_names) || length(var_names) != d[1]) {
    var_names <- paste0("variable", seq_len(d[1]))
  }

  shock_names <- var_names[seq_len(min(length(var_names), d[2]))]
  if (length(shock_names) != d[2]) {
    shock_names <- paste0("shock", seq_len(d[2]))
  }

  dimnames(x) <- resolve_array_dimnames(x, list(
    var_names,
    shock_names,
    as.character(seq_len(d[3]) - 1L),
    as.character(seq_len(d[4]))
  ))
  x
}

set_time_dimnames <- function(x, model = NULL) {
  d <- dim(x)
  var_names <- infer_model_variable_names(model, n = d[1])
  if (is.null(var_names) || length(var_names) != d[1]) {
    var_names <- paste0("variable", seq_len(d[1]))
  }

  dimnames(x) <- resolve_array_dimnames(x, list(
    var_names,
    as.character(seq_len(d[2])),
    as.character(seq_len(d[3]))
  ))
  x
}

set_hd_dimnames <- function(x, model = NULL) {
  d <- dim(x)
  var_names <- infer_model_variable_names(model, n = d[1])
  if (is.null(var_names) || length(var_names) != d[1]) {
    var_names <- paste0("variable", seq_len(d[1]))
  }

  shock_names <- var_names[seq_len(min(length(var_names), d[2]))]
  if (length(shock_names) != d[2]) {
    shock_names <- paste0("shock", seq_len(d[2]))
  }

  dimnames(x) <- resolve_array_dimnames(x, list(
    var_names,
    shock_names,
    as.character(seq_len(d[3])),
    as.character(seq_len(d[4]))
  ))
  x
}

summarise_vec <- function(x, probability) {
  probs <- summary_probs(probability)
  c(
    mean = mean(x),
    median = stats::median(x),
    sd = stats::sd(x),
    lower = stats::quantile(x, probs = probs[1], names = FALSE),
    upper = stats::quantile(x, probs = probs[2], names = FALSE)
  )
}

compute_cdm_draws <- function(irf, scale_by = c("none", "shock_sd"), scale_var = NULL, model = NULL) {
  scale_by <- match.arg(scale_by)
  cdm_draws <- set_response_dimnames(irf, model = model)
  if (dim(cdm_draws)[3] > 1L) {
    for (h in 2:dim(cdm_draws)[3]) {
      cdm_draws[, , h, ] <- cdm_draws[, , h - 1L, ] + irf[, , h, ]
    }
  }
  scale_factors <- rep(1, dim(cdm_draws)[2])
  if (identical(scale_by, "shock_sd")) {
    scale_factors <- resolve_scale_factors(model, dim(cdm_draws)[2], scale_var)
    for (shock in seq_along(scale_factors)) {
      cdm_draws[, shock, , ] <- cdm_draws[, shock, , ] / scale_factors[shock]
    }
  }
  list(draws = cdm_draws, scale_factors = scale_factors)
}

resolve_scale_factors <- function(model, n_shocks, scale_var = NULL) {
  y_matrix <- model$last_draw$data_matrices$Y
  sample_sds <- apply(y_matrix, 1, stats::sd, na.rm = TRUE)

  if (is.null(scale_var)) {
    return(unname(sample_sds[seq_len(n_shocks)]))
  }

  if (is.character(scale_var)) {
    if (length(scale_var) == 1L) return(rep(unname(sample_sds[[scale_var]]), n_shocks))
    return(unname(sample_sds[scale_var]))
  }

  if (is.numeric(scale_var)) {
    if (length(scale_var) == 1L) return(rep(unname(sample_sds[[scale_var]]), n_shocks))
    return(unname(sample_sds[scale_var]))
  }

  stop("'scale_var' must be NULL, character, or numeric.", call. = FALSE)
}

as_tidy_response_array <- function(x, object_type, model = "model1", probability = 0.68, draws = FALSE) {
  d <- dim(x)
  dns <- resolve_array_dimnames(x, list(
    paste0("variable", seq_len(d[1])),
    paste0("shock", seq_len(d[2])),
    as.character(seq_len(d[3]) - 1L),
    as.character(seq_len(d[4]))
  ))

  rows <- vector("list", d[1] * d[2] * d[3])
  idx <- 1L
  for (i in seq_len(d[1])) {
    for (j in seq_len(d[2])) {
      for (h in seq_len(d[3])) {
        values <- x[i, j, h, ]
        if (draws) {
          rows[[idx]] <- tibble::tibble(
            model = model,
            object_type = object_type,
            variable = dns[[1]][i],
            shock = dns[[2]][j],
            horizon = as.numeric(dns[[3]][h]),
            draw = seq_along(values),
            value = as.numeric(values)
          )
        } else {
          stats <- summarise_vec(as.numeric(values), probability)
          rows[[idx]] <- tibble::tibble(
            model = model,
            object_type = object_type,
            variable = dns[[1]][i],
            shock = dns[[2]][j],
            horizon = as.numeric(dns[[3]][h]),
            mean = stats[["mean"]],
            median = stats[["median"]],
            sd = stats[["sd"]],
            lower = stats[["lower"]],
            upper = stats[["upper"]]
          )
        }
        idx <- idx + 1L
      }
    }
  }
  new_bsvar_post_tbl(do.call(rbind, rows), object_type = object_type, draws = draws)
}

as_tidy_time_array <- function(x, object_type, model = "model1", probability = 0.68, draws = FALSE, time_name = "time") {
  d <- dim(x)
  dns <- resolve_array_dimnames(x, list(
    paste0("variable", seq_len(d[1])),
    as.character(seq_len(d[2])),
    as.character(seq_len(d[3]))
  ))
  rows <- vector("list", d[1] * d[2])
  idx <- 1L
  for (i in seq_len(d[1])) {
    for (t in seq_len(d[2])) {
      values <- x[i, t, ]
      if (draws) {
        row <- tibble::tibble(
          model = model,
          object_type = object_type,
          variable = dns[[1]][i],
          draw = seq_along(values),
          value = as.numeric(values)
        )
        row[[time_name]] <- dns[[2]][t]
        rows[[idx]] <- row[, c("model", "object_type", "variable", time_name, "draw", "value")]
      } else {
        stats <- summarise_vec(as.numeric(values), probability)
        row <- tibble::tibble(
          model = model,
          object_type = object_type,
          variable = dns[[1]][i],
          mean = stats[["mean"]],
          median = stats[["median"]],
          sd = stats[["sd"]],
          lower = stats[["lower"]],
          upper = stats[["upper"]]
        )
        row[[time_name]] <- dns[[2]][t]
        rows[[idx]] <- row[, c("model", "object_type", "variable", time_name, "mean", "median", "sd", "lower", "upper")]
      }
      idx <- idx + 1L
    }
  }
  new_bsvar_post_tbl(do.call(rbind, rows), object_type = object_type, draws = draws)
}

as_tidy_hd_array <- function(x, model = "model1", probability = 0.68, draws = FALSE) {
  d <- dim(x)
  dns <- resolve_array_dimnames(x, list(
    paste0("variable", seq_len(d[1])),
    paste0("shock", seq_len(d[2])),
    as.character(seq_len(d[3])),
    as.character(seq_len(d[4]))
  ))
  rows <- vector("list", d[1] * d[2] * d[3])
  idx <- 1L
  for (i in seq_len(d[1])) {
    for (j in seq_len(d[2])) {
      for (t in seq_len(d[3])) {
        values <- x[i, j, t, ]
        if (draws) {
          rows[[idx]] <- tibble::tibble(
            model = model,
            object_type = "hd",
            variable = dns[[1]][i],
            shock = dns[[2]][j],
            time = dns[[3]][t],
            draw = seq_along(values),
            value = as.numeric(values)
          )
        } else {
          stats <- summarise_vec(as.numeric(values), probability)
          rows[[idx]] <- tibble::tibble(
            model = model,
            object_type = "hd",
            variable = dns[[1]][i],
            shock = dns[[2]][j],
            time = dns[[3]][t],
            mean = stats[["mean"]],
            median = stats[["median"]],
            sd = stats[["sd"]],
            lower = stats[["lower"]],
            upper = stats[["upper"]]
          )
        }
        idx <- idx + 1L
      }
    }
  }
  new_bsvar_post_tbl(do.call(rbind, rows), object_type = "hd", draws = draws)
}

set_compare_flag <- function(x) {
  attr(x, "compare") <- TRUE
  x
}
