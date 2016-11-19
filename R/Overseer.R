#' Model repository manager
#' @importFrom R6 R6Class
#' @name Overseer
#' @examples
#' \dontrun{
#' model_cache <- Overseer$new(".modcache") # relative path to where should cache files
#' model_cache$add_model("test")
#' }
NULL

#' @export
Overseer <- R6Class("Overseer",
                    public =
                        list(
                            initialize = function(
                                cache_name = ".modelcache",
                                relative_path = TRUE,
                                create_git_ignore = TRUE
                            ) {
                            if (relative_path) {
                                cache_folder <- cache_location(cache_name)
                                private$cache_location <<- cache_folder
                                message("cache location set to ", private$cache_location)
                                if (!dir.exists(cache_folder)) {
                                    dir.create(cache_folder, recursive = TRUE)
                                }
                            } else {
                                private$cache_location <<- getwd()
                            }
                            if (create_git_ignore) {
                                potential_gitignore <- file.path(private$cache_location, ".gitignore")
                                if(!file.exists(potential_gitignore)) {
                                  ## ignore everything in the model cache
                                    message("no .gitignore file detected, creating one for you...")
                                    writeLines("*", potential_gitignore)

                                }
                            }
                            },
                            add_model = function(model, model_name = NULL) {
                                if (is.null(model_name)) {
                                    model_name <- deparse(substitute(model))
                                }
                                private$models[[model_name]] <<- model
                            },
                            use = function(model_name) {

                            },
                            list_models = function(details = FALSE) {
                                names(private$models)
                            }
                        ),
                    private = list(
                        cache_location = NULL,
                        models = list()

                    )
)