#' Model repository manager
#' @importFrom R6 R6Class
#' @importFrom mrgsolve mcode_cache mread_cache
#' @name Overseer
#' @examples
#' \dontrun{
#' model_cache <- Overseer$new(".modcache") # folder name for the cache files
#' model_cache$add_model("test")
#' }
NULL

#' @export
Overseer <- R6Class("Overseer",
                    public =
                        list(
                            initialize = function(
                                cache_name = ".modelcache",
                                dir = NULL, # where model files should be stored
                                create_git_ignore = TRUE
                            ) {
                            if (is.null(dir)) {
                                ## cache folder set to same directory as the sourced script
                                cache_folder <- cache_location(cache_name)
                                private$cache_location <<- cache_folder
                                private$dir <<- dirname(cache_folder)
                                message("model dir set to ", private$dir)
                                message("cache location set to ", private$cache_location)
                                if (!dir.exists(cache_folder)) {
                                    dir.create(cache_folder, recursive = TRUE)
                                }
                            } else {
                                # if they are 'manually' setting a modeling dir, make sure it exists
                                if (!dir.exists(dir)) {
                                    stop(
                                        paste(
                                            "no directory detected at: ",
                                            dir,
                                            "please correct the path or create the folder"
                                        )
                                    )
                                }
                                dir_and_cache <- normalizePath(file.path(dir, cache_name))
                                if (!dir.exists(dir_and_cache)) {
                                    dir.create(dir_and_cache, recursive = TRUE)
                                }
                                private$cache_location <<- dir_and_cache
                                message("model dir set to ", private$dir)
                                message("cache location set to ", private$cache_location)
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
                                private$models[[model_name]] <<- mcode_cache(model_name, model, private$cache_location)
                            },
                            add_model_file = function(file, model_name = NULL) {
                                if (is.null(model_name)) {
                                    model_name <- basename(file)
                                }
                                private$models[[model_name]] <<- mread_cache(model_name,
                                                                             private$dir,
                                                                             soloc = private$cache_location)
                            },
                            use = function(model_name) {
                                if (is.numeric(model_name)) {
                                    warning("be careful referencing models by index as changes could result in suble bugs,
                                            suggest referring to models by name")
                                }
                                return(private$models[[model_name]])
                            },
                            list_models = function(details = FALSE) {
                                names(private$models)
                            }
                        ),
                    private = list(
                        dir = NULL,
                        cache_location = NULL,
                        models = list()

                    )
)