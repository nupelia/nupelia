test_that("peld_abrevia_especie", {

  test_df <- data.frame(
    especie = c("Acestrorhynchus lacustris",
                "Aequidens plagiozonatus",
                "Ageneiosus inermis",
                "Ageneiosus ucayalensis",
                "Astyanax lacustris"),
    lab = 1:5,
    lfe = 2:6,
    rio = 3:7
  )

  data_abrevia <- peld_abrevia_especie(test_df)

  expect_s3_class(data_abrevia, "tbl_df")
  expect_true(nrow(data_abrevia) == 5)
})

test_that("peld_abund_geral", {

  test_df <- data.frame(
    especie = rep(c("a","b","c"),5),
    lab = 1:15,
    lfe = 2:16,
    rio = 3:17
  )

  data_abund_geral <- peld_abund_rel(test_df)

  expect_s3_class(data_abund_geral, "tbl_df")
})

test_that("peld_abund_lab", {

  test_df <- data.frame(
    especie = rep(c("a","b","c"),5),
    lab = 1:15,
    lfe = 2:16,
    rio = 3:17
  )

  data_abund_lab <- peld_abund_rel(test_df, subsistema = "lab")

  expect_s3_class(data_abund_lab, "tbl_df")
})

test_that("peld_riqueza_geral", {

  test_df <- data.frame(
    especie = rep(c("a","b","c"),5),
    lab = 1:15,
    lfe = 2:16,
    rio = 3:17
  )

  data_riqueza_geral <- peld_riqueza(test_df)

  expect_s3_class(data_riqueza_geral, "tbl_df")
})

test_that("peld_riqueza_lab", {

  test_df <- data.frame(
    especie = rep(c("a","b","c"),5),
    lab = 1:15,
    lfe = 2:16,
    rio = 3:17
  )

  data_riqueza_lab <- peld_riqueza(test_df,ambiente = "lab")

  expect_s3_class(data_riqueza_lab, "tbl_df")
})

test_that("peld_shannon_geral", {

  test_df <- data.frame(
    especie = rep(c("a","b","c"),5),
    lab = 1:15,
    lfe = 2:16,
    rio = 3:17
  )

  data_shannon_geral <- peld_shannon(test_df)

  expect_s3_class(data_shannon_geral, "tbl_df")
})

test_that("peld_shannon_lab", {

  test_df <- data.frame(
    especie = rep(c("a","b","c"),5),
    lab = 1:15,
    lfe = 2:16,
    rio = 3:17
  )

  data_shannon_lab <- peld_shannon(test_df, ambiente = "lab")

  expect_s3_class(data_shannon_lab, "tbl_df")
})

test_that("peld_equitabilidade_geral", {

  test_df <- data.frame(
    especie = rep(c("a","b","c"),5),
    lab = 1:15,
    lfe = 2:16,
    rio = 3:17
  )

  data_equitabilidade_geral <- peld_equitabilidade(test_df)

  expect_s3_class(data_equitabilidade_geral, "tbl_df")
})

test_that("peld_equitabilidade_lab", {

  test_df <- data.frame(
    especie = rep(c("a","b","c"),5),
    lab = 1:15,
    lfe = 2:16,
    rio = 3:17
  )

  data_equitabilidade_lab <- peld_equitabilidade(test_df,ambiente = "lab")

  expect_s3_class(data_equitabilidade_lab, "tbl_df")
})
