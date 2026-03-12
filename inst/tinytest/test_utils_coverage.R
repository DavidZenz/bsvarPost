Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")
data(us_fiscal_lsuw, package = "bsvars")
set.seed(1)
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
post <- bsvars::estimate(spec, S = 5, thin = 1, show_progress = FALSE)

# ---- theme_bsvarpost ----
theme_default <- theme_bsvarpost()
expect_true(
  inherits(theme_default, "theme"),
  info = "theme_bsvarpost(): inherits theme"
)
expect_true(
  inherits(theme_default, "gg"),
  info = "theme_bsvarpost(): inherits gg"
)

theme_paper <- theme_bsvarpost(preset = "paper")
expect_true(
  inherits(theme_paper, "theme"),
  info = "theme_bsvarpost(preset='paper'): inherits theme"
)

theme_slides <- theme_bsvarpost(preset = "slides")
expect_true(
  inherits(theme_slides, "theme"),
  info = "theme_bsvarpost(preset='slides'): inherits theme"
)

# ---- Plot styling functions ----
irf_tbl <- tidy_irf(post, horizon = 2)
p <- ggplot2::autoplot(irf_tbl)
expect_true(
  inherits(p, "ggplot"),
  info = "autoplot(tidy_irf(...)): produces ggplot"
)

styled_paper <- style_bsvar_plot(p, preset = "paper")
expect_true(
  inherits(styled_paper, "ggplot"),
  info = "style_bsvar_plot(preset='paper'): returns ggplot"
)

styled_slides <- style_bsvar_plot(p, preset = "slides")
expect_true(
  inherits(styled_slides, "ggplot"),
  info = "style_bsvar_plot(preset='slides'): returns ggplot"
)

tmpl <- template_bsvar_plot(p, family = "irf")
expect_true(
  inherits(tmpl, "ggplot"),
  info = "template_bsvar_plot(family='irf'): returns ggplot"
)

tmpl_cdm <- template_bsvar_plot(p, family = "cdm")
expect_true(
  inherits(tmpl_cdm, "ggplot"),
  info = "template_bsvar_plot(family='cdm'): returns ggplot"
)

ann <- annotate_bsvar_plot(p, title = "Test", subtitle = "Sub")
expect_true(
  inherits(ann, "ggplot"),
  info = "annotate_bsvar_plot(title, subtitle): returns ggplot"
)

ann_lines <- annotate_bsvar_plot(p, yintercept = 0, xintercept = 2)
expect_true(
  inherits(ann_lines, "ggplot"),
  info = "annotate_bsvar_plot(yintercept, xintercept): returns ggplot"
)

ann_window <- annotate_bsvar_plot(p, xmin = 1, xmax = 3)
expect_true(
  inherits(ann_window, "ggplot"),
  info = "annotate_bsvar_plot(xmin, xmax): returns ggplot"
)

pub <- publish_bsvar_plot(irf_tbl)
expect_true(
  inherits(pub, "ggplot"),
  info = "publish_bsvar_plot(irf_tbl): returns ggplot"
)

# ---- Internal utility: new_bsvar_post_tbl ----
# Verified indirectly through tidy_irf output
irf_result <- tidy_irf(post, horizon = 2)
expect_true(
  inherits(irf_result, "bsvar_post_tbl"),
  info = "new_bsvar_post_tbl: tidy_irf output has bsvar_post_tbl class"
)
expect_true(
  inherits(irf_result, "tbl_df"),
  info = "new_bsvar_post_tbl: tidy_irf output has tbl_df class"
)
expect_true(
  inherits(irf_result, "tbl"),
  info = "new_bsvar_post_tbl: tidy_irf output has tbl class"
)
expect_true(
  inherits(irf_result, "data.frame"),
  info = "new_bsvar_post_tbl: tidy_irf output has data.frame class"
)

# ---- Internal utility: object_type attribute ----
expect_equal(
  attr(irf_result, "object_type"),
  "irf",
  info = "new_bsvar_post_tbl: object_type attribute is 'irf' for tidy_irf output"
)

cdm_result <- tidy_cdm(post, horizon = 2)
expect_equal(
  attr(cdm_result, "object_type"),
  "cdm",
  info = "new_bsvar_post_tbl: object_type attribute is 'cdm' for tidy_cdm output"
)

# ---- Internal utility: model column default name ----
expect_true(
  "model" %in% names(irf_result),
  info = "tidy_irf: has model column"
)
expect_equal(
  unique(irf_result$model),
  "model1",
  info = "tidy_irf: default single-model name is 'model1'"
)

# ---- Internal utility: ensure_model_names ----
# Tested indirectly via compare_* output (model names are assigned by ensure_model_names)
post2 <- bsvars::estimate(spec, S = 5, thin = 1, show_progress = FALSE)
compare_result <- compare_irf(post, post2, horizon = 2)
expect_true(
  inherits(compare_result, "bsvar_post_tbl"),
  info = "ensure_model_names: compare_irf with two unnamed models returns bsvar_post_tbl"
)
model_names <- unique(compare_result$model)
expect_true(
  length(model_names) == 2,
  info = "ensure_model_names: two distinct model names assigned"
)

# ---- Internal utility: resolve_array_dimnames ----
# Tested indirectly: tidy_irf on draws with no dimnames produces character horizon labels
irf_result2 <- tidy_irf(post, horizon = 3)
expect_true(
  is.numeric(irf_result2$horizon),
  info = "resolve_array_dimnames: horizon column is numeric in tidy_irf output"
)
expect_true(
  0 %in% irf_result2$horizon,
  info = "resolve_array_dimnames: horizon 0 present in tidy_irf output"
)

# ---- plot_hypothesis with bsvar_post_tbl input ----
h_tbl <- hypothesis_irf(post, variable = 1, shock = 1, horizon = 0:2, relation = ">", value = 0)
p_hyp <- plot_hypothesis(h_tbl)
expect_true(
  inherits(p_hyp, "ggplot"),
  info = "plot_hypothesis(bsvar_post_tbl): returns ggplot"
)
