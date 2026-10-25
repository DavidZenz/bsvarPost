#' @importFrom utils globalVariables head
utils::globalVariables(c("restriction_type", "restriction_display"))

new_bsvar_post_tbl <- function(x, object_type, draws = FALSE, compare = FALSE) {
  required_cols <- c("model")
  missing_cols <- setdiff(required_cols, names(x))
  if (length(missing_cols) > 0L) {
    stop(
      "In new_bsvar_post_tbl(): missing required columns for object_type '", object_type, "'.\n",
      "Expected: model\n",
      "Missing: ", paste(missing_cols, collapse = ", "),
      call. = FALSE
    )
  }
  if (!is.character(object_type) || length(object_type) != 1L || is.na(object_type) || !nzchar(object_type)) {
    stop("`object_type` must be a single nonempty label.", call. = FALSE)
  }
  if (anyNA(x$model) || any(!nzchar(as.character(x$model)))) {
    stop("Posterior table model labels must be non-missing and nonempty.", call. = FALSE)
  }
  x$model <- as.character(x$model)
  x$object_type <- rep(object_type, nrow(x))
  validate_flag(draws, "draws")
  validate_flag(compare, "compare")
  defaults <- post_metadata_defaults(nrow(x))
  for (field in setdiff(names(defaults), names(x))) x[[field]] <- defaults[[field]]
  x$analysis_type <- rep(infer_analysis_type(x, object_type), nrow(x))
  if (identical(object_type, "fevd")) x$units <- rep("percent", nrow(x))
  if (all(x$analysis_type %in% c("duration", "half_life", "time_to_threshold"))) x$units <- rep("periods", nrow(x))
  if (draws && "draw" %in% names(x) && !"draw_id" %in% names(x)) x$draw_id <- as.character(x$draw)
  if (draws && "draw" %in% names(x)) x$n_draws <- as.integer(draw_counts(x))
  class(x) <- unique(c("bsvar_post_tbl", class(x)))
  attr(x, "object_type") <- object_type
  attr(x, "draws") <- draws
  attr(x, "compare") <- compare
  x
}

validate_nonnegative_horizon <- function(horizon, caller) {
  if (!is.numeric(horizon) || length(horizon) != 1L || is.na(horizon) ||
      !is.finite(horizon) || horizon < 0 || horizon > .Machine$integer.max || horizon != floor(horizon)) {
    stop(sprintf("`%s` requires `horizon` to be a single non-negative integer.", caller), call. = FALSE)
  }
  as.integer(horizon)
}

validate_positive_count <- function(value, caller, arg = deparse(substitute(value))) {
  if (!is.numeric(value) || length(value) != 1L || is.na(value) ||
      !is.finite(value) || value < 1 || value > .Machine$integer.max || value != floor(value)) {
    stop(sprintf("`%s` requires `%s` to be a single positive integer.", caller, arg), call. = FALSE)
  }
  as.integer(value)
}

summary_probs <- function(probability) {
  validate_probability(probability)
  alpha <- (1 - probability) / 2
  c(alpha, 1 - alpha)
}

ensure_model_names <- function(models) {
  nms <- names(models)
  if (is.null(nms)) {
    nms <- rep("", length(models))
  }
  if (anyNA(nms)) {
    stop("Model names must not be missing.", call. = FALSE)
  }
  missing <- nms == ""
  if (anyDuplicated(nms[!missing])) {
    stop("Explicit model names must be unique.", call. = FALSE)
  }
  used <- nms[!missing]
  for (i in which(missing)) {
    suffix <- i
    candidate <- paste0("model", suffix)
    while (candidate %in% used) {
      suffix <- suffix + 1L
      candidate <- paste0("model", suffix)
    }
    nms[i] <- candidate
    used <- c(used, candidate)
  }
  names(models) <- nms
  models
}

# Group tuples directly, rather than concatenating their labels. Factor levels
# preserve first appearance, including for more than nine groups.
tuple_group <- function(..., drop = TRUE) {
  columns <- list(...)
  frame <- if (length(columns) == 1L && is.data.frame(columns[[1]])) {
    columns[[1]]
  } else {
    as.data.frame(columns, optional = TRUE, stringsAsFactors = FALSE)
  }
  ids <- vctrs::vec_group_id(frame)
  factor(ids, levels = seq_len(attr(ids, "n")))
}

