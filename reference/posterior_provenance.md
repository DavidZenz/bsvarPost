# Provenance columns in posterior tables

Posterior tables retain the existing estimate and identifier columns and
add ordinary columns describing how the result was computed. These
columns are included in default reports and CSV exports; compact reports
omit most of them. Unknown or inapplicable values are typed `NA`.

## Columns

- `analysis_type`: response, hypothesis, joint hypothesis, simultaneous
  band, representative selection, response timing, or diagnostic
  analysis.

- `interval_probability` and `interval_method`: the mass and
  construction of intervals actually reported, `equal_tailed` or
  `empirical_sup_norm`.

- `scale_by`, `scale_var`, and `scale_factor`: response normalisation. A
  `shock_sd` response is divided by the reported sample standard
  deviation.

- `units`: known units such as FEVD percentages or response-timing
  periods; economic units are left unknown when they cannot be
  recovered.

- `source_package` and `source_version`: the upstream package used for
  the current computation. They do not reconstruct estimation software
  history.

- `n_draws`: number of posterior draws used for the result.

- `draw_id`: original draw labels in draw-level tables. The integer
  `draw` column retains positional indexing.

- `selected_draw_id`: original label of a representative draw;
  `draw_index` remains its positional index.

Existing `object_type`, `draws`, and `compare` attributes remain
supported. Legacy tables without provenance columns can still be plotted
when their analysis is unambiguous from the existing columns and
attributes.

## See also

[`tidy_irf()`](https://davidzenz.github.io/bsvarPost/reference/tidy_irf.md),
[`report_table()`](https://davidzenz.github.io/bsvarPost/reference/report_table.md),
[`write_bsvar_csv()`](https://davidzenz.github.io/bsvarPost/reference/write_bsvar_csv.md)
