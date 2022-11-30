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
#' @param ambiente Ambiente indicado. Pode ser "geral", "lab", "lfe" ou "rio". "geral" por padrao.
#' @param porcentagem_corte A porcentagem da abundância relativa utilizada como corte para espécies. Espécies com porcentagem menor serão agrupadas em "Outros". 2 por padrão.
#' @param especie_var Nome da variável referente a "Espécie". "especie" por padrao.
#' @param lab_var Nome da variável referente a "Lagoas abertas". "lab" por padrao.
#' @param lfe_var Nome da variável referente a "Lagoas fechadas". "lfe" por padrao.
#' @param rio_var Nome da variável referente a "Rios". "rio" por padrao.
#'
#' @export
peld_abund_rel <- function(dados,
                           ambiente = "geral",
                           porcentagem_corte = 2,
                           especie_var = "especie",
                           lab_var = "lab",
                           lfe_var = "lfe",
                           rio_var = "rio"){

  if(ambiente == "geral"){

    abund_rel <- dados %>%
      tidyr::pivot_longer(
        cols = c({{lab_var}}, {{lfe_var}}, {{rio_var}}),
        names_to = "ambiente",
        values_to = "n"
      ) %>%
      dplyr::select(especie, ambiente, n) %>%
      dplyr::group_by(especie) %>%
      dplyr::summarise(total_sp = sum(n, na.rm = TRUE)) %>%
      dplyr::mutate(total_geral = sum(total_sp, na.rm = TRUE)) %>%
      dplyr::arrange(-total_sp) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(abund_rel_porcentagem = ((total_sp/total_geral)*100),
                    especie = ifelse(abund_rel_porcentagem < porcentagem_corte,
                                     "Outros",
                                     especie)) %>%
      dplyr::group_by(especie) %>%
      dplyr::mutate(total_sp = sum(total_sp),
                    abund_rel_porcentagem = round(((total_sp/total_geral)*100),2)) %>%
      dplyr::ungroup() %>%
      dplyr::distinct()

  }else{

    if(ambiente == "lab"){
      var <- {{lab_var}}
    }
    if(ambiente == "lfe"){
      var <- {{lab_lfe}}
    }
    if(ambiente == "rio"){
      var <- {{lab_rio}}
    }

    abund_rel <- dados %>%
      tidyr::pivot_longer(
        cols = var,
        names_to = "ambiente",
        values_to = "total_sp"
      ) %>%
      dplyr::select(especie, ambiente, total_sp) %>%
      dplyr::mutate(total_geral = sum(total_sp, na.rm = TRUE)) %>%
      dplyr::group_by(especie) %>%
      dplyr::mutate(total_sp = sum(total_sp, na.rm = TRUE)) %>%
      dplyr::arrange(-total_sp) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(abund_rel_porcentagem = ((total_sp/total_geral)*100),
                    especie = ifelse(abund_rel_porcentagem < porcentagem_corte,
                                     "Outros",
                                     especie)) %>%
      dplyr::group_by(especie) %>%
      dplyr::mutate(total_sp = sum(total_sp),
                    abund_rel_porcentagem = round(((total_sp/total_geral)*100),2)) %>%
      dplyr::ungroup() %>%
      dplyr::distinct()
  }

  return(abund_rel)

}

#' PELD: Riqueza
#'
#' @param dados Tabela de dados do PELD
#' @param ambiente Ambiente indicado. Pode ser "geral", "lab", "lfe" ou "rio". "geral" por padrao.
#' @param especie_var Nome da variável referente a "Espécie". "especie" por padrao.
#' @param lab_var Nome da variável referente a "Lagoas abertas". "lab" por padrao.
#' @param lfe_var Nome da variável referente a "Lagoas fechadas". "lfe" por padrao.
#' @param rio_var Nome da variável referente a "Rios". "rio" por padrao.
#'
#' @export
peld_riqueza <- function(dados,
                         ambiente = "geral",
                         especie_var = "especie",
                         lab_var = "lab",
                         lfe_var = "lfe",
                         rio_var = "rio"){

  if(ambiente == "geral"){
    var <- c({{lab_var}}, {{lfe_var}}, {{rio_var}})
  }else{
    if(ambiente == "lab"){
      var <- {{lab_var}}
    }
    if(ambiente == "lfe"){
      var <- {{lab_lfe}}
    }
    if(ambiente == "rio"){
      var <- {{lab_rio}}
    }
  }

  riqueza <- dados %>%
    tidyr::pivot_longer(
      cols = var,
      names_to = "ambiente",
      values_to = "n"
    ) %>%
    dplyr::mutate(n = !is.na(n)) %>%
    dplyr::group_by(ambiente) %>%
    dplyr::summarise(riqueza = sum(n==TRUE))

  return(riqueza)

}

