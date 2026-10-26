make_identity_irf <- function(value) {
  out <- array(value, c(1, 1, 2, 3),
               dimnames = list("y", "s", c("0", "1"), as.character(1:3)))
  class(out) <- c("PosteriorIR", "array")
  out
}

first <- make_identity_irf(1)
second <- make_identity_irf(10)
expect_error(compare_irf(list(same = first, same = second)), "unique")
comparison <- compare_irf(list(model2 = first, second))
expect_equal(unique(comparison$model), c("model2", "model3"))
expect_equal(comparison$mean, c(1, 1, 10, 10))
expect_equal(unique(compare_irf(first, second)$model), c("model1", "model2"))

draws <- tibble::tibble(model = c("a.b", "a"), object_type = "hd",
                       variable = c("c", "b.c"), shock = "s", time = "1",
                       draw = 1L, value = c(1, 100))
draws <- bsvarPost:::new_bsvar_post_tbl(draws, "hd", draws = TRUE)
event <- tidy_hd_event(draws, start = "1", draws = TRUE)
expect_equal(nrow(event), 2L)
expect_equal(event$value, c(1, 100))
expect_equal(event$model, c("a.b", "a"))

groups <- bsvarPost:::tuple_group(c("a\rb", "a"), c("c", "b\rc"))
expect_equal(nlevels(groups), 2L)
