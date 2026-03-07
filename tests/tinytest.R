if (!requireNamespace("tinytest", quietly = TRUE)) {
  quit(save = "no", status = 0)
}

library(tinytest)
tinytest::test_package("bsvarPost")
