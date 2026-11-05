data(us_fiscal_lsuw)
set.seed(1)
spec_bsvar <- specify_bsvar$new(us_fiscal_lsuw, p = 1)
post_bsvar <- estimate(spec_bsvar, S = 5, thin = 1, show_progress = FALSE)

hd_draws <- tidy_hd(post_bsvar, draws = TRUE)
time_window <- unique(as.character(hd_draws$time))[1:2]
event_draws <- tidy_hd_event(hd_draws, start = time_window[1], end = time_window[2], draws = TRUE)
expect_true(inherits(event_draws, "bsvar_post_tbl"))
expect_true(isTRUE(attr(event_draws, "draws")))

variable_1 <- unique(hd_draws$variable)[1]
shock_1 <- unique(hd_draws$shock)[1]
manual <- subset(hd_draws, variable == variable_1 & shock == shock_1 & time %in% time_window)
manual_sum <- tapply(manual$value, manual$draw, sum)
check_row <- subset(event_draws, variable == variable_1 & shock == shock_1)
expect_equal(unname(check_row$value), unname(as.numeric(manual_sum)))

event_summary <- tidy_hd_event(post_bsvar, start = time_window[1], end = time_window[2])
expect_true(inherits(event_summary, "bsvar_post_tbl"))
expect_true(all(c("event_start", "event_end", "median") %in% names(event_summary)))

ranked_abs <- shock_ranking(post_bsvar, start = time_window[1], end = time_window[2], ranking = "absolute")
expect_true(inherits(ranked_abs, "bsvar_post_tbl"))
expect_true(all(c("rank", "rank_score", "ranking") %in% names(ranked_abs)))

var_block <- subset(ranked_abs, model == ranked_abs$model[1] & variable == ranked_abs$variable[1])
expect_equal(var_block$rank, seq_len(nrow(var_block)))
expect_true(all(diff(var_block$rank_score) <= 0))

ranked_signed <- shock_ranking(post_bsvar, start = time_window[1], end = time_window[2], ranking = "signed")
expect_true(all(ranked_signed$ranking == "signed"))

# Time order and completeness are numerical contracts, independent of a fit.
bounded <- array(1, c(1, 1, 4, 3),
  dimnames = list("y", "s", as.character(1:4), as.character(1:3)))
class(bounded) <- c("PosteriorHD", "array")
complete <- tidy_hd(bounded, draws = TRUE)
shuffled <- complete[order(match(complete$time, c("1", "3", "2", "4"))), ]
expect_equal(tidy_hd_event(shuffled, "1", "3", draws = TRUE)$value, rep(3, 3),
  info = "Shuffling period rows cannot change an inclusive event total.")
expect_equal(tidy_hd_event(bounded[, , c(1, 3, 2, 4), , drop = FALSE] |>
  structure(class = c("PosteriorHD", "array")), "1", "3", draws = TRUE)$value, rep(3, 3))
expect_error(tidy_hd_event(shuffled, "3", "1"), "start must not follow")

incomplete <- complete[!(complete$time == "2" & complete$draw == 1), ]
expect_error(tidy_hd_event(incomplete, "1", "2"), "Incomplete HD event window.*draw 1.*2",
  info = "Missing cells must not silently produce partial totals 1, 2, 2.")
expect_error(plot_hd_event_cumulative(incomplete, "1", "2"), "Incomplete HD event window")
expect_error(tidy_hd_event(rbind(complete, complete[1, ]), "1", "3"), "unique.*duplicate")
other <- complete
other$shock <- "other"
expect_error(tidy_hd_event(rbind(complete, other[other$draw != 3, ]), "1", "3"), "Incomplete HD draw coverage")
zero <- complete
zero$value[zero$time == "2" & zero$draw == 1] <- 0
expect_equal(tidy_hd_event(zero, "1", "2", draws = TRUE)$value, c(1, 2, 2),
  info = "A stored zero remains a contribution, unlike a missing observation.")

for (axis in list(as.Date("2024-01-01") + 0:3,
                 as.character(as.Date("2024-01-01") + 0:3),
                 as.POSIXct("2024-01-01", tz = "UTC") + (0:3) * 3600,
                 c("2024-01-01T00:00:00Z", "2024-01-01T01:00:00Z",
                   "2024-01-01T02:00:00Z", "2024-01-01T03:00:00Z"),
                 ordered(c("winter", "spring", "summer", "autumn"),
                   levels = c("winter", "spring", "summer", "autumn")))) {
  timed <- complete
  timed$time <- axis[as.integer(timed$time)]
  timed <- timed[rev(seq_len(nrow(timed))), ]
  result <- tidy_hd_event(timed, axis[1], axis[3], draws = TRUE)
  expect_equal(result$value, rep(3, 3), info = "Supported time classes retain inclusive chronological windows.")
}
# POSIXt's default character format changes when a subset contains only midnight.
midnight <- shuffled
axis <- as.POSIXct("2024-01-01", tz = "UTC") + c(0, 24, 48, 84) * 3600
midnight$time <- axis[as.integer(midnight$time)]
expect_equal(tidy_hd_event(midnight, "2024-01-01 00:00:00", "2024-01-03 00:00:00",
  draws = TRUE)$value, rep(3, 3))
expect_equal(tidy_hd_event(midnight, "2024-01-01", "2024-01-03", draws = TRUE)$value, rep(3, 3))
cumulative <- bsvarPost:::compute_hd_event_cumulative(midnight, axis[1], axis[3])
expect_equal(cumulative$draws$value, rep(1:3, 3))
expect_false(anyNA(cumulative$draws$time))
expect_error(tidy_hd_event(midnight, "2024-01-02 24:00:00", axis[3]), "No historical decomposition")
dst_axis <- as.POSIXct("2024-10-27 00:30:00", tz = "UTC") + (0:3) * 3600
attr(dst_axis, "tzone") <- "Europe/Vienna"
dst <- complete
dst$time <- dst_axis[as.integer(dst$time)]
expect_equal(tidy_hd_event(dst, dst_axis[2], dst_axis[3], draws = TRUE)$value, rep(2, 3))
expect_equal(tidy_hd_event(dst, "2024-10-27T01:30:00Z", dst_axis[3], draws = TRUE)$value, rep(2, 3))
expect_error(tidy_hd_event(dst, "2024-10-27 02:30:00", dst_axis[3]), "Ambiguous HD time bound")
declared <- complete
declared$time <- ordered(declared$time, levels = as.character(1:4))
expect_error(tidy_hd_event(declared[declared$time != "2", ], "1", "3"), "missing period.*2")
ambiguous <- complete
ambiguous$time[ambiguous$time == "2"] <- "01"
expect_error(tidy_hd_event(ambiguous, "1", "3"), "Ambiguous HD periods")
duplicate_axis <- bounded
dimnames(duplicate_axis)[[3]][2] <- "1"
expect_error(tidy_hd_event(duplicate_axis, "1", "3"), "unique")

expect_error(
  tidy_hd_event(tidy_hd(post_bsvar, draws = FALSE), start = time_window[1], end = time_window[2]),
  pattern = "draw-level tidy HD table",
  info = "tidy_hd_event: summary-level tidy HD input fails clearly."
)
