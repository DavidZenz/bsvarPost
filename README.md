# bsvarPost

**bsvarPost** turns posterior draws from **bsvars** and **bsvarSIGNs** into
response summaries, model comparisons, posterior probability statements,
historical decompositions, and publication tables and plots.

## Installation

Install from GitHub (R >= 4.1):

<!-- documentation-skip: installation -->
```r
install.packages("remotes")
remotes::install_github("DavidZenz/bsvarPost")
```

The online [articles](https://davidzenz.github.io/bsvarPost/articles/index.html)
are available without building vignettes. To install local HTML articles as well:

<!-- documentation-skip: installation -->
```r
install.packages(c("knitr", "rmarkdown"))
remotes::install_github("DavidZenz/bsvarPost", build_vignettes = TRUE)
```

## A complete first analysis

These installed demo fits use US log real per capita GDP, government spending
(`gs`), and tax revenue (`ttr`). The baseline has one lag; the alternative has
three. Each has **200 retained draws for demonstration**, which does not establish
sampling adequacy for an empirical study. The introduction supplies the seeded
[estimation recipe](https://davidzenz.github.io/bsvarPost/articles/bsvarPost.html#estimate-your-own-models).

```r
library(bsvarPost)
post <- readRDS(system.file("extdata", "fiscal_post_bsvar.rds",
  package = "bsvarPost", mustWork = TRUE))
post_alt <- readRDS(system.file("extdata", "fiscal_post_bsvar_alt.rds",
  package = "bsvarPost", mustWork = TRUE))

responses <- tidy_irf(post, horizon = 12, probability = 0.90)
gdp <- subset(responses, variable == "gdp" & shock == "gs")
gdp[gdp$horizon %in% c(0, 4, 8, 12),
    c("horizon", "median", "lower", "upper")]
```

Horizons are quarters after the shock, including impact at zero. Bounds are
pointwise 90% equal-tailed credible intervals. Responses use the fitted model's
structural-shock normalization and the original log units.

```r
comparison <- compare_cdm(baseline = post, longer_lag = post_alt,
  horizon = 12, probability = 0.90)
comparison_gdp <- subset(comparison, variable == "gdp" & shock == "gs")
comparison_plot <- ggplot2::autoplot(comparison_gdp) +
  ggplot2::labs(y = "Cumulative log response", x = "Quarters after shock")
comparison_plot

output <- tempfile(fileext = ".csv")
write_bsvar_csv(comparison_gdp, file = output)
read.csv(output, check.names = FALSE)[1:2,
  c("Model", "Horizon", "Median", "Interval method", "Draw count")]
```

A cumulative dynamic multiplier (CDM) sums each draw's responses from impact
through the selected horizon. With these data it is a cumulative log response;
a dollar-per-dollar fiscal multiplier requires additional conversion and a
spending-response denominator. `scale_by = "shock_sd"` divides by an observed
variable's sample standard deviation and does not perform that conversion.

The default CSV export preserves provenance columns, including interval mass
and method, scaling, upstream computation version and draw count. Keep these
columns when passing results to collaborators. This exporter uses readable
column labels; the introduction also shows a fixed-schema export. Economic units require your
knowledge of the model's transformations.

## Choose a workflow

| Research question | Start here |
|---|---|
| How do I summarize, compare and export responses? | [Complete fiscal analysis](https://davidzenz.github.io/bsvarPost/articles/bsvarPost.html) |
| How probable is a sign, magnitude or complete response path? | [Inference and comparison](https://davidzenz.github.io/bsvarPost/articles/inference-and-comparison.html) |
| Which shocks contributed during an event? | [Historical decompositions](https://davidzenz.github.io/bsvarPost/articles/historical-decomposition-events.html) |
| How do restrictions, representative draws and importance weights relate? | [Sign-restricted workflows](https://davidzenz.github.io/bsvarPost/articles/sign-restricted-workflows.html) |

The [function reference](https://davidzenz.github.io/bsvarPost/reference/index.html)
covers arguments and supported inputs, including FEVDs, forecasts and structural
shocks. In R, use `help(package = "bsvarPost")`, `?tidy_irf` or
`vignette(package = "bsvarPost")` for installed documentation.
