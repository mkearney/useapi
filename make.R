api <- readr::read_lines("data-raw/api.R")
utils <- readr::read_lines("data-raw/utils.R")
oauth <- readr::read_lines("data-raw/oauth.R")

rfuns <- list(api = api, utils = utils, oauth = oauth)
usethis::use_data(rfuns, internal = TRUE, overwrite = TRUE)

dir.create("data-raw")
file.copy("R/api.R", "data-raw/api.R")
file.copy("R/utils.R", "data-raw/utils.R")
Sys.getenv()
file.remove("R/api.R")
file.remove("R/utils.R")

usethis::use_package("devtools")

cat(paste(build_rfun(rfuns$api, basename(getwd()),
  "USE-API", "https://api.useapi.com/v1"), collapse = "\n"))
