# Render the exact labeled analysis chunks displayed in the articles.
# Optional PNG basenames restrict regeneration. Rebuild fixtures separately with
# tools/build-demo-fixtures.R, then reinstall before rendering.
source("tools/doc-helpers.R")
args <- commandArgs(trailingOnly = TRUE)
recipes <- figure_recipes()
if (any(!args %in% recipes$figure)) stop("Unknown figure name. For fixtures use tools/build-demo-fixtures.R, then reinstall.")
check_demo_fixtures()
# Grob construction can open the default device even without printing.
# Keep that device off disk so rendering never leaves a top-level Rplots.pdf.
grDevices::pdf(file = NULL)
selected <- if (length(args)) recipes[recipes$figure %in% args, ] else recipes
for (article in unique(selected$article)) {
  env <- new.env(parent = globalenv())
  targets <- selected[selected$article == article, ]
  for (chunk in read_doc_chunks(file.path("vignettes", paste0(article, ".Rmd")))) {
    if (!chunk$skip) eval(parse(text = chunk$code), envir = env)
    i <- match(chunk$label, targets$chunk)
    if (is.na(i)) next
    r <- targets[i, ]
    stopifnot(inherits(env$figure, "ggplot") || inherits(env$figure, "grob"))
    path <- file.path("vignettes/figures", r$figure)
    ggplot2::ggsave(path, env$figure, width = r$width, height = r$height, dpi = 150, bg = "white")
    message("Rendered ", r$figure)
    if (i == nrow(targets)) break
  }
}
check_figure_assets()
invisible(grDevices::dev.off())
