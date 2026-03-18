source(system.file("tinytest/helpers-release-qa.R", package = "bsvarPost"), local = TRUE)

expect_true(
  isTRUE(installed_release_qa_check("bsvarPost")),
  info = "release QA: installed exports and S3 registrations stay in sync."
)
