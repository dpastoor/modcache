## overseer 0.0.4

* fix bugs from sourcing from files/directories when sourcing overseer from other locations

## overseer 0.0.3

* update internals to lazily load models added via file or directory, this will allow files to be easily
updated/recompiled after being added to an overseer
* changed `list_models()` to `available()`
