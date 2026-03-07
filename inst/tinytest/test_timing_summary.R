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

data(us_fiscal_lsuw, package = "bsvars")
set.seed(202)
model_post <- bsvars::estimate(bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1), S = 8, thin = 1, show_progress = FALSE)

model_half <- half_life_response(model_post, type = "irf", horizon = 4, variable = 1, shock = 1)
expect_true(all(c("mean_half_life", "median_half_life", "reached_prob") %in% names(model_half)))

model_time <- time_to_threshold(model_post, type = "cdm", horizon = 4, variable = 1, shock = 1, relation = ">", value = 0)
expect_true(all(c("mean_horizon", "median_horizon", "reached_prob") %in% names(model_time)))
