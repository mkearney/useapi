
#' Create API package
#'
#' @param path A path. If it exists, it is used. If it does not exist, it is
#'   created, provided that the parent path exists.
#' @param site Name of the site/app/platform. This is how it will be referenced
#'   in function documentation.
#' @param base_url Base URL to the site/app/platform of interest.
#' @param ... Other arguments passed on to \link[usethis]{create_package}.
#' @return Creates or uses existing directory and builds the basic
#'   infastructure for an API client R package.
#' @details In addition to \link[usethis]{create_package} defaults, this
#'   function provides useful starter functions for creating an R client for
#'   interacting with a web API. The functions are saved in two files in the
#'   path's R directory. api.R contains functions for sending/receiving HTTP
#'   requests. utils.R contains functions for setting environment variables and
#'   parsing response objects.
#' @examples
#' \dontrun{
#' ## create API client package for Instagram API
#' create_api_package("example/useapitest",
#'   "Use API Test Site", "https://api.useapitest.com/v1")
#' }
#' @export
create_api_package <- function(path, site, base_url, ...) {
  owd <- getwd()
  on.exit(setwd(owd), add = TRUE)
  if (!dir.exists(path)) {
    dir.create(path)
  }
  setwd(path)
  usethis::create_package(getwd(), ..., open = FALSE)
  build_rfuns(site, base_url)
  usethis::use_package("httr")
  usethis::use_package("jsonlite")
  usethis::use_package("tibble")
  devtools::document(path)
  devtools::install(path)
  invisible(TRUE)
}

build_rfun <- function(rfun, pkg, site, base_url) {
  if (any(grepl("HTTR_SERVER", rfun))) {
    base_url <- dirname(base_url)
  }
  uppersite <- gsub("\\s+", "_", toupper(site))

  rfun <- gsub("\\{PKG\\}", pkg, rfun)
  rfun <- gsub("\\{SITE_UPPERCASE\\}", uppersite, rfun)
  rfun <- gsub("\\{SITE\\}", site, rfun)
  gsub("\\{BASE_API_URL\\}", base_url, rfun)
}

build_rfuns <- function(site, base_url) {
  save_as <- file.path("R", paste0(names(rfuns), ".R"))
  rf <- lapply(rfuns, build_rfun, basename(getwd()), site, base_url)
  for (i in seq_along(rf)) {
    task <- rlang::quo(writeLines(rf[[i]], save_as[i]))
    task_progress_bar(task, paste0("Writing R/", basename(save_as[i])))
  }
  invisible()
}



task_progress_bar <- function(task, msg) {
  w <- getOption("width")
  if (w > 90) {
    w <- 90
  }
  ## estimate half bar
  r <- (w - nchar(msg) - 7) %/% 2
  cat(paste0(msg, " +"))
  for (j in seq_len(r)) {
    Sys.sleep(.025)
    cat("+")
  }
  rlang::eval_tidy(task)
  for (k in seq_len(r)) {
    Sys.sleep(.025)
    if (k == r) {
      cat(" 100%", fill = TRUE)
    } else {
      cat("+")
    }
  }
}
