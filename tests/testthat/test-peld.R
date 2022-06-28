test_that("peld_abund", {

  test_df <- data.frame(
    especie = rep(c("a","b","c"),5),
    lab = 1:15,
    lfe = 2:16,
    rio = 3:17
  )

  data_abund <- peld_abund_rel(test_df)

  expect_s3_class(data_abund, "tbl_df")
})

test_that("peld_riqueza", {

  test_df <- data.frame(
    especie = rep(c("a","b","c"),5),
    lab = 1:15,
    lfe = 2:16,
    rio = 3:17
  )

  data_riqueza <- peld_riqueza(test_df)

  expect_s3_class(data_riqueza, "tbl_df")
})

test_that("peld_shannon", {

  test_df <- data.frame(
    especie = rep(c("a","b","c"),5),
    lab = 1:15,
    lfe = 2:16,
    rio = 3:17
  )

  data_shannon <- peld_shannon(test_df)

  expect_s3_class(data_shannon, "tbl_df")
})

test_that("peld_equitabilidade", {

  test_df <- data.frame(
    especie = rep(c("a","b","c"),5),
    lab = 1:15,
    lfe = 2:16,
    rio = 3:17
  )

  data_equitabilidade <- peld_equitabilidade(test_df)

  expect_s3_class(data_equitabilidade, "tbl_df")
})
