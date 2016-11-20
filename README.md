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

# define any inline text models
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


### Rmd (or other Rscript) files can now pull in all models to access

```r
models <- source("path/to/models.R")$value
# access models at any time with use
models$use("one_cmt_f") %>%
    ev(amt = 100, cmt = 1) %>% mrgsim %>% plot

one_cmt_f <- models$use("one_cmt_f")

one_cmt_f %>% ev(amt = 200, cmt = 1) %>% mrgsim %>% plot
```

For a super basic example, please see a [project example](https://github.com/dpastoor/example_overseer)