#' PELD: Abrevia espécie
#'
#' @param dados Tabela de dados do PELD
#'
#' @importFrom dplyr %>%
#' @importFrom utils head
#'
#' @export

peld_abrevia_especie <- function(dados){

  dados2 <- dados %>%
    dplyr::mutate(especie_draft = dplyr::case_when(stringr::str_detect(especie, "sp.") == TRUE ~ especie,
                                            stringr::str_detect(especie, "sp.") == FALSE ~
                                              stringr::str_replace(especie, "\\w+", paste0(stringr::str_extract(especie, "\\w"),".")))) %>%
    dplyr::add_count(especie_draft, name = "rep") %>%
    dplyr::mutate(especie = ifelse(rep > 1,
                                   stringr::str_replace(especie, "\\w+", paste0(stringr::str_extract(especie, "\\w{3}"),".")),
                                   especie_draft)) %>%
    dplyr::select(-c(rep,especie_draft)) %>%
    dplyr::as_tibble()

  return(dados2)

}

#' PELD: Abundância relativa
#'
#' @param dados Tabela de dados do PELD
#' @param subsistema Subsistema indicado. Pode ser "geral", "lab", "lfe" ou "rio". "geral" por padrao.
#' @param top_n Número de espécies a serem consideradas antes de "Outros". 14 por padrao.
#' @param especie_var Nome da variável referente a "Espécie". "especie" por padrao.
#' @param lab_var Nome da variável referente a "Lagoas abertas". "lab" por padrao.
#' @param lfe_var Nome da variável referente a "Lagoas fechadas". "lfe" por padrao.
#' @param rio_var Nome da variável referente a "Rios". "rio" por padrao.
#'
#' @export
peld_abund_rel <- function(dados,
                           subsistema = "geral",
                           top_n = 14,
                           especie_var = especie,
                           lab_var = lab,
                           lfe_var = lfe,
                           rio_var = rio){

  especie <- substitute(especie_var)
  lab <- substitute(lab_var)
  lfe <- substitute(lfe_var)
  rio <- substitute(rio_var)

  dados2 <- dados %>%
    dplyr::rename(
      "especie" = especie,
      "lab" = lab,
      "lfe" = lfe,
      "rio" = rio
    )

  if(subsistema == "geral"){

    abund_rel <- dados %>%
      tidyr::pivot_longer(
        cols = c("lab", "lfe", "rio"),
        names_to = "subsistema",
        values_to = "n"
      ) %>%
      dplyr::select(especie, subsistema, n) %>%
      dplyr::group_by(especie) %>%
      dplyr::summarise(total_sp = sum(n, na.rm = TRUE)) %>%
      dplyr::mutate(total_geral = sum(total_sp, na.rm = TRUE)) %>%
      dplyr::arrange(-total_sp) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(rank = dplyr::row_number(),
                    rank = ifelse(rank > top_n, top_n+1, rank)) %>%
      dplyr::group_by(rank) %>%
      dplyr::mutate(total_sp = sum(total_sp),
                    abund_rel = total_sp/total_geral,
                    especie = ifelse(rank > top_n, "Outros", especie)) %>%
      head(top_n+1) %>%
      dplyr::ungroup()

  }else{
    var <- subsistema

    abund_rel <- dados2 %>%
      tidyr::pivot_longer(
        cols = var,
        names_to = "subsistema",
        values_to = "total_sp"
      ) %>%
      dplyr::select(especie, subsistema, total_sp) %>%
      dplyr::mutate(total_geral = sum(total_sp, na.rm = TRUE)) %>%
      dplyr::group_by(especie) %>%
      dplyr::mutate(total_sp = sum(total_sp, na.rm = TRUE)) %>%
      dplyr::arrange(-total_sp) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(rank = dplyr::row_number(),
                    rank = ifelse(rank > top_n, top_n+1,rank)) %>%
      dplyr::group_by(rank) %>%
      dplyr::mutate(total_sp = sum(total_sp),
                    abund_rel = total_sp/total_geral,
                    especie = ifelse(rank > top_n, "Outros", especie)) %>%
      head(top_n+1) %>%
      dplyr::ungroup()
  }

  return(abund_rel)

}

