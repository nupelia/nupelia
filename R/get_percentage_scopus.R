#' Get the Scopus percentage
#'
#' Get the Scopus percentage of a given journal.
#'
#' @param journal_id The ID of the journal.
#' @param journal_name The name of the journal.
#' @param year The year to get the percentage from.
#'
#' @return A tibble with the percentage of the journal in Scopus.
#'
#' @examples
#' get_percentage_scopus(journal_id = "5200153106", year = 2021)
#'
#' @export
#'
get_percentage_scopus <- function(journal_id = NULL, journal_name = NULL, year = 2021, best_rank = TRUE){

  if(is.null(journal_id)){

    journal_id <- tabela_scopus %>%
      dplyr::filter(journal %in% journal_name) %>%
      pull(id)

  }

  # if(is.null(journal_name)){
  #
  #   journal_name <- tabela_scopus %>%
  #     dplyr::filter(id %in% journal_id) %>%
  #     pull(journal)
  #
  # }

  url <- paste0("https://www.scopus.com/source/citescore/",journal_id,".uri")

  teste <- jsonlite::fromJSON(url)

  if(year == 2022){

    resultado <- tibble::as_tibble(teste$predictor$"2022"$percentiles) %>%
      dplyr::rename(category = "parent",
                    sub_category = "subName",
                    percentage = "subPercentage",
                    total_journals = "totalSourceCount") %>%
      dplyr::mutate(journal = journal_name,
                    qualis = dplyr::case_when(percentage )) %>%
      dplyr::select(journal, category, sub_category, percentage, rank, total_journals) %>%
      dplyr::arrange(desc(percentage))

  }else{
    resultado <- tibble::as_tibble(teste$yearInfo$"2021"$percentiles) %>%
      dplyr::rename(category = "parent",
                    sub_category = "subName",
                    percentage = "subPercentage",
                    total_journals = "totalSourceCount") %>%
      dplyr::mutate(journal = journal_name) %>%
      dplyr::select(journal, category, sub_category, percentage, rank, total_journals) %>%
      dplyr::arrange(desc(percentage))
  }

  if(best_rank == TRUE){
    resultado <- slice_head(resultado,n = 1)
  }

  return(resultado)

}
