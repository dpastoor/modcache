#' check model existance during interactive use to protect against improperly
#' set paths
#' @param .model modelfile name in directory of file where overseer is set
#' @export
#' @examples \dontrun{
#' # given a model my_model.cpp
#' if (!interactive_model_check("my_model.cpp")) {
#'   stop("make sure the directory is set to the models directory before running
#'   interactively to make sure the relative paths will be the same as when sourcing")
#' }
#' }
interactive_model_check <- function(.model) {
if (is.null(thisfile())) {
    #probably sourcing from this directory directly
    if (file.exists(.model)) {
        return(TRUE)
    }
    return(FALSE)
}
    # defaults to true so in non-interactive settings will pass over this
    return(TRUE)
}
