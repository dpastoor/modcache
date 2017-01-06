library(mrgsolve)
library(overseer)
models <- Overseer$new()

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

# pull this model in if it doesn't exist on this computer
models$add_remote_model("https://raw.githubusercontent.com/dpastoor/example_overseer/master/models/one_cmt_f.cpp")

# pull in model saved as one_cmt_f.cpp and save with a different name
models$add_model_file("one_cmt_f", "othername")

# models$add_model_directory("tmpdir")

models$available()

models$add_remote_model("https://raw.githubusercontent.com/dpastoor/example_overseer/master/models/multiple_models/one_cmt_f2.cpp")

# access models at any time with use
library(dplyr)
models$use("one_cmt_f") %>%
    ev(amt = 100, cmt = 1) %>% mrgsim %>% plot

models$use("othername") %>%
    ev(amt = 100, cmt = 1) %>% mrgsim %>% plot