#' PELD: Diversidade de Shannon (H')
#'
#' @param dados Tabela de dados do PELD
#' @param ambiente Ambiente indicado. Pode ser "geral", "lab", "lfe" ou "rio". "geral" por padrao.
#' @param especie_var Nome da variável referente a "Espécie". "especie" por padrao.
#' @param lab_var Nome da variável referente a "Lagoas abertas". "lab" por padrao.
#' @param lfe_var Nome da variável referente a "Lagoas fechadas". "lfe" por padrao.
#' @param rio_var Nome da variável referente a "Rios". "rio" por padrao.
#'
#' @export
peld_shannon <- function(dados,
                         ambiente = "geral",
                         especie_var = especie,
                         lab_var = lab,
                         lfe_var = lfe,
                         rio_var = rio){

  if(ambiente == "geral"){
    var <- c({{lab_var}}, {{lfe_var}}, {{rio_var}})
  }else{
    if(ambiente == "lab"){
      var <- {{lab_var}}
    }
    if(ambiente == "lfe"){
      var <- {{lab_lfe}}
    }
    if(ambiente == "rio"){
      var <- {{lab_rio}}
    }
  }

  shannon <- dados %>%
    tidyr::pivot_longer(
      cols = var,
      names_to = "ambiente",
      values_to = "n"
    ) %>%
    dplyr::group_by(ambiente) %>%
    tidyr::drop_na(n) %>%
    dplyr::summarise(shannon = vegan::diversity(n, index = "shannon"))

  return(shannon)

}


#' PELD: Equitabilidade de Pielou (J)
#'
#' @param dados Tabela de dados do PELD
#' @param ambiente Ambiente indicado. Pode ser "geral", "lab", "lfe" ou "rio". "geral" por padrao.
#' @param especie_var Nome da variável referente a "Espécie". "especie" por padrao.
#' @param lab_var Nome da variável referente a "Lagoas abertas". "lab" por padrao.
#' @param lfe_var Nome da variável referente a "Lagoas fechadas". "lfe" por padrao.
#' @param rio_var Nome da variável referente a "Rios". "rio" por padrao.
#'
#' @export
peld_equitabilidade <- function(dados,
                                ambiente = "geral",
                                especie_var = especie,
                                lab_var = lab,
                                lfe_var = lfe,
                                rio_var = rio){

  if(ambiente == "geral"){
    var <- c({{lab_var}}, {{lfe_var}}, {{rio_var}})
  }else{
    if(ambiente == "lab"){
      var <- {{lab_var}}
    }
    if(ambiente == "lfe"){
      var <- {{lab_lfe}}
    }
    if(ambiente == "rio"){
      var <- {{lab_rio}}
    }
  }

  equit <- dados %>%
    tidyr::pivot_longer(
      cols = var,
      names_to = "ambiente",
      values_to = "n"
    ) %>%
    dplyr::group_by(ambiente) %>%
    tidyr::drop_na(n) %>%
    dplyr::summarise(equit = vegan::diversity(n, index = "shannon")/log(sum(n, na.rm = TRUE))
    )

  return(equit)

}

#' PELD: Abundância relativa por subsistema
#'
#' @param dados Tabela de dados do PELD
#' @param subsistema Subsistema indicado. Pode ser "ivinhema", "baia" ou "parana". "geral" por padrao.
#' @param porcentagem_corte A porcentagem da abundância relativa utilizada como corte para espécies. Espécies com porcentagem menor serão agrupadas em "Outros". 2 por padrão.
#' @param especie_var Nome da variável referente a "Espécie". "especie" por padrao.
#' @param ivinhema_var Nome da variável referente a "ivinhema". "ivinhema" por padrao.
#' @param baia_var Nome da variável referente a "baia". "baia" por padrao.
#' @param parana_var Nome da variável referente a "parana". "parana" por padrao.
#'
#' @export
peld_abund_rel_subsistema <- function(dados,
                                      subsistema = "geral",
                                      porcentagem_corte = 2,
                                      especie_var = "especie",
                                      ivinhema_var = "ivi",
                                      baia_var = "bai",
                                      parana_var = "par"){

  if(subsistema == "geral"){

    abund_rel <- dados %>%
      tidyr::pivot_longer(
        cols = c({{ivinhema_var}}, {{baia_var}}, {{parana_var}}),
        names_to = "subsistema",
        values_to = "n"
      ) %>%
      dplyr::select(especie, subsistema, n) %>%
      dplyr::group_by(especie) %>%
      dplyr::summarise(total_sp = sum(n, na.rm = TRUE)) %>%
      dplyr::mutate(total_geral = sum(total_sp, na.rm = TRUE)) %>%
      dplyr::arrange(-total_sp) %>%
      dplyr::ungroup() %>%
      dplyr::mutate(abund_rel_porcentagem = ((total_sp/total_geral)*100),
                    especie = ifelse(abund_rel_porcentagem < porcentagem_corte,
                                     "Outros",
                                     especie)) %>%
      dplyr::group_by(especie) %>%
      dplyr::add_count(name = "n_outros") %>%
      dplyr::mutate(total_sp = sum(total_sp),
                    abund_rel_porcentagem = round(((total_sp/total_geral)*100),2)) %>%
      dplyr::ungroup() %>%
      dplyr::distinct()

  }else{

    if(subsistema == "ivinhema"){
      var <- {{ivinhema_var}}
    }
    if(subsistema == "baia"){
      var <- {{baia_var}}
    }
    if(subsistema == "parana"){
      var <- {{parana_var}}
    }

    abund_rel <- dados %>%
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
      dplyr::mutate(abund_rel_porcentagem = ((total_sp/total_geral)*100),
                    especie = ifelse(abund_rel_porcentagem < porcentagem_corte,
                                     "Outros",
                                     especie)) %>%
      dplyr::group_by(especie) %>%
      dplyr::add_count(name = "n_outros") %>%
      dplyr::mutate(total_sp = sum(total_sp),
                    abund_rel_porcentagem = round(((total_sp/total_geral)*100),2)) %>%
      dplyr::ungroup() %>%
      dplyr::distinct()
  }

  return(abund_rel)

}

