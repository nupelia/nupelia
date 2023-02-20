#' @title citations_year
#' @description Get the citation history of a researcher from Google Scholar
#' @param id character string of the researcher's Google Scholar ID
#' @return a data frame with the citation history
#' @export
citations_year <- function(id) {

  fun_id <- function(id_prof = id) {

    table_citation_history <- scholar::get_citation_history(id_prof) %>%
      dplyr::mutate(id = id_prof) %>%
      dplyr::mutate(name = scholar::get_profile(id_prof)$name[1])

    cli::cli_alert_success(table_citation_history$name[1])
    cli::cli_alert_info("Waiting 1 second...")
    return(table_citation_history)
    Sys.sleep(1)

  }

  final_table <- purrr::map(id, fun_id, .progress = TRUE) %>%
    purrr::list_rbind() %>%
    dplyr::arrange(year) %>%
    tidyr::pivot_wider(
      names_from = year,
      values_from = cites
    ) %>%
    dplyr::arrange(name)

  return(final_table)
}



