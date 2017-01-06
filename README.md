overseer
============

overseer is a package to watch over your models and help you manage them.

## Why use overseer?

* to have a unified api for dealing with many models across project(s) and from different sources. Currently support:
    * inline code
    * cpp files
    * remote sources like github repositories (anything where an http request can be made to acquire the resource)
* to handle the frustrating details of managing models/caches transparently
    * creation and maintenance of a cache (folder)
    * automatically sets up a gitignore in the cache folder to ignore cached files
    * handles directory and operating system normalization for paths and files
    
## Example

### R file to manage all models - models.R

Example file, called models.R but can be named anything. The most important thing
is *the Overseer instance needs to be the last thing called on the last line*, so that it
can be imported in by `source`ing the rscript.


```r
library(overseer)

# create a new Overseer instance
models <- Overseer$new()

# define any inline text models, though this is NOT the suggested method
mod_simple <- '
$PARAM CL= 1.2, V=14.3
$CMT CENT
$PKMODEL ncmt = 1
$MAIN
$TABLE double DV = CENT/V;
$CAPTURE DV
'


# save inlined model
models$add_model(mod_simple)

# pull in model saved as one_cmt_f.cpp in the same directory
models$add_model_file("one_cmt_f")

# last line should be 'returning' the models object as that can be
# sourced from other files
models
```

### Checking models

One can see which models are available via the `available()` method

```r
models$available()
```

will print all models by name that can be invoked via `use()`

### Rmd (or other Rscript) files can now pull in all models to access

```r
models <- source("path/to/models.R")$value
# access models at any time with use
# load directly (not recommended as will compile each time!)
models$use("one_cmt_f") %>%
    ev(amt = 100, cmt = 1) %>% mrgsim %>% plot

# better to save to an object then use that object
one_cmt_f <- models$use("one_cmt_f")

one_cmt_f %>% ev(amt = 200, cmt = 1) %>% mrgsim %>% plot
```

For a super basic example, please see a [project example](https://github.com/dpastoor/example_overseer)

### Additional tips for sourcing files

Overseer sources models similar to how Rmarkdown files are knit - namely, when running
chunks interactively (in for example, models.R), the code will act on the current
working directory; however, when sourcing the models.R into other files, the Overseer
initialization will source files relative to the file itself. This (potential) difference
can cause some confusion. One way to protect yourself from accidentally running into that
issue is a basic check function provided called `interactive_model_check`. This can
be used at the top of the `models.R` file to halt progression in interactive
contexts if a given file is not in the same directory, aka the directory is not
normalized to what it will be when sourcing from elsewhere.

For example, given we have a model called `vanco_stockmann.cpp` in the models folder
at the same level as models.R where the overseer is created:

```
library(overseer)

if (!interactive_model_check("vanco_stockmann.cpp")) {
    stop("make sure the directory is set to the models directory before running interactively,
         to make sure the relative paths will be the same as when sourcing")
}

models <- Overseer$new()

models$add_model_file("vanc_stockmann")
```

The interactive call will make sure this is only run when the code is executed
directly, and will make sure that it is at the proper directory location by checking
for the direct existance for that file, and if it doesn't exist, likely due to an
incorrect working directory, it will stop the code execution before initializing
the Overseer instance.