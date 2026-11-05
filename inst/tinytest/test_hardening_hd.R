hd <- array(0, c(1, 3, 2, 3), dimnames = list("y", c("a", "b", "c"), c("1", "2"), as.character(1:3)))
hd[1, 1, , ] <- rep(c(-1, 0, 1), each = 2)
hd[1, 2, , ] <- -hd[1, 1, , ]
class(hd) <- c("PosteriorHD", "array")
groups <- c(a = "together", b = "together", c = "zero")
lines <- plot_hd_lines(hd, shock_groups = groups)
grouped <- subset(lines$data, component == "together")
expect_equal(grouped$median, c(0, 0))
expect_equal(grouped$lower, c(0, 0))
expect_equal(grouped$upper, c(0, 0))
expect_error(plot_hd_lines(tidy_hd(hd), shock_groups = groups), "requires draw-level")
expect_error(plot_hd_lines(tidy_hd(hd), top_n = 1), "requires draw-level")
expect_true(inherits(plot_hd_lines(tidy_hd(hd)), "ggplot"))

draw_table <- tidy_hd(hd, draws = TRUE)
draw_table$component <- draw_table$shock
observed <- tibble::tibble(model = "model1", variable = "y", time = c("1", "2"), observed = c(10, 20))
baseline <- bsvarPost:::compute_hd_baseline_draws(draw_table, observed)$baseline
expect_equal(baseline$value, rep(c(10, 20), each = 3))

hd[1, 1, , ] <- rep(c(0, 0, 100), each = 2)
hd[1, 2, , ] <- rep(c(0, 100, 0), each = 2)
plotted <- plot_hd_lines(hd, shock_groups = groups)
expect_equal(subset(plotted$data, component == "together")$median, c(100, 100))
event <- bsvarPost:::prepare_hd_event_plot_data(hd, start = "1", end = "2", shock_groups = groups)
expect_equal(subset(event, component == "together")$median, 200)
cumulative <- bsvarPost:::compute_hd_event_cumulative(hd, start = "1", end = "2", shock_groups = groups)
expect_equal(subset(cumulative$summary, component == "together" & time == "2")$median, 200)
expect_error(plot_hd_event_distribution(tidy_hd_event(hd, start = "1", end = "2"), shock_groups = groups), "requires draw-level")

raw_event <- tidy_hd_event(hd, start = "1", end = "2", draws = TRUE)
manual <- tidy_hd_event(tidy_hd(hd, draws = TRUE), start = "1", end = "2", draws = TRUE)
keys <- c("model", "variable", "shock", "draw")
match_rows <- vctrs::vec_match(as.data.frame(raw_event[keys]), as.data.frame(manual[keys]))
expect_equal(raw_event$value, manual$value[match_rows])
expect_error(tidy_hd_event(hd, start = "2", end = "1"), "must not follow")

# Event ranking must also choose the cumulative plot's retained components.
hd[1, 1, 1, ] <- 10
hd[1, 1, 2, ] <- -10
hd[1, 2, , ] <- 1
end_point <- bsvarPost:::compute_hd_event_cumulative(hd, "1", "2", top_n = 1)$summary
end_point <- subset(end_point, time == "2")
event_top <- bsvarPost:::prepare_hd_event_plot_data(hd, "1", "2", top_n = 1)
expect_equal(end_point$median[match(event_top$component, end_point$component)], event_top$median)
expect_true("b" %in% end_point$component)

from_array <- bsvarPost:::prepare_hd_plot_data(hd, top_n = 1)$components
from_draws <- bsvarPost:::prepare_hd_plot_data(tidy_hd(hd, draws = TRUE), top_n = 1)$components
key <- c("model", "variable", "component", "time")
matched <- vctrs::vec_match(as.data.frame(from_array[key]), as.data.frame(from_draws[key]))
expect_equal(from_array$median, from_draws$median[matched])
expect_equal(from_array$lower, from_draws$lower[matched])
expect_equal(from_array$upper, from_draws$upper[matched])

for (p in list(plotted, plot_hd_event_distribution(hd, start = "1", end = "2", shock_groups = groups))) {
  expect_true(inherits(ggplot2::ggplot_build(p), "ggplot_built"))
}

