expect_true(exists("as_tsibble_post", mode = "function"))

mock_tbl <- bsvarPost:::new_bsvar_post_tbl(
  tibble::tibble(
    model = c("m1", "m1"),
    object_type = c("forecast", "forecast"),
    variable = c("y", "y"),
    horizon = c(1, 2),
    mean = c(0.1, 0.2),
    median = c(0.1, 0.2),
    sd = c(0.01, 0.01),
    lower = c(0.05, 0.15),
    upper = c(0.15, 0.25)
  ),
  object_type = "forecast",
  draws = FALSE
)

expect_error(
  as_tsibble_post(mock_tbl),
  pattern = "tsibble",
  info = "as_tsibble_post: fails cleanly when tsibble is not installed."
)