#' PELD: Riqueza por subsistema
#'
#' @param dados Tabela de dados do PELD
#' @param subsistema Subsistema indicado. Pode ser "ivinhema", "baia" ou "parana". "geral" por padrao.
#' @param especie_var Nome da variável referente a "Espécie". "especie" por padrao.
#' @param ivinhema_var Nome da variável referente a "ivinhema". "ivinhema" por padrao.
#' @param baia_var Nome da variável referente a "baia". "baia" por padrao.
#' @param parana_var Nome da variável referente a "parana". "parana" por padrao.
#'
#' @export
peld_riqueza_subsistema <- function(dados,
                                    subsistema = "geral",
                                    especie_var = "especie",
                                    ivinhema_var = "ivi",
                                    baia_var = "bai",
                                    parana_var = "par"){



  if(subsistema == "geral"){
    var <- c({{ivinhema_var}}, {{baia_var}}, {{parana_var}})
  }
  if(subsistema == "ivinhema"){
    var <- {{ivinhema_var}}
  }
  if(subsistema == "baia"){
    var <- {{baia_var}}
  }
  if(subsistema == "parana"){
    var <- {{parana_var}}
  }


  riqueza <- dados %>%
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

#' PELD: Diversidade de Shannon (H') por subsistema
#'
#' @param dados Tabela de dados do PELD
#' @param subsistema Subsistema indicado. Pode ser "ivinhema", "baia" ou "parana". "geral" por padrao.
#' @param especie_var Nome da variável referente a "Espécie". "especie" por padrao.
#' @param ivinhema_var Nome da variável referente a "ivinhema". "ivinhema" por padrao.
#' @param baia_var Nome da variável referente a "baia". "baia" por padrao.
#' @param parana_var Nome da variável referente a "parana". "parana" por padrao.
#'
#' @export
peld_shannon_subsistema <- function(dados,
                         subsistema = "geral",
                         especie_var = "especie",
                         ivinhema_var = "ivi",
                         baia_var = "bai",
                         parana_var = "par"){



  if(subsistema == "geral"){
    var <- c({{ivinhema_var}}, {{baia_var}}, {{parana_var}})
  }
  if(subsistema == "ivinhema"){
    var <- {{ivinhema_var}}
  }
  if(subsistema == "baia"){
    var <- {{baia_var}}
  }
  if(subsistema == "parana"){
    var <- {{parana_var}}
  }

  shannon <- dados %>%
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


#' PELD: Equitabilidade de Pielou (J) por subsistema
#'
#' @param dados Tabela de dados do PELD
#' @param subsistema Subsistema indicado. Pode ser "ivinhema", "baia" ou "parana". "geral" por padrao.
#' @param especie_var Nome da variável referente a "Espécie". "especie" por padrao.
#' @param ivinhema_var Nome da variável referente a "ivinhema". "ivinhema" por padrao.
#' @param baia_var Nome da variável referente a "baia". "baia" por padrao.
#' @param parana_var Nome da variável referente a "parana". "parana" por padrao.
#'
#' @export
peld_equitabilidade_subsistema <- function(dados,
                                subsistema = "geral",
                                especie_var = "especie",
                                ivinhema_var = "ivi",
                                baia_var = "bai",
                                parana_var = "par"){



  if(subsistema == "geral"){
    var <- c({{ivinhema_var}}, {{baia_var}}, {{parana_var}})
  }
  if(subsistema == "ivinhema"){
    var <- {{ivinhema_var}}
  }
  if(subsistema == "baia"){
    var <- {{baia_var}}
  }
  if(subsistema == "parana"){
    var <- {{parana_var}}
  }

  equit <- dados %>%
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

