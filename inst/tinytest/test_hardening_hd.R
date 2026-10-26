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
