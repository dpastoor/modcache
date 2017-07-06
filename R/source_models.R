#' source models from an overseer R script
#' @param .path path to R script containing overseer setup
#' @export
source_models <- function(.path) {
    # can eventually implement additional checks here if desired
    source(.path)$value
}