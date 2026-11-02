Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")

data(us_fiscal_lsuw, package = "bsvars")
set.seed(1)
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
post <- bsvars::estimate(spec, S = 2, thin = 1, show_progress = FALSE)

apr_tbl <- as_apr_cond_forc(post, horizon = 2, origin = as.Date("2024-01-01"), frequency = "quarter")
expect_true(all(c("hor", "variable", "lower", "center", "upper") %in% names(apr_tbl)))
expect_true(inherits(apr_tbl$hor, "Date"))

back_tbl <- tidy_apr_forecast(apr_tbl, model = "apr")
expect_equal(attr(back_tbl, "object_type"), "forecast")
expect_true(all(c("model", "variable", "time", "median", "lower", "upper") %in% names(back_tbl)))
expect_equal(nrow(back_tbl), nrow(apr_tbl))

# Calendar policy: each requested offset is anchored to the original date.
forecast <- structure(list(forecasts = array(1:6, c(1, 2, 3))), class = "Forecasts")
forecast_tbl <- tidy_forecast(forecast)
expect_equal(as_apr_cond_forc(forecast, origin = as.Date("2024-03-31"))$hor,
  as.Date(c("2024-06-30", "2024-09-30")))
date_cases <- list(
  list("2024-01-31", "month", c("2024-02-29", "2024-03-31")),
  list("2023-01-31", "month", c("2023-02-28", "2023-03-31")),
  list("2024-01-30", "month", c("2024-02-29", "2024-03-30")),
  list("2024-02-29", "year", c("2025-02-28", "2026-02-28")),
  list("2023-12-31", "quarter", c("2024-03-31", "2024-06-30")),
  list("2024-01-15", "quarter", c("2024-04-15", "2024-07-15")),
  list("2024-02-28", "day", c("2024-02-29", "2024-03-01")))
for (case in date_cases) {
  expect_equal(as_apr_cond_forc(forecast_tbl, origin = as.Date(case[[1]]), frequency = case[[2]])$hor,
    as.Date(case[[3]]))
}
offsets <- forecast_tbl[c(2, 1), ]
offsets$horizon <- c(2, 0)
expect_equal(as_apr_cond_forc(offsets, origin = as.Date("2024-03-31"))$hor,
  as.Date(c("2024-09-30", "2024-03-31")), info = "Conversion preserves row order and horizon zero.")
expect_equal(as_apr_cond_forc(back_tbl)$hor, apr_tbl$hor)

# Summary-format output must retain a unique model/variable/horizon identity.
irf <- array(1:12, c(1, 2, 2, 3),
  dimnames = list("gdp", c("gs", "ttr"), c("0", "1"), as.character(1:3)))
class(irf) <- c("PosteriorIR", "array")
expect_error(as_apr_cond_forc(tidy_irf(irf)), "forecast-type",
  info = "A two-shock IRF is not a forecast, even when its summary columns overlap.")
expect_error(as_apr_cond_forc(tidy_forecast(forecast, draws = TRUE)), "summarise forecasts first")
expect_error(as_apr_cond_forc(rbind(forecast_tbl, forecast_tbl[1, ])), "unique model-variable-horizon")
bad <- forecast_tbl
bad$shock <- "s"
expect_error(as_apr_cond_forc(bad), "shock identifiers")
bad <- forecast_tbl
bad$lower <- as.character(bad$lower)
expect_error(as_apr_cond_forc(bad), "finite and numeric")
bad <- forecast_tbl
bad$lower <- matrix(1:4, nrow = 2)
expect_error(as_apr_cond_forc(bad), "one-dimensional columns")
bad <- forecast_tbl
bad$median[1] <- Inf
expect_error(as_apr_cond_forc(bad), "finite and numeric")
bad <- forecast_tbl
bad$lower[1] <- bad$upper[1] + 1
expect_error(as_apr_cond_forc(bad), "lower bounds")
bad <- forecast_tbl
bad$variable[1] <- NA_character_
expect_error(as_apr_cond_forc(bad), "labels")
bad <- forecast_tbl
bad$horizon <- c(1, 1.5)
expect_error(as_apr_cond_forc(bad), "integer offsets")
bad$horizon <- c("1", "01")
expect_error(as_apr_cond_forc(bad, origin = as.Date("2024-01-01")), "unique model-variable-horizon",
  info = "Calendar conversion must not collapse distinct input labels into duplicate keys.")
# A skewed forecast's mean can legitimately lie outside its central interval.
forecast_tbl$mean <- forecast_tbl$upper + 1
expect_equal(as_apr_cond_forc(forecast_tbl, center = "mean")$center, forecast_tbl$mean)
comparison <- rbind(transform(forecast_tbl, model = "base"), transform(forecast_tbl, model = "alt"))
comparison <- bsvarPost:::new_bsvar_post_tbl(comparison, "forecast")
apr_comparison <- as_apr_cond_forc(comparison)
expect_equal(unique(apr_comparison$model), c("base", "alt"))
expect_equal(nrow(apr_comparison), 4L)

expect_error(
  as_apr_cond_forc(data.frame(variable = "y", lower = 0, upper = 1)),
  pattern = "no applicable method|forecast summary columns",
  info = "as_apr_cond_forc: malformed tidy input is rejected."
)

if (requireNamespace("APRScenario", quietly = TRUE)) {
  matrices <- apr_gen_mats(posterior = post, specification = spec, max_cores = 1)
  expect_true(all(c("M", "M_inv", "B", "B_list", "Y", "X", "Z") %in% names(matrices)))
  expect_equal(dim(matrices$M_inv), dim(post$posterior$B))
  expect_error(
    apr_gen_mats(max_cores = 0),
    pattern = "positive integer|positive",
    info = "apr_gen_mats: invalid max_cores is rejected before calling APRScenario."
  )
  expect_error(
    apr_gen_mats(max_cores = Inf),
    pattern = "positive integer",
    info = "apr_gen_mats: infinite max_cores is rejected before integer coercion."
  )
} else {
  expect_error(
    apr_gen_mats(max_cores = 0),
    pattern = "APRScenario",
    info = "apr_gen_mats: missing optional dependency is reported clearly."
  )

  expect_error(
    apr_gen_mats(),
    pattern = "APRScenario",
    info = "apr_gen_mats: missing optional dependency is reported clearly."
  )
}