# Missing/duplicate raw cells cannot become component sums before validation.
cells <- array(0, c(1, 2, 1, 3), dimnames = list("y", c("a", "b"), "1", c("d1", "d2", "d3")))
cells[1, 1, 1, ] <- 1:3
cells[1, 2, 1, ] <- 10 * (1:3)
class(cells) <- c("PosteriorHD", "array")
raw <- tidy_hd(cells, draws = TRUE)
group <- c(a = "Both", b = "Both")
valid <- plot_hd_lines(raw[rev(seq_len(nrow(raw))), ], shock_groups = group)$data
expect_equal(valid$median, 22)
expect_equal(c(valid$lower, valid$upper), as.numeric(quantile(c(11, 22, 33), c(.05, .95))))
missing <- raw[!(raw$shock == "b" & raw$draw == 2), ]
expect_error(plot_hd_lines(missing, shock_groups = group), "Incomplete HD draw coverage.*model1.*y.*b.*2")
expect_error(plot_hd_event_cumulative(missing, "1", shock_groups = group), "Incomplete HD draw coverage")
expect_error(plot_hd_lines(rbind(raw, raw[raw$shock == "b" & raw$draw == 2, ]), shock_groups = group), "duplicate periods.*model1.*time.*draw")
zeros <- raw
zeros$value[zeros$shock == "b" & zeros$draw == 2] <- 0
expect_equal(plot_hd_lines(zeros, shock_groups = group)$data$median, 11)

grid <- array(seq_len(24), c(2, 2, 2, 3),
  dimnames = list(c("y1", "y2"), c("a", "b"), c("1", "2"), as.character(1:3)))
class(grid) <- c("PosteriorHD", "array")
raw_grid <- tidy_hd(grid, draws = TRUE, model = "base")
alt <- raw_grid; alt$model <- "alt"; alt$value <- alt$value * 2
both <- rbind(raw_grid, alt)
p <- plot_hd_lines(both[rev(seq_len(nrow(both))), ], shock_groups = group)
oracle <- apply(apply(grid, c(1, 3, 4), sum), c(1, 2), median)
expected <- oracle[cbind(match(p$data$variable, rownames(oracle)), match(p$data$time, colnames(oracle)))]
expect_equal(p$data$median, as.numeric(expected) * ifelse(p$data$model == "alt", 2, 1))
missing <- raw_grid[-1, ]
expect_error(plot_hd_lines(missing, shock_groups = group), "Incomplete HD event window.*missing period")
missing <- raw_grid[!(raw_grid$variable == "y2" & raw_grid$shock == "b"), ]
expect_error(plot_hd_lines(missing, shock_groups = group), "Incomplete HD cell grid.*base.*y2.*b")
bad_id <- raw_grid; bad_id$draw_id[1] <- "different"
expect_error(plot_hd_lines(bad_id), "draw_id identifiers.*one-to-one")

# Native dates/instants and explicit ordered levels keep value/period mapping.
axes <- list(as.Date("2024-01-01") + 0:1,
  as.POSIXct("2024-10-27 00:30:00", tz = "UTC") + c(0, 3600),
  ordered(c("spring", "summer"), levels = c("spring", "summer")))
attr(axes[[2]], "tzone") <- "Europe/Vienna"
for (axis in axes) {
  timed <- raw_grid
  timed$time <- axis[as.integer(timed$time)]
  timed <- timed[rev(seq_len(nrow(timed))), ]
  p <- plot_hd_lines(timed, shock_groups = group)
  time_index <- if (inherits(axis, "POSIXt")) match(as.numeric(p$data$time), as.numeric(axis)) else
    match(as.character(p$data$time), as.character(axis))
  expect_equal(p$data$median, as.numeric(oracle[cbind(match(p$data$variable, rownames(oracle)), time_index)]))
  positions <- p$data$time_plot[match(seq_along(axis), time_index)]
  expect_true(all(diff(positions) > 0))
}
dates <- array(rep(c(10, 20, 30), 3), c(1, 1, 3, 3),
  dimnames = list("y", "a", c("1", "2", "3"), as.character(1:3)))
class(dates) <- c("PosteriorHD", "array")
dates <- tidy_hd(dates, draws = TRUE)
dates$time <- (as.Date("2024-01-01") + 0:2)[as.integer(dates$time)]
dates <- dates[order(match(as.character(dates$time), c("2024-01-01", "2024-01-03", "2024-01-02"))), ]
dated_plot <- plot_hd_lines(dates)$data
expect_equal(dated_plot$median[order(dated_plot$time_plot)], c(10, 20, 30))
