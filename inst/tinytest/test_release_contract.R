source("tools/release-qa.R", local = TRUE)

expect_true(
  isTRUE(release_qa_check(".")),
  info = "release QA: exports, docs, tests, and S3 registrations stay in sync."
)
