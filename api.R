
### mrgsolve_models.R

# set up a model_cache
# on initialization, check if existing cache --> use
# if no cache, create a new cache

model_cache <- modcache::Cache$new(cache_dir = '.modcache', .gitignore = TRUE)

mod1 <- '
 <model code>
'

model_cache$add_model(mod1)

# model_file is relative to the mrgsolve_models.R like Rmd file knitting for
# relative paths
model_cache$add_model_file("some_model.cpp")

# call model_cache at the end so it is what is returned to source_models
model_cache

### end file

### in your_work.Rmd/.R
library(mrgsolve)
library(modcache)
models <- source_models("mrgsolve_models.R")

models$list()
# model names, cachetime

models$details() # show details for all models
models$details("ex1") # show details for specific model

# maybe should be models$get("ex1")
models$use("ex1") # give back model object

# force recompilation
models$force_recompile()
models$force_recompile("ex1")

# maybe some functional constructs, don't know how I feel about this vs extracting
# all models into a separate list model_list <- models$get_all() then using lapply or whatever
# to iterate over
models$apply_f(function(mod) {
    mod %>% allparam
})


