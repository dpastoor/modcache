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
                            verbose = NULL,
                            initialize = function(
                                cache_name = ".modelcache",
                                dir = NULL, # where model files should be stored
                                create_git_ignore = TRUE,
                                verbose = TRUE
                            ) {
                                self$verbose <<- verbose
                            if (is.null(dir)) {
                                ## cache folder set to same directory as the sourced script
                                cache_folder <- cache_location(cache_name)
                                private$cache_location <<- cache_folder
                                ## also save dir that the cache is saved to
                                ## which should be the directory the Overseer class is being sourced from
                                private$dir <<- dirname(cache_folder)
                                if (self$verbose) {
                                    message("model dir set to ", private$dir)
                                    message("cache location set to ", private$cache_location)
                                }
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
                                private$models[[model_name]] <<- list(
                                    "model" = mcode_cache(model_name, model, private$cache_location),
                                    "model_path" = NULL
                                )
                            },
                            add_model_file = function(.filepath, model_name = NULL) {
                                if (is.null(model_name)) {
                                    model_name <- strip_ext(basename(.filepath))
                                }
                                # may or may not provide extension, want to flexibly pick it up
                                # so will strip the .cpp if it was there, then add it back in
                                # for example:
                                # Theoph --> Theoph.cpp
                                # Theoph.cpp --> Theoph.cpp
                                model_path <- normalizePath(paste0(file.path(private$dir,
                                                                             strip_ext(.filepath)), ".cpp"))
                                if(!file.exists(model_path)) {
                                    stop(paste0("model file not detected at: ", .filepath))
                                }
                                # keep as list so open to save more information later,
                                # details of model add time other otherwise
                                private$models[[model_name]] <<- list(
                                    "model_path" = model_path,
                                    "model" = NULL
                                )
                            },
                            add_model_directory = function(.dir = ".", pattern = "*.cpp") {
                                cpp_files <- strip_ext(dir(.dir, pattern = pattern))
                                project_dir <- normalizePath(file.path(private$dir, .dir))
                                for (i in seq_along(cpp_files)) {
                                    .file <- cpp_files[i]
                                    if (self$verbose) {
                                        message('adding model ', .file)
                                    }
                                    self$add_model_file(file.path(.dir, .file))
                                }
                            },
                            add_remote_model = function(.url, model_name = NULL) {
                                if(is.null(model_name)) {
                                    model_name <- strip_ext(basename(.url))
                                }
                                output_file <- file.path(private$dir, paste0(model_name, ".cpp"))
                                if (!file.exists(output_file)) {
                                    message('fetching file from ', .url)
                                    model_from_url <- httr::GET(.url)
                                    write(rawToChar(model_from_url$content), file = output_file)
                                }
                                self$add_model_file(basename(output_file), model_name)

                            },
                            use = function(model_name) {
                                if (is.numeric(model_name)) {
                                    warning("be careful referencing models by index as changes could result in subtle bugs,
                                            suggest referring to models by name")
                                }
                                model_details <- private$models[[model_name]]
                                if (is.null(model_details$model_path)) {
                                    # covers models added from add_model()
                                    # should already be cached from mcode_cache
                                    return(model_details$model)
                                }
                                if (!file.exists(model_details$model_path)) {
                                    stop(paste0("model file not detected at: ", model_details$model_path))
                                }
                                model_name <- strip_ext(basename(model_details$model_path))
                                model_dir <- dirname(model_details$model_path)
                                model <- mread_cache(model_name,
                                                     model_dir,
                                                     soloc = private$cache_location
                                                     )
                                return(model)
                            },
                            available = function(details = FALSE) {
                                names(private$models)
                            }
                        ),
                    private = list(
                        dir = NULL,
                        cache_location = NULL,
                        models = list()

                    )
)