# Post-estimation Analysis with bsvarPost

**bsvarPost** provides posterior analyses for Bayesian Structural Vector
Autoregressions estimated with **bsvars** and **bsvarSIGNs**. It
computes posterior summaries, cumulative dynamic responses, comparisons
across model specifications, posterior probabilities of hypotheses,
representative draws, response-timing measures, and historical-shock
contributions.

The examples examine the response of US GDP (`gdp`) to a
government-spending shock (`gs`) using the
[`bsvars::us_fiscal_lsuw`](https://bsvars.org/bsvars/reference/us_fiscal_lsuw.html)
data. They assume familiarity with model specification and posterior
simulation in the parent packages. Precomputed posterior draws reduce
computation time, while the same functions apply directly to posterior
objects obtained in empirical analyses.

## Posterior distributions from bsvars and bsvarSIGNs

The analysis starts from a posterior distribution estimated by either
parent package. The following code specifies a Bayesian Structural
Vector Autoregression with **bsvars** and simulates draws from its
posterior distribution:

``` r

data("us_fiscal_lsuw", package = "bsvars")
spec <- bsvars::specify_bsvar$new(us_fiscal_lsuw, p = 1)
post <- bsvars::estimate(spec, S = 2000, thin = 1,
                         show_progress = FALSE)
```

The remaining examples use the precomputed `post` object loaded above.
This `PosteriorBSVAR` object can be passed directly to **bsvarPost**
functions.

## Posterior summaries

The `tidy_*()` functions transform posterior quantities into long-format
tibbles. Here,
[`tidy_irf()`](https://davidzenz.github.io/bsvarPost/reference/tidy_irf.md)
computes posterior medians and 90% pointwise credible intervals for
impulse responses. The reported values correspond to four horizons of
the GDP response to a government-spending shock.

``` r

irf_tbl <- tidy_irf(post, horizon = 12, probability = 0.90)
irf_focus <- subset(irf_tbl, variable == "gdp" & shock == "gs" &
                    horizon %in% c(0, 4, 8, 12),
                    select = c(variable, shock, horizon, median, lower, upper))
irf_focus
#> # A tibble: 4 × 6
#>   variable shock horizon     median    lower    upper
#>   <chr>    <chr>   <dbl>      <dbl>    <dbl>    <dbl>
#> 1 gdp      gs          0 -0.0000935 -0.00115 0.000901
#> 2 gdp      gs          4 -0.000702  -0.00191 0.000522
#> 3 gdp      gs          8 -0.00119   -0.00301 0.000284
#> 4 gdp      gs         12 -0.00158   -0.00394 0.000289
```

The same representation applies to other posterior quantities. Summary
tables contain posterior location and credible-interval columns, whereas
`draws = TRUE` returns the individual posterior draws.

``` r

tidy_cdm(post, horizon = 12)       # cumulative responses
tidy_fevd(post, horizon = 12)      # variance shares
tidy_hd(post)                      # historical contributions
tidy_forecast(post, horizon = 8)   # predictive paths
tidy_shocks(post)                  # structural shocks
```

These tables can be filtered, combined with other variables, or
visualised without direct manipulation of the posterior arrays.

## Cumulative dynamic responses

[`cdm()`](https://davidzenz.github.io/bsvarPost/reference/cdm.md)
accumulates the impulse response through each horizon separately for
every posterior draw. The resulting posterior distribution describes
cumulative dynamic responses, and
[`tidy_cdm()`](https://davidzenz.github.io/bsvarPost/reference/tidy_cdm.md)
reports its posterior summaries and credible intervals.

``` r

cdm_draws <- cdm(post, horizon = 12)
cdm_tbl <- tidy_cdm(cdm_draws, probability = 0.90)
cdm_focus <- subset(cdm_tbl, variable == "gdp" & shock == "gs" &
                    horizon %in% c(0, 4, 8, 12),
                    select = c(variable, shock, horizon, median, lower, upper))
cdm_focus
#> # A tibble: 4 × 6
#>   variable shock horizon     median    lower    upper
#>   <chr>    <chr>   <dbl>      <dbl>    <dbl>    <dbl>
#> 1 gdp      gs          0 -0.0000935 -0.00115 0.000901
#> 2 gdp      gs          4 -0.00211   -0.00817 0.00344 
#> 3 gdp      gs          8 -0.00618   -0.0169  0.00487 
#> 4 gdp      gs         12 -0.0121    -0.0311  0.00547
```

Interpretation of cumulative dynamic responses as economic multipliers
depends on the transformations and scaling used in the model. See
[`?cdm`](https://davidzenz.github.io/bsvarPost/reference/cdm.md) for the
`scale_by` and `scale_var` arguments.

![Posterior cumulative dynamic responses with pointwise credible
bands](figures/cdm-showcase.png)

## Comparison of model specifications

The second posterior distribution corresponds to the same three-variable
system with a longer lag order.
[`compare_cdm()`](https://davidzenz.github.io/bsvarPost/reference/compare_cdm.md)
computes posterior summaries of cumulative dynamic responses under both
specifications. Names assigned to the posterior arguments identify the
specifications in the `model` column.

``` r

cdm_comparison <- compare_cdm(
  baseline = post,
  longer_lag = post_alt,
  horizon = 12,
  probability = 0.90
)
subset(cdm_comparison, variable == "gdp" & shock == "gs" &
       horizon %in% c(4, 8, 12),
       select = c(model, horizon, median, lower, upper))
#> # A tibble: 6 × 5
#>   model      horizon   median    lower   upper
#>   <chr>        <dbl>    <dbl>    <dbl>   <dbl>
#> 1 baseline         4 -0.00211 -0.00817 0.00344
#> 2 baseline         8 -0.00618 -0.0169  0.00487
#> 3 baseline        12 -0.0121  -0.0311  0.00547
#> 4 longer_lag       4 -0.00277 -0.00934 0.00635
#> 5 longer_lag       8 -0.00866 -0.0262  0.0134 
#> 6 longer_lag      12 -0.0150  -0.0471  0.0209
```

The functions
[`compare_irf()`](https://davidzenz.github.io/bsvarPost/reference/compare_irf.md),
[`compare_fevd()`](https://davidzenz.github.io/bsvarPost/reference/compare_fevd.md),
and the remaining `compare_*()` methods provide the same comparison for
other posterior quantities. They report corresponding posterior
summaries across specifications without selecting a preferred model.

![Posterior impulse responses under two model
specifications](figures/compare-irf-showcase.png)

## Posterior probabilities of hypotheses

[`hypothesis_irf()`](https://davidzenz.github.io/bsvarPost/reference/hypothesis_irf.md)
computes the posterior probability that an impulse response satisfies a
specified inequality. The following hypothesis states that the GDP
response to the government-spending shock is positive at each selected
horizon.

``` r

prob_positive <- hypothesis_irf(
  post,
  variables = "gdp",
  shocks = "gs",
  horizon = c(0, 4, 8, 12),
  relation = ">",
  value = 0
)
prob_positive[, c("variable", "shock", "horizon", "posterior_prob")]
#> # A tibble: 4 × 4
#>   variable shock horizon posterior_prob
#>   <chr>    <chr>   <dbl>          <dbl>
#> 1 gdp      gs          0          0.47 
#> 2 gdp      gs          4          0.185
#> 3 gdp      gs          8          0.11 
#> 4 gdp      gs         12          0.09
```

`posterior_prob` is the model-conditional posterior probability of the
stated inequality, rather than a frequentist p-value.
[`joint_hypothesis_irf()`](https://davidzenz.github.io/bsvarPost/reference/joint_hypothesis_irf.md)
computes the probability that a condition holds jointly across several
horizons,
[`magnitude_audit()`](https://davidzenz.github.io/bsvarPost/reference/magnitude_audit.md)
evaluates economically meaningful thresholds, and
[`simultaneous_irf()`](https://davidzenz.github.io/bsvarPost/reference/simultaneous_irf.md)
constructs a credible band for an entire selected response path. The
[Inference and
Comparison](https://davidzenz.github.io/bsvarPost/articles/inference-and-comparison.md)
article develops these distinctions.

## Representative posterior draws and response timing

Pointwise medians need not correspond to any single posterior draw.
[`median_target_irf()`](https://davidzenz.github.io/bsvarPost/reference/median_target_irf.md)
selects the posterior draw whose response path is closest to the
pointwise posterior median over the requested variables, shocks, and
horizons. The selected path therefore preserves the joint dependence
within a single draw.

``` r

representative <- median_target_irf(
  post,
  horizon = 12,
  variables = "gdp",
  shocks = "gs"
)
representative_path <- subset(summary(representative),
                              variable == "gdp" & shock == "gs")
subset(representative_path, horizon %in% c(0, 4, 8, 12),
       select = c(variable, shock, horizon, median, draw_index, method))
#> # A tibble: 4 × 6
#>   variable shock horizon    median draw_index method       
#>   <chr>    <chr>   <dbl>     <dbl>      <int> <chr>        
#> 1 gdp      gs          0 -0.000148        144 median_target
#> 2 gdp      gs          4 -0.000712        144 median_target
#> 3 gdp      gs          8 -0.00119         144 median_target
#> 4 gdp      gs         12 -0.00160         144 median_target
```

[`peak_response()`](https://davidzenz.github.io/bsvarPost/reference/peak_response.md)
computes the magnitude and horizon of the peak response in every
posterior draw and reports posterior summaries of both quantities.

![Representative posterior draw and pointwise posterior
summary](figures/representative-showcase.png)

``` r

peak <- peak_response(
  post,
  horizon = 12,
  variables = "gdp",
  shocks = "gs",
  absolute = TRUE
)
peak[, c("variable", "shock", "median_value", "median_horizon")]
#> # A tibble: 1 × 4
#>   variable shock median_value median_horizon
#>   <chr>    <chr>        <dbl>          <dbl>
#> 1 gdp      gs        -0.00158             12
```

For analyses of response persistence,
[`duration_response()`](https://davidzenz.github.io/bsvarPost/reference/duration_response.md),
[`half_life_response()`](https://davidzenz.github.io/bsvarPost/reference/half_life_response.md),
and
[`time_to_threshold()`](https://davidzenz.github.io/bsvarPost/reference/time_to_threshold.md)
compute related quantities for the posterior distribution without
reducing it to a single response path.

## Historical decompositions for selected periods

`tidy_hd(draws = TRUE)` returns the contribution of each structural
shock to each observed variable in every posterior draw.
[`tidy_hd_event()`](https://davidzenz.github.io/bsvarPost/reference/tidy_hd_event.md)
aggregates these contributions over a selected period, while
[`shock_ranking()`](https://davidzenz.github.io/bsvarPost/reference/shock_ranking.md)
orders the shocks by their contributions. The following example
considers an illustrative four-quarter period.

``` r

hd_draws <- tidy_hd(post, draws = TRUE)
event_tbl <- tidy_hd_event(
  hd_draws,
  start = "1958",
  end = "1958.75"
)

subset(event_tbl, variable == "gdp",
       select = c(variable, shock, event_start, event_end, median))
#> # A tibble: 3 × 5
#>   variable shock event_start event_end median
#>   <chr>    <chr> <chr>       <chr>      <dbl>
#> 1 gdp      gdp   1958        1958.75   -14.9 
#> 2 gdp      gs    1958        1958.75    -3.15
#> 3 gdp      ttr   1958        1958.75    -1.23

ranking <- shock_ranking(hd_draws, start = "1958", end = "1958.75",
                         variables = "gdp")
ranking[, c("variable", "shock", "median", "rank")]
#> # A tibble: 3 × 4
#>   variable shock median  rank
#>   <chr>    <chr>  <dbl> <int>
#> 1 gdp      gdp   -14.9      1
#> 2 gdp      gs     -3.15     2
#> 3 gdp      ttr    -1.23     3
```

These functions transform the historical decompositions computed by the
parent package into posterior summaries for selected periods. The choice
of period and the interpretation of structural-shock contributions are
discussed in [Historical
Decompositions](https://davidzenz.github.io/bsvarPost/articles/historical-decomposition-events.md).

![Structural-shock contributions to GDP over the full
sample](figures/hd-overlay-showcase.png)

## Figures and tables

[`publish_bsvar_plot()`](https://davidzenz.github.io/bsvarPost/reference/publish_bsvar_plot.md)
displays the representative posterior draw using a consistent `ggplot2`
style. The returned `ggplot` object can be annotated or modified before
saving.

``` r

publish_bsvar_plot(representative_path, family = "irf", preset = "paper",
  title = "GDP response to a government-spending shock",
  caption = "Median-target posterior draw")
```

![](bsvarPost_files/figure-html/publication-plot-1.png)

[`as_kable()`](https://davidzenz.github.io/bsvarPost/reference/as_kable.md)
presents the selected posterior summary as a formatted table:

``` r

as_kable(peak, caption = "Signed GDP response at the peak absolute magnitude",
         digits = 3, preset = "compact")
```

| Model | Variable | Shock | Mean value | Median value | Lower value | Upper value | Mean horizon | Median horizon | Lower horizon | Upper horizon |
|:---|:---|:---|---:|---:|---:|---:|---:|---:|---:|---:|
| model1 | gdp | gs | -0.017 | -0.002 | -0.004 | 0.001 | 10.44 | 12 | 0 | 12 |

Signed GDP response at the peak absolute magnitude {.table}

## Related analyses

- [Inference and
  Comparison](https://davidzenz.github.io/bsvarPost/articles/inference-and-comparison.md)
  covers joint and magnitude hypotheses, simultaneous credible bands,
  and model comparisons.
- [Historical
  Decompositions](https://davidzenz.github.io/bsvarPost/articles/historical-decomposition-events.md)
  covers selected historical periods, structural-shock contributions,
  and shock rankings.
- [Analysis of Sign-Restricted
  Models](https://davidzenz.github.io/bsvarPost/articles/sign-restricted-workflows.md)
  covers `most_likely_admissible_*()`,
  [`restriction_audit()`](https://davidzenz.github.io/bsvarPost/reference/restriction_audit.md),
  [`acceptance_diagnostics()`](https://davidzenz.github.io/bsvarPost/reference/acceptance_diagnostics.md),
  and sign-model comparisons.

The [reference
index](https://davidzenz.github.io/bsvarPost/reference/index.html)
documents all functions and their arguments.
