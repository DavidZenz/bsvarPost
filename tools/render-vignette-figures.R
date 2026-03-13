if (Sys.info()[["sysname"]] == "Darwin") {
  Sys.setenv(KMP_DUPLICATE_LIB_OK = "TRUE")
}

dir.create("vignettes/figures",  recursive = TRUE, showWarnings = FALSE)
dir.create("vignettes/fixtures", recursive = TRUE, showWarnings = FALSE)

.save_gg <- function(path, plot, width = 8, height = 5, dpi = 150) {
  ggplot2::ggsave(
    filename = path,
    plot = plot,
    width = width,
    height = height,
    dpi = dpi
  )
}

.save_base <- function(path, expr, width = 1600, height = 1200, res = 150) {
  grDevices::png(path, width = width, height = height, res = res)
  on.exit(grDevices::dev.off(), add = TRUE)
  force(expr)
}

library(bsvars)
library(bsvarSIGNs)
library(bsvarPost)
library(ggplot2)

# ── Fixture generation ────────────────────────────────────────────────────────

data(us_fiscal_lsuw)
cat("Variable names in us_fiscal_lsuw:\n")
print(colnames(us_fiscal_lsuw))

# Primary posterior fixture: p = 1, S = 200
set.seed(123)
spec_bsvar <- specify_bsvar$new(us_fiscal_lsuw, p = 1)
post_bsvar  <- estimate(spec_bsvar, S = 200, thin = 1, show_progress = FALSE)
saveRDS(post_bsvar, "vignettes/fixtures/fiscal_post_bsvar.rds", compress = "xz")

# Alternative specification fixture: p = 3, S = 200
set.seed(456)
spec_bsvar_alt <- specify_bsvar$new(us_fiscal_lsuw, p = 3)
post_bsvar_alt  <- estimate(spec_bsvar_alt, S = 200, thin = 1, show_progress = FALSE)
saveRDS(post_bsvar_alt, "vignettes/fixtures/fiscal_post_bsvar_alt.rds", compress = "xz")

# Report fixture file sizes
cat("\nFixture file sizes:\n")
cat("  fiscal_post_bsvar.rds:     ",
    file.size("vignettes/fixtures/fiscal_post_bsvar.rds"),     "bytes\n")
cat("  fiscal_post_bsvar_alt.rds: ",
    file.size("vignettes/fixtures/fiscal_post_bsvar_alt.rds"), "bytes\n")
cat("  Total (bytes):",
    file.size("vignettes/fixtures/fiscal_post_bsvar.rds") +
    file.size("vignettes/fixtures/fiscal_post_bsvar_alt.rds"), "\n")

# ── Load fixtures for figure generation ───────────────────────────────────────

post_bsvar     <- readRDS("vignettes/fixtures/fiscal_post_bsvar.rds")
post_bsvar_alt <- readRDS("vignettes/fixtures/fiscal_post_bsvar_alt.rds")

# ── Showcase figures ──────────────────────────────────────────────────────────

# cdm-showcase.png: conditional distribution moments, horizon = 20
cdm_bsvar <- cdm(post_bsvar, horizon = 20)
.save_base(
  "vignettes/figures/cdm-showcase.png",
  plot(cdm_bsvar)
)

# compare-irf-showcase.png: baseline / alternative naming, horizon = 20
cmp_irf <- compare_irf(baseline = post_bsvar, alternative = post_bsvar_alt, horizon = 20)
cmp_irf_focus <- cmp_irf[
  cmp_irf$variable == unique(cmp_irf$variable)[1] &
    cmp_irf$shock == unique(cmp_irf$shock)[1],
  ,
  drop = FALSE
]
.save_gg(
  "vignettes/figures/compare-irf-showcase.png",
  template_bsvar_plot(
    ggplot2::autoplot(cmp_irf_focus),
    family = "comparison",
    preset = "paper"
  ),
  width = 8,
  height = 4.5
)

# representative-showcase.png: median target IRF, horizon = 20
rep_bsvar <- median_target_irf(post_bsvar, horizon = 20)
.save_gg(
  "vignettes/figures/representative-showcase.png",
  publish_bsvar_plot(rep_bsvar, preset = "paper"),
  width = 8,
  height = 5
)

# diagnostics-showcase.png and hd-event-showcase.png: bsvarSIGNs optimism data
data(optimism)
sign_irf <- matrix(c(0, 1, rep(NA, 23)), 5, 5)
set.seed(202)
spec_sign <- specify_bsvarSIGN$new(
  optimism * 100,
  p = 4,
  sign_irf = sign_irf
)
post_sign <- estimate(spec_sign, S = 200, thin = 1, show_progress = FALSE)

diag_sign <- acceptance_diagnostics(post_sign)
.save_gg(
  "vignettes/figures/diagnostics-showcase.png",
  publish_bsvar_plot(diag_sign, preset = "paper"),
  width = 8,
  height = 4.5
)

hd_sign <- plot_hd_event(post_sign, start = 1, end = 4)
.save_gg(
  "vignettes/figures/hd-event-showcase.png",
  hd_sign,
  width = 8,
  height = 5
)

# hypothesis-showcase.png: hypothesis testing on fiscal model
.save_base(
  "vignettes/figures/hypothesis-showcase.png",
  plot(
    plot_hypothesis(
      post_bsvar,
      type      = "irf",
      variables = 1,
      shocks    = 1,
      horizon   = 0:20,
      relation  = ">",
      value     = 0
    )
  )
)

cat("\nAll fixtures and figures generated successfully.\n")
