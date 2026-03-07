data(us_fiscal_lsuw)
set.seed(1)
spec_a <- specify_bsvar$new(us_fiscal_lsuw, p = 1)
spec_b <- specify_bsvar$new(us_fiscal_lsuw, p = 2)
post_a <- estimate(spec_a, S = 5, thin = 1, show_progress = FALSE)
post_b <- estimate(spec_b, S = 5, thin = 1, show_progress = FALSE)

restr <- list(
  irf_restriction(variable = 1, shock = 1, horizon = 0, sign = 1),
  structural_restriction(variable = 1, shock = 1, sign = 1)
)

cmp_bsvar <- compare_restrictions(base = post_a, alt = post_b, restrictions = restr)
expect_true(inherits(cmp_bsvar, "bsvar_post_tbl"))
expect_true(isTRUE(attr(cmp_bsvar, "compare")))
expect_equal(sort(unique(cmp_bsvar$model)), c("alt", "base"))
expect_equal(nrow(cmp_bsvar), 4)

data(optimism)
sign_irf <- matrix(c(0, 1, rep(NA, 23)), 5, 5)
set.seed(1)
spec_sign_a <- specify_bsvarSIGN$new(optimism * 100, p = 4, sign_irf = sign_irf)
spec_sign_b <- specify_bsvarSIGN$new(optimism * 100, p = 2, sign_irf = sign_irf)
post_sign_a <- estimate(spec_sign_a, S = 5, thin = 1, show_progress = FALSE)
post_sign_b <- estimate(spec_sign_b, S = 5, thin = 1, show_progress = FALSE)

cmp_sign <- compare_restrictions(a = post_sign_a, b = post_sign_b)
expect_true(inherits(cmp_sign, "bsvar_post_tbl"))
expect_true(all(c("restriction", "posterior_prob", "restriction_type") %in% names(cmp_sign)))
expect_equal(sort(unique(cmp_sign$model)), c("a", "b"))
expect_true(any(cmp_sign$restriction_type == "irf_zero"))
expect_true(any(cmp_sign$restriction_type == "irf_sign"))
