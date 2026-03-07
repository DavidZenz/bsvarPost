#' bsvarPost: Post-Estimation Tools for bsvars and bsvarSIGNs
#'
#' Companion post-estimation tools for Bayesian structural vector
#' autoregressions fitted with the `bsvars` and `bsvarSIGNs` packages.
#'
#' @keywords internal
#' @importFrom tibble tibble as_tibble
#' @importFrom ggplot2 autoplot ggplot aes geom_line geom_ribbon geom_hline
#' @importFrom ggplot2 facet_grid facet_wrap labs theme_minimal scale_x_continuous
#' @importFrom ggplot2 vars
#' @importFrom methods is
#' @importFrom utils globalVariables
#' @import bsvars
#' @import bsvarSIGNs
"_PACKAGE"

utils::globalVariables(c("variable", "shock"))
