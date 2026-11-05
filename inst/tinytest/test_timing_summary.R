make_test_irf <- function() {
  arr <- array(0, dim = c(1, 1, 5, 3), dimnames = list("y", "shock", as.character(0:4), as.character(1:3)))
  arr[1, 1, , 1] <- c(4.0, 2.0, 1.0, 0.4, 0.1)
  arr[1, 1, , 2] <- c(3.0, 1.4, 0.7, 0.2, 0.1)
  arr[1, 1, , 3] <- c(2.0, 1.5, 1.1, 0.9, 0.6)
  class(arr) <- c("PosteriorIR", class(arr))
  arr
}

irf_obj <- make_test_irf()

half_tbl <- half_life_response(irf_obj, variable = "y", shock = "shock", baseline = "peak")
expect_equal(half_tbl$mean_half_life[[1]], 5 / 3)
expect_equal(half_tbl$median_half_life[[1]], 1)
expect_equal(half_tbl$reached_prob[[1]], 1)

time_tbl <- time_to_threshold(irf_obj, variable = "y", shock = "shock", relation = "<=", value = 0.5)
expect_equal(time_tbl$mean_horizon[[1]], 3)
expect_equal(time_tbl$median_horizon[[1]], 3)
expect_equal(time_tbl$reached_prob[[1]], 2 / 3)

permuted <- irf_obj[, , c(1, 4, 3, 5, 2), , drop = FALSE]
class(permuted) <- class(irf_obj)
expect_equal(half_life_response(permuted)$median_half_life, half_tbl$median_half_life)
expect_equal(time_to_threshold(permuted, relation = "<=", value = .5)$median_horizon, time_tbl$median_horizon)
regression <- array(rep(c(1, 1, 4), 3), c(1, 1, 3, 3),
  dimnames = list("y", "s", c("0", "2", "1"), as.character(1:3)))
regression[1, 1, , ] <- rep(c(1, 4, 1), 3)
class(regression) <- c("PosteriorIR", "array")
expect_true(is.na(half_life_response(regression)$median_half_life))
expect_equal(half_life_response(regression)$reached_prob, 0)
regression[1, 1, , ] <- rep(c(-1, 2, 1), 3)
expect_equal(time_to_threshold(regression)$median_horizon, 1)
for (labels in list(c("0", "1", "01"), c("0", "1.5", "2"), c("0", "-1", "2"), c("0", "bad", "2"))) {
  bad <- regression; dimnames(bad)[[3]] <- labels
  expect_error(half_life_response(bad), "unique, finite, non-negative integer horizon labels")
}
dimnames(regression)[[3]] <- c("0", "2", "5")
regression[1, 1, , ] <- rep(c(4, 3, 1), 3)
expect_equal(half_life_response(regression, baseline = "initial")$median_half_life, 5)
leading_zero <- regression; dimnames(leading_zero)[[3]] <- c("00", "02", "05")
expect_equal(half_life_response(leading_zero, baseline = "initial")$median_half_life, 5)
expect_equal(time_to_threshold(regression, relation = "<=", value = 1)$median_horizon, 5)
expect_equal(duration_response(regression, relation = ">", value = 2)$median_duration, 2)
no_zero <- regression; dimnames(no_zero)[[3]] <- c("1", "2", "5")
expect_error(half_life_response(no_zero, baseline = "initial"), "requires horizon zero")
regression[1, 1, , ] <- rep(c(-4, -2, 0), 3)
expect_equal(half_life_response(regression, absolute = FALSE)$reached_prob, 0)
expect_equal(time_to_threshold(regression)$reached_prob, 0)
regression[1, 1, , ] <- rep(c(4, -1, -2), 3)
expect_equal(half_life_response(regression, absolute = FALSE)$median_half_life, 2)

data(us_fiscal_lsuw, package = "bsvars")
set.seed(202)
model_post <- bsvars::estimate(bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1), S = 8, thin = 1, show_progress = FALSE)

model_half <- half_life_response(model_post, type = "irf", horizon = 4, variable = 1, shock = 1)
expect_true(all(c("mean_half_life", "median_half_life", "reached_prob") %in% names(model_half)))

model_time <- time_to_threshold(model_post, type = "cdm", horizon = 4, variable = 1, shock = 1, relation = ">", value = 0)
expect_true(all(c("mean_horizon", "median_horizon", "reached_prob") %in% names(model_time)))
