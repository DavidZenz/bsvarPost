#' bsvarPost: Post-Estimation Tools for bsvars and bsvarSIGNs
#'
#' Companion post-estimation tools for Bayesian structural vector
#' autoregressions fitted with the `bsvars` and `bsvarSIGNs` packages.
#'
#' @section Vignettes:
#' Use [utils::browseVignettes()] to open the package articles:
#'
#' - `browseVignettes(package = "bsvarPost")`
#'
#' If no vignettes are listed there, reinstall the GitHub package with
#' `build_vignettes = TRUE`.
#'
#' The package currently ships with:
#'
#' - Getting Started (`bsvarPost`)
#' - Post-Estimation Workflows (`post-estimation-workflows`)
#' - Hypothesis Testing (`hypothesis-testing`)
#'
#' @keywords internal
#' @importFrom tibble tibble as_tibble
#' @importFrom ggplot2 autoplot ggplot aes geom_line geom_ribbon geom_hline
#' @importFrom ggplot2 facet_grid facet_wrap labs theme_minimal scale_x_continuous
#' @importFrom ggplot2 vars
#' @importFrom methods is
#' @importFrom rlang .data
#' @importFrom utils globalVariables
#' @import bsvars
#' @import bsvarSIGNs
"_PACKAGE"

utils::globalVariables(c(
  "variable", "shock", "horizon", "median", "lower", "upper",
  "metric", "value", "model", "flag", "posterior_prob",
  "restriction", "restriction_display", "restriction_type", "rank_score",
  "component", "label", "panel", "panel_variable"
))
