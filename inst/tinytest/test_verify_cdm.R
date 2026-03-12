Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")

strip_attrs <- function(x) {
  attributes(x) <- NULL
  x
}

# --- PosteriorBSVAR fixture ---
data(us_fiscal_lsuw, package = "bsvars")
set.seed(2026)
spec_b <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
post_b <- bsvars::estimate(spec_b, S = 30, thin = 1, show_progress = FALSE)
irf_b  <- bsvars::compute_impulse_responses(post_b, horizon = 8)

# Test 1 -- CDM cumulative sums match manual horizon-by-horizon accumulation (PosteriorBSVAR)
cdm_manual <- irf_b
for (h in 2:dim(irf_b)[3]) {
  cdm_manual[, , h, ] <- cdm_manual[, , h - 1, ] + irf_b[, , h, ]
}
cdm_result <- cdm(post_b, horizon = 8)
expect_equal(strip_attrs(cdm_result), strip_attrs(cdm_manual), tolerance = 1e-10)

# Test 2 -- CDM with shock_sd scaling (PosteriorBSVAR)
ysd <- apply(post_b$last_draw$data_matrices$Y, 1, sd, na.rm = TRUE)
cdm_manual_scaled <- cdm_manual
for (j in seq_len(dim(cdm_manual)[2])) {
  cdm_manual_scaled[, j, , ] <- cdm_manual[, j, , ] / ysd[j]
}
cdm_scaled <- cdm(post_b, horizon = 8, scale_by = "shock_sd")
expect_equal(strip_attrs(cdm_scaled), strip_attrs(cdm_manual_scaled), tolerance = 1e-10)

# --- PosteriorBSVARSIGN fixture ---
data(optimism, package = "bsvarSIGNs")
set.seed(2026)
sign_irf <- matrix(c(1, rep(NA, 3)), 2, 2)
spec_s   <- suppressMessages(
  bsvarSIGNs::specify_bsvarSIGN$new(optimism[, 1:2], p = 1, sign_irf = sign_irf)
)
post_s <- bsvars::estimate(spec_s, S = 30, thin = 1, show_progress = FALSE)

# Test 3 -- CDM cumulative sums (PosteriorBSVARSIGN)
irf_s <- bsvars::compute_impulse_responses(post_s, horizon = 8)
cdm_manual_s <- irf_s
for (h in 2:dim(irf_s)[3]) {
  cdm_manual_s[, , h, ] <- cdm_manual_s[, , h - 1, ] + irf_s[, , h, ]
}
expect_equal(strip_attrs(cdm(post_s, horizon = 8)), strip_attrs(cdm_manual_s), tolerance = 1e-10)

# Test 4 -- CDM dimensions and horizon-0 identity
expect_equal(dim(cdm_result), dim(irf_b))
expect_equal(strip_attrs(cdm_result[, , 1, ]), strip_attrs(irf_b[, , 1, ]), tolerance = 1e-10)