collect_models <- function(...) {
  dots <- list(...)
  if (!length(dots)) {
    stop("At least one model object must be supplied.", call. = FALSE)
  }
  if (length(dots) == 1 && is.list(dots[[1]]) && !inherits(dots[[1]], c("PosteriorIR", "PosteriorFEVD", "PosteriorShocks", "PosteriorHD", "Forecasts", "PosteriorCDM"))) {
    models <- dots[[1]]
  } else {
    models <- dots
  }
  if (!length(models) || any(vapply(models, is.null, logical(1)))) {
    stop("Model inputs must be non-NULL posterior objects.", call. = FALSE)
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
  if (!is.array(x) || length(dim(x)) != 4L) {
    stop(
      "In set_response_dimnames(): expected a 4-dimensional array.\n",
      "Received: ", if (is.array(x)) paste0(length(dim(x)), " dimensions") else paste0("class ", paste(class(x), collapse = ", ")),
      call. = FALSE
    )
  }
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
  mark_posterior_source(x, model)
}

set_time_dimnames <- function(x, model = NULL) {
  if (!is.array(x) || length(dim(x)) != 3L) {
    stop(
      "In set_time_dimnames(): expected a 3-dimensional array.\n",
      "Received: ", if (is.array(x)) paste0(length(dim(x)), " dimensions") else paste0("class ", paste(class(x), collapse = ", ")),
      call. = FALSE
    )
  }
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
  mark_posterior_source(x, model)
}

set_hd_dimnames <- function(x, model = NULL) {
  if (!is.array(x) || length(dim(x)) != 4L) {
    stop(
      "In set_hd_dimnames(): expected a 4-dimensional array.\n",
      "Received: ", if (is.array(x)) paste0(length(dim(x)), " dimensions") else paste0("class ", paste(class(x), collapse = ", ")),
      call. = FALSE
    )
  }
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
  mark_posterior_source(x, model)
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
    for (shock in seq_len(dim(cdm_draws)[2])) {
      cdm_draws[, shock, , ] <- cdm_draws[, shock, , ] / scale_factors[shock]
    }
  }
  list(draws = cdm_draws, scale_factors = scale_factors)
}

resolve_scale_factors <- function(model, n_shocks, scale_var = NULL) {
  y_matrix <- model$last_draw$data_matrices$Y
  sample_sds <- apply(y_matrix, 1, stats::sd, na.rm = TRUE)

  if (is.null(scale_var)) {
    if (length(sample_sds) < n_shocks) {
      stop("Cannot resolve one scaling variable for every shock.", call. = FALSE)
    }
    indices <- seq_len(n_shocks)
  } else {
    if (length(scale_var) != 1L && length(scale_var) != n_shocks) {
      stop("'scale_var' must have length 1 or one entry per shock.", call. = FALSE)
    }

    if (is.character(scale_var)) {
      indices <- match(scale_var, names(sample_sds))
      if (anyNA(indices)) {
        stop("Unknown 'scale_var' label(s): ", paste(scale_var[is.na(indices)], collapse = ", "), call. = FALSE)
      }
    } else if (is.numeric(scale_var)) {
      if (anyNA(scale_var) || any(!is.finite(scale_var)) ||
          any(scale_var != floor(scale_var)) || any(scale_var < 1) ||
          any(scale_var > length(sample_sds))) {
        stop("Numeric 'scale_var' values must be finite, whole-number indices within the model variables.", call. = FALSE)
      }
      indices <- as.integer(scale_var)
    } else {
      stop("'scale_var' must be NULL, character, or numeric.", call. = FALSE)
    }

    if (length(indices) == 1L) {
      indices <- rep(indices, n_shocks)
    }
  }

  scale_factors <- unname(sample_sds[indices])
  if (length(scale_factors) != n_shocks || anyNA(scale_factors) ||
      any(!is.finite(scale_factors)) || any(scale_factors <= 0)) {
    stop("Resolved shock standard deviations must be finite and strictly positive for every shock.", call. = FALSE)
  }
  scale_factors
}

as_tidy_response_array <- function(x, object_type, model = "model1", probability = 0.90, draws = FALSE) {
  validate_draw_array(x, 4L, "tidy response")
  validate_probability(probability)
  validate_flag(draws, "draws")
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
            draw_id = as.character(dns[[4]]),
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
  with_post_provenance(new_bsvar_post_tbl(do.call(rbind, rows), object_type = object_type, draws = draws), source = x, probability = probability, n_draws = d[4])
}

as_tidy_time_array <- function(x, object_type, model = "model1", probability = 0.90, draws = FALSE, time_name = "time") {
  validate_draw_array(x, 3L, "tidy time series")
  validate_probability(probability)
  validate_flag(draws, "draws")
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
            draw_id = as.character(dns[[3]]),
          value = as.numeric(values)
        )
        row[[time_name]] <- dns[[2]][t]
        rows[[idx]] <- row[, c("model", "object_type", "variable", time_name, "draw", "draw_id", "value")]
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
  out <- do.call(rbind, rows)
  if (identical(time_name, "horizon")) {
    labels <- as.character(out$horizon)
    suppressWarnings(numeric_horizon <- as.numeric(labels))
    if (all(is.finite(numeric_horizon))) {
      out$horizon <- numeric_horizon
    } else {
      out$horizon_label <- labels
      out$horizon <- match(labels, dns[[2]])
    }
  }
  with_post_provenance(new_bsvar_post_tbl(out, object_type = object_type, draws = draws), source = x, probability = probability, n_draws = d[3])
}

as_tidy_hd_array <- function(x, model = "model1", probability = 0.90, draws = FALSE) {
  validate_draw_array(x, 4L, "tidy historical decomposition")
  validate_probability(probability)
  validate_flag(draws, "draws")
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
            draw_id = as.character(dns[[4]]),
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
  with_post_provenance(new_bsvar_post_tbl(do.call(rbind, rows), object_type = "hd", draws = draws), source = x, probability = probability, n_draws = d[4])
}

set_compare_flag <- function(x) {
  attr(x, "compare") <- TRUE
  x
}
