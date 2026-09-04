# Inference and Comparison

This article starts with estimated posteriors and asks questions that
cannot be answered by plotting a pointwise median alone. The running
example compares two lag specifications for the
[`bsvars::us_fiscal_lsuw`](https://bsvars.org/bsvars/reference/us_fiscal_lsuw.html)
system. We focus on the GDP response to a government-spending shock,
without presuming that its sign or magnitude is known in advance.

The fixtures contain 200 stored draws and keep the article quick to
build. Replace them with your own compatible `bsvars` or `bsvarSIGNs`
posterior objects.

## Is the conclusion sensitive to specification?

Start with the comparison rather than two separate tables. Named
arguments to
[`compare_irf()`](https://davidzenz.github.io/bsvarPost/reference/compare_irf.md)
become stable model labels, and every other column has the same meaning
as in
[`tidy_irf()`](https://davidzenz.github.io/bsvarPost/reference/tidy_irf.md).

``` r

comparison <- compare_irf(
  baseline = post,
  longer_lag = post_alt,
  horizon = 12,
  probability = 0.90
)

subset(
  comparison,
  variable == "gdp" & shock == "gs" & horizon %in% c(0, 4, 8, 12),
  select = c(model, horizon, median, lower, upper))
#> # A tibble: 8 × 5
#>   model      horizon     median    lower    upper
#>   <chr>        <dbl>      <dbl>    <dbl>    <dbl>
#> 1 baseline         0 -0.0000935 -0.00115 0.000901
#> 2 baseline         4 -0.000702  -0.00191 0.000522
#> 3 baseline         8 -0.00119   -0.00301 0.000284
#> 4 baseline        12 -0.00158   -0.00394 0.000289
#> 5 longer_lag       0 -0.000111  -0.00117 0.000898
#> 6 longer_lag       4 -0.00100   -0.00316 0.00185 
#> 7 longer_lag       8 -0.00163   -0.00453 0.00206 
#> 8 longer_lag      12 -0.00220   -0.00544 0.00227
```

Read this descriptively: shifts in the center or interval show
specification sensitivity; they do not constitute a model-selection
rule. The same named- posterior pattern is available for
[CDMs](https://davidzenz.github.io/bsvarPost/reference/compare_cdm.md),
[FEVDs](https://davidzenz.github.io/bsvarPost/reference/compare_fevd.md),
[forecasts](https://davidzenz.github.io/bsvarPost/reference/compare_forecast.md),
and [historical-decomposition
events](https://davidzenz.github.io/bsvarPost/reference/compare_hd_event.md).

## How much posterior support does a statement have?

### Pointwise support

For a claim at particular horizons, ask directly what share of posterior
draws satisfies it. Here the claim is that the GDP response is positive.

``` r

positive_gdp <- hypothesis_irf(
  post,
  variables = "gdp",
  shocks = "gs",
  horizon = c(0, 4, 8, 12),
  relation = ">",
  value = 0
)

positive_gdp[, c("horizon", "posterior_prob", "median_gap",
                 "lower_gap", "upper_gap")]
#> # A tibble: 4 × 5
#>   horizon posterior_prob median_gap lower_gap upper_gap
#>     <dbl>          <dbl>      <dbl>     <dbl>     <dbl>
#> 1       0          0.47  -0.0000935  -0.00115  0.000901
#> 2       4          0.185 -0.000702   -0.00191  0.000522
#> 3       8          0.11  -0.00119    -0.00301  0.000284
#> 4      12          0.09  -0.00158    -0.00394  0.000289
```

`posterior_prob` is the model-conditional probability of the stated
inequality, not a p-value. The gap columns summarize the response minus
the threshold, so they retain information about effect size. Use
[`hypothesis_cdm()`](https://davidzenz.github.io/bsvarPost/reference/hypothesis_cdm.md)
for the same question about cumulative responses.

### Joint support across a path

Pointwise probabilities do not answer whether one draw satisfies every
condition. For the stronger claim that the response is positive from
impact through horizon 8, intersect the conditions draw by draw.

``` r

positive_path <- joint_hypothesis_irf(
  post,
  variable = "gdp",
  shock = "gs",
  horizon = 0:8,
  relation = ">",
  value = 0
)

positive_path[, c("posterior_prob", "n_constraints")]
#> # A tibble: 1 × 2
#>   posterior_prob n_constraints
#>            <dbl>         <int>
#> 1          0.095             9
```

The joint probability can be much smaller than the probability at any
one horizon because all nine inequalities must hold in the same draw.
See
[`joint_hypothesis_cdm()`](https://davidzenz.github.io/bsvarPost/reference/joint_hypothesis_cdm.md)
for cumulative paths.

### A magnitude question

A sign may be too weak for the research question. Suppose `0.001` is a
pre-specified, substantively meaningful response size on the scale used
to fit the model. We can ask for the probability that the absolute
response exceeds that threshold at horizon 8.

``` r

material_response <- magnitude_audit(
  post,
  type = "irf",
  variable = "gdp",
  shock = "gs",
  horizon = 8,
  relation = ">",
  value = 0.001,
  absolute = TRUE
)

material_response[, c("posterior_prob", "median_gap",
                       "lower_gap", "upper_gap")]
#> # A tibble: 1 × 4
#>   posterior_prob median_gap lower_gap upper_gap
#>            <dbl>      <dbl>     <dbl>     <dbl>
#> 1          0.595   0.000229 -0.000818   0.00201
```

Choose the threshold from the variable transformation and application,
not from the posterior output. For cumulative multiplier questions, set
`type = "cdm"` and review the scaling options in
[`magnitude_audit()`](https://davidzenz.github.io/bsvarPost/reference/magnitude_audit.md).

## Does an interval cover the whole path?

Ordinary credible intervals are pointwise. A 90% simultaneous band uses
one sup-norm critical value for the selected response path, giving the
stronger statement that 90% of draws lie inside the band over the
selection as a whole.

``` r

gdp_band <- simultaneous_irf(
  post,
  horizon = 12,
  probability = 0.90,
  variables = "gdp",
  shocks = "gs"
)

gdp_band[gdp_band$horizon %in% c(0, 4, 8, 12),
         c("horizon", "median", "lower", "upper", "simultaneous_prob")]
#> # A tibble: 4 × 5
#>   horizon     median    lower    upper simultaneous_prob
#>     <dbl>      <dbl>    <dbl>    <dbl>             <dbl>
#> 1       0 -0.0000935 -0.00219 0.00201                0.9
#> 2       4 -0.000702  -0.00280 0.00140                0.9
#> 3       8 -0.00119   -0.00329 0.000914               0.9
#> 4      12 -0.00158   -0.00368 0.000523               0.9
```

The band applies only to the variables, shocks, and horizons used to
construct it. Expanding that family generally widens the band. Use
[`simultaneous_cdm()`](https://davidzenz.github.io/bsvarPost/reference/simultaneous_cdm.md)
for cumulative responses and
[`plot_simultaneous()`](https://davidzenz.github.io/bsvarPost/reference/plot_simultaneous.md)
when the path is easier to assess graphically.

## Which single draw represents the posterior center?

A grid of pointwise medians need not be generated by any stored
parameter draw.
[`median_target_irf()`](https://davidzenz.github.io/bsvarPost/reference/median_target_irf.md)
instead selects the one draw closest to the median target over the
requested responses and horizons. Including both GDP and government
spending in the target keeps their displayed paths coherent with each
other.

``` r

representative <- median_target_irf(
  post, horizon = 12,
  variables = c("gdp", "gs"),
  shocks = "gs", horizons = 0:12
)

representative$draw_index
#> [1] 70

rep_path <- summary(representative)
subset(
  rep_path,
  variable == "gdp" & shock == "gs" & horizon %in% c(0, 4, 8, 12),
  select = c(horizon, median, draw_index, method))
#> # A tibble: 4 × 4
#>   horizon    median draw_index method       
#>     <dbl>     <dbl>      <int> <chr>        
#> 1       0 -0.000268         70 median_target
#> 2       4 -0.000827         70 median_target
#> 3       8 -0.00131          70 median_target
#> 4      12 -0.00172          70 median_target
```

Use this draw when a downstream calculation requires one internally
consistent structural model. Do not describe it as posterior
uncertainty: retain the full posterior and its intervals alongside it.
The same selection is available for
[CDMs](https://davidzenz.github.io/bsvarPost/reference/median_target_cdm.md);
sign-restricted models also have a distinct [most-likely admissible
draw](https://davidzenz.github.io/bsvarPost/reference/most_likely_admissible_irf.md).

## When does the response arrive and fade?

Response-shape summaries operate draw by draw before summarizing, so
uncertainty in timing is not inferred from one median curve. For an
interpretable persistence example, examine the government-spending
shock’s own response over 20 quarters.

``` r

peak <- peak_response(post, horizon = 20, variables = "gs", shocks = "gs",
                      absolute = TRUE)
duration <- duration_response(
  post, horizon = 20, variables = "gs", shocks = "gs",
  relation = ">", value = 0, mode = "consecutive")
half_life <- half_life_response(
  post, horizon = 20, variables = "gs", shocks = "gs", baseline = "peak")
threshold <- time_to_threshold(
  post, horizon = 20, variables = "gs", shocks = "gs",
  relation = "<", value = 0.015)

data.frame(
  question = c("absolute peak", "positive spell", "half-life", "below 0.015"),
  posterior_median = c(
    peak$median_horizon,
    duration$median_duration,
    half_life$median_half_life,
    threshold$median_horizon
  ),
  unit = c("horizon", "periods", "periods after peak", "horizon"),
  reached_prob = c(NA, NA, half_life$reached_prob, threshold$reached_prob)
)
#>         question posterior_median               unit reached_prob
#> 1  absolute peak                0            horizon           NA
#> 2 positive spell               21            periods           NA
#> 3      half-life               14 periods after peak        0.900
#> 4    below 0.015               11            horizon        0.975
```

`reached_prob` matters for half-life and threshold summaries: a
conditional median can look precise even when few draws reach the event
within the requested horizon.
[`peak_response()`](https://davidzenz.github.io/bsvarPost/reference/peak_response.md)
additionally reports the posterior distribution of the peak value. Use
the dedicated reference pages for alternative definitions:
[`duration_response()`](https://davidzenz.github.io/bsvarPost/reference/duration_response.md),
[`half_life_response()`](https://davidzenz.github.io/bsvarPost/reference/half_life_response.md),
and
[`time_to_threshold()`](https://davidzenz.github.io/bsvarPost/reference/time_to_threshold.md).

## Choose the statement that matches the question

- Use a `compare_*()` table to expose specification sensitivity.
- Use `hypothesis_*()` for one or more pointwise posterior
  probabilities.
- Use `joint_hypothesis_*()` when all selected inequalities must hold
  together.
- Use
  [`magnitude_audit()`](https://davidzenz.github.io/bsvarPost/reference/magnitude_audit.md)
  for a pre-specified economically relevant threshold.
- Use `simultaneous_*()` when coverage of an entire selected path is the
  claim.
- Use a median-target draw only when one coherent stored model is
  required.
- Use timing summaries for when, how long, and whether a response
  reaches an event—not as substitutes for the response distribution
  itself.

For sign-restricted posterior diagnostics and admissibility-based
representative draws, continue to [Sign-Restricted
Workflows](https://davidzenz.github.io/bsvarPost/articles/sign-restricted-workflows.md).
The [reference
index](https://davidzenz.github.io/bsvarPost/reference/index.html) lists
lower-level variants and plotting methods without repeating them here.
