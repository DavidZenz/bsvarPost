#' bsvarPost: Posterior Analysis for bsvars and bsvarSIGNs
#'
#' Posterior summaries, inference, model comparison, and visualisation for
#' Bayesian structural vector autoregressions estimated with the `bsvars` and
#' `bsvarSIGNs` packages.
#'
#' @section Result tables:
#' Posterior tables include provenance as ordinary columns, alongside the
#' estimates and identifiers. See [posterior_provenance] for probability,
#' scaling, units, software versions and draw-identity definitions. Default
#' reports and CSV exports include these columns; compact reports omit most
#' provenance columns. Select columns explicitly when a fixed schema is needed.
#'
#' @section Vignettes:
#' Use [utils::browseVignettes()] to open the package articles:
#'
#' - `browseVignettes(package = "bsvarPost")`
#'
#' If no vignettes are listed there, reinstall the GitHub package with
#' `build_vignettes = TRUE`.
#'
#' The package includes the following articles:
#'
#' - Post-estimation Analysis with bsvarPost (`bsvarPost`)
#' - Inference and Comparison (`inference-and-comparison`)
#' - Historical Decompositions (`historical-decomposition-events`)
#' - Analysis of Sign-Restricted Models (`sign-restricted-workflows`)
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
