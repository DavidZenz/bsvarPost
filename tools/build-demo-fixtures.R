# Rebuild installed demonstration assets. Existing input snapshots are reused;
# --refresh-inputs explicitly adopts the datasets in the installed upstreams.
args <- commandArgs(trailingOnly = TRUE)
stopifnot(all(args %in% "--refresh-inputs"))
out <- "inst/extdata"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
library(bsvars)
library(bsvarSIGNs)
snapshot <- function(name, package) {
  path <- file.path(out, paste0(name, ".rds"))
  if (!file.exists(path) || "--refresh-inputs" %in% args) {
    env <- new.env()
    utils::data(list = name, package = package, envir = env)
    saveRDS(env[[name]], path, compress = "xz", version = 2)
  }
  readRDS(path)
}
fiscal <- snapshot("us_fiscal_lsuw", "bsvars")
optimism <- snapshot("optimism", "bsvarSIGNs")
sign_irf <- matrix(c(0, 1, rep(NA_real_, 23)), 5, 5)
settings <- data.frame(
  file = c("fiscal_post_bsvar.rds", "fiscal_post_bsvar_alt.rds",
           "sign_post.rds", "sign_post_alt.rds"),
  input = c(rep("us_fiscal_lsuw.rds", 2), rep("optimism.rds", 2)),
  seed = c(123L, 456L, 123L, 456L), p = c(1L, 3L, 4L, 2L),
  draws = 200L, thin = 1L,
  transformation = c(rep("Unchanged: log real per capita levels", 2),
                     rep("Input multiplied by 100", 2)),
  restrictions = c(rep("bsvars default identification", 2),
    rep("sign_irf = matrix(c(0, 1, rep(NA_real_, 23)), 5, 5)", 2)),
  stringsAsFactors = FALSE
)
for (i in seq_len(nrow(settings))) {
  is_sign <- i > 2L
  input <- if (is_sign) optimism else fiscal
  set.seed(settings$seed[i])
  spec <- if (is_sign) {
    bsvarSIGNs::specify_bsvarSIGN$new(input * 100, p = settings$p[i], sign_irf = sign_irf)
  } else bsvars::specify_bsvar$new(input, p = settings$p[i])
  post <- bsvars::estimate(spec, S = 200, thin = 1, show_progress = FALSE)
  saveRDS(post, file.path(out, settings$file[i]), compress = "xz", version = 2)
  settings$input_rows[i] <- nrow(input)
  settings$input_variables[i] <- ncol(input)
  times <- if (is.ts(input)) as.character(time(input)) else as.character(seq_len(nrow(input)))
  settings$sample_start[i] <- times[1]
  settings$sample_end[i] <- tail(times, 1)
}
settings$bsvars_version <- as.character(utils::packageVersion("bsvars"))
settings$bsvarSIGNs_version <- as.character(utils::packageVersion("bsvarSIGNs"))
settings$R_version <- as.character(getRversion())
settings$input_md5 <- unname(tools::md5sum(file.path(out, settings$input)))
settings$posterior_md5 <- unname(tools::md5sum(file.path(out, settings$file)))
utils::write.csv(settings, file.path(out, "demo-metadata.csv"), row.names = FALSE)
print(settings[, c("file", "p", "seed", "draws", "sample_start", "sample_end")])