#' PELD: Riqueza
#'
#' @param dados Tabela de dados do PELD
#' @param subsistema Subsistema indicado. Pode ser "geral", "lab", "lfe" ou "rio". "geral" por padrao.
#' @param especie_var Nome da variável referente a "Espécie". "especie" por padrao.
#' @param lab_var Nome da variável referente a "Lagoas abertas". "lab" por padrao.
#' @param lfe_var Nome da variável referente a "Lagoas fechadas". "lfe" por padrao.
#' @param rio_var Nome da variável referente a "Rios". "rio" por padrao.
#'
#' @export
peld_riqueza <- function(dados,
                         subsistema = "geral",
                         especie_var = especie,
                         lab_var = lab,
                         lfe_var = lfe,
                         rio_var = rio){

  especie <- substitute(especie_var)
  lab <- substitute(lab_var)
  lfe <- substitute(lfe_var)
  rio <- substitute(rio_var)

  dados2 <- dados %>%
    dplyr::rename(
      "especie" = especie,
      "lab" = lab,
      "lfe" = lfe,
      "rio" = rio
    )

  if(subsistema == "geral"){
    var <- c("lab", "lfe", "rio")
  }else{
    var <- subsistema
  }

  riqueza <- dados2 %>%
    tidyr::pivot_longer(
      cols = var,
      names_to = "subsistema",
      values_to = "n"
    ) %>%
    dplyr::mutate(n = !is.na(n)) %>%
    dplyr::group_by(subsistema) %>%
    dplyr::summarise(riqueza = sum(n==TRUE))

  return(riqueza)

}

#' PELD: Diversidade de Shannon (H')
#'
#' @param dados Tabela de dados do PELD
#' @param subsistema Subsistema indicado. Pode ser "geral", "lab", "lfe" ou "rio". "geral" por padrao.
#' @param especie_var Nome da variável referente a "Espécie". "especie" por padrao.
#' @param lab_var Nome da variável referente a "Lagoas abertas". "lab" por padrao.
#' @param lfe_var Nome da variável referente a "Lagoas fechadas". "lfe" por padrao.
#' @param rio_var Nome da variável referente a "Rios". "rio" por padrao.
#'
#' @export
peld_shannon <- function(dados,
                         subsistema = "geral",
                         especie_var = especie,
                         lab_var = lab,
                         lfe_var = lfe,
                         rio_var = rio){

  especie <- substitute(especie_var)
  lab <- substitute(lab_var)
  lfe <- substitute(lfe_var)
  rio <- substitute(rio_var)

  dados2 <- dados %>%
    dplyr::rename(
      "especie" = especie,
      "lab" = lab,
      "lfe" = lfe,
      "rio" = rio
    )

  if(subsistema == "geral"){
    var <- c("lab", "lfe", "rio")
  }else{
    var <- subsistema
  }

  shannon <- dados2 %>%
    tidyr::pivot_longer(
      cols = var,
      names_to = "subsistema",
      values_to = "n"
    ) %>%
    dplyr::group_by(subsistema) %>%
    tidyr::drop_na(n) %>%
    dplyr::summarise(shannon = vegan::diversity(n, index = "shannon"))

  return(shannon)

}


#' PELD: Equitabilidade de Pielou (J)
#'
#' @param dados Tabela de dados do PELD
#' @param subsistema Subsistema indicado. Pode ser "geral", "lab", "lfe" ou "rio". "geral" por padrao.
#' @param especie_var Nome da variável referente a "Espécie". "especie" por padrao.
#' @param lab_var Nome da variável referente a "Lagoas abertas". "lab" por padrao.
#' @param lfe_var Nome da variável referente a "Lagoas fechadas". "lfe" por padrao.
#' @param rio_var Nome da variável referente a "Rios". "rio" por padrao.
#'
#' @export
peld_equitabilidade <- function(dados,
                                subsistema = "geral",
                                especie_var = especie,
                                lab_var = lab,
                                lfe_var = lfe,
                                rio_var = rio){

  especie <- substitute(especie_var)
  lab <- substitute(lab_var)
  lfe <- substitute(lfe_var)
  rio <- substitute(rio_var)

  dados2 <- dados %>%
    dplyr::rename(
      "especie" = especie,
      "lab" = lab,
      "lfe" = lfe,
      "rio" = rio
    )

  if(subsistema == "geral"){
    var <- c("lab", "lfe", "rio")
  }else{
    var <- subsistema
  }

  equit <- dados2 %>%
    tidyr::pivot_longer(
      cols = var,
      names_to = "subsistema",
      values_to = "n"
    ) %>%
    dplyr::group_by(subsistema) %>%
    tidyr::drop_na(n) %>%
    dplyr::summarise(equit = vegan::diversity(n, index = "shannon")/log(sum(n, na.rm = TRUE))
    )

  return(equit)

}
