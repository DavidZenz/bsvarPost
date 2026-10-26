Demonstration data for bsvarPost
================================
Four posterior fits each contain 200 retained draws. They illustrate the API;
they do not establish sampling adequacy or identify a recommended research model.

fiscal_post_bsvar.rds: bsvars default identification, p=1, seed=123.
fiscal_post_bsvar_alt.rds: same input/identification, p=3, seed=456.
sign_post.rds: bsvarSIGNs optimism*100, p=4, seed=123.
sign_post_alt.rds: same input/restrictions, p=2, seed=456.
The sign restriction matrix is matrix(c(0, 1, rep(NA_real_, 23)), 5, 5).
All fits use S=200, thin=1 and the upstream default priors.

us_fiscal_lsuw.rds and optimism.rds are frozen upstream input snapshots.
Fiscal variables are quarterly log real per capita levels, unchanged.
Optimism is stored unchanged; multiply by 100 before fitting the sign models.
The snapshots originate in the GPL-licensed bsvars and bsvarSIGNs packages;
see their dataset documentation for original sources and transformations.
demo-metadata.csv records sample ranges, versions, seeds and checksums.
RDS files use serialization version 2 for minimum-R compatibility.

Load assets with readRDS(system.file("extdata", filename,
  package="bsvarPost", mustWork=TRUE)). See the introduction and sign-restricted
vignette for estimation recipes. In a source checkout, regenerate using
Rscript --vanilla tools/build-demo-fixtures.R; --refresh-inputs explicitly
updates snapshots to the installed upstream datasets. Re-estimation can differ
across upstream or R versions even with the same seed.
