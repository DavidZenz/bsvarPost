# Run against an installed development build, for example:
# Rscript --vanilla tools/benchmark-hardening.R /tmp/bsvarPost-benchmarks.csv
# This is a measurement tool, not a timing gate in the test suite.
library(bsvarPost)

measure <- function(label, operation, iterations = 3L) {
  samples <- lapply(seq_len(iterations), function(i) {
    gc()
    profile <- tempfile()
    Rprofmem(profile)
    elapsed <- tryCatch(system.time(operation())[["elapsed"]], finally = Rprofmem(NULL))
    allocations <- readLines(profile, warn = FALSE)
    unlink(profile)
    bytes <- suppressWarnings(as.numeric(sub(" .*", "", allocations)))
    c(elapsed_seconds = elapsed, allocated_bytes = sum(bytes, na.rm = TRUE))
  })
  data.frame(operation = label, elapsed_seconds = median(vapply(samples, `[[`, numeric(1), 1L)),
             allocated_bytes = median(vapply(samples, `[[`, numeric(1), 2L)))
}

cases <- list(small = c(2L, 100L, 100L), many_draws = c(2L, 100L, 1000L),
              more_variables = c(5L, 200L, 100L))
results <- list()
set.seed(20261025)
for (name in names(cases)) {
  case <- cases[[name]]
  n <- case[1]; times <- case[2]; draws <- case[3]
  hd <- array(rnorm(n * n * times * draws), c(n, n, times, draws),
              dimnames = list(paste0("y", seq_len(n)), paste0("s", seq_len(n)),
                              as.character(seq_len(times)), as.character(seq_len(draws))))
  class(hd) <- c("PosteriorHD", "array")
  reference <- function() tidy_hd_event(tidy_hd(hd, draws = TRUE), start = "1", end = "2")
  optimized <- function() tidy_hd_event(hd, start = "1", end = "2")
  expected <- reference()
  observed <- optimized()
  key <- c("model", "variable", "shock")
  matched <- vctrs::vec_match(as.data.frame(observed[key]), as.data.frame(expected[key]))
  columns <- c("mean", "median", "sd", "lower", "upper")
  stopifnot(isTRUE(all.equal(as.data.frame(observed[columns]),
                            as.data.frame(expected[matched, columns]), check.attributes = FALSE)))
  operations <- list(full_sample_event = reference, selected_array_event = optimized,
                     tidy_hd = function() tidy_hd(hd),
                     grouped_plot = function() plot_hd_lines(hd,
                       shock_groups = setNames(rep("all", n), dimnames(hd)[[2]])))
  for (label in names(operations)) {
    row <- measure(label, operations[[label]])
    row$case <- name
    row$array_bytes <- as.numeric(object.size(hd))
    results[[length(results) + 1L]] <- row
    cat(name, label, row$elapsed_seconds, "seconds;", row$allocated_bytes, "allocated bytes\n")
    flush.console()
  }
  # A short response window exercises representative selection without an
  # estimation step or a separate large fixture.
  ir <- hd[, , 1:10, , drop = FALSE]
  dimnames(ir)[[3]] <- as.character(0:9)
  class(ir) <- c("PosteriorIR", "array")
  row <- measure("representative_selection", function() median_target_irf(ir))
  row$case <- name
  row$array_bytes <- as.numeric(object.size(ir))
  results[[length(results) + 1L]] <- row
}
results <- do.call(rbind, results)
print(results, row.names = FALSE)
output <- commandArgs(trailingOnly = TRUE)
if (length(output)) utils::write.csv(results, output[1], row.names = FALSE)
