#' @title Get citations info
#'
#' @description Retrieve the total number of citations and h-index for a given Google Scholar ID.
#'
#' @param id A character vector with the Google Scholar ID
#'
#' @return A data frame with the ID, name, total citations and h-index
#'
#' @examples
#' ids <- c("GNJ8XGQAAAAJ","Wy6KhVIAAAAJ")
#'
#' citations_info(ids)
#'
#' @export
#'
citations_info <- function(id) {

  ids <- id
  # ids <- c("GNJ8XGQAAAAJ",
  #          "Wy6KhVIAAAAJ"
  # )

  get_profile_lazy <- function(id) {
    table_profile <- scholar::get_profile(id = id)
    cli::cli_alert_success(table_profile$name[1])
    cli::cli_alert_info("Waiting 1 second...")
    return(table_profile)
    Sys.sleep(1)
  }
  result_gscholar <- purrr::map(ids, get_profile_lazy)

  result_table <- data.frame(t(sapply(result_gscholar,c))) %>%
    dplyr::select(id, name, total_cites, h_index) %>%
    tidyr::unnest(cols = c(id, name, total_cites, h_index))

  return(result_table)

}
