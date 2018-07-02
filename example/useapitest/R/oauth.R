
#' useapitest_token
#'
#' Accessing the user's instagram token
#'
#' @return The user's access token, if available.
#' @export
#' @rdname useapitest_token
useapitest_token <- function() {
  if (identical(Sys.getenv("USE_API_TEST_PAT"), "")) {
    stop("Couldn't find access token. See `?useapitest_create_token()` for ",
      "instructions on setting up and storying your access token.")
  }
  structure(Sys.getenv("USE_API_TEST_PAT"), names = "access_token")
}


#' Create useapitest_token
#'
#' Creating access token for interacting with Instagram API
#' @param access_token Access token. Token creation should occur via supplying
#'   access token directly or via client ID and client secret. You should
#'   provide one or the other to this function.
#' @param client_id Client key. Token creation should occur via supplying
#'   access token directly or via client ID and client secret. You should
#'   provide one or the other to this function.
#' @param client_secret Client secret. Required if access token is NULL and
#'   a value is supplied for client_id.
#' @param ... Other args passed to \link[httr]{init_oauth2.0}
#' @return Sets environment variable and invisibly returns access token.
#' @rdname useapitest_token
#' @export
useapitest_create_token <- function(access_token = NULL,
                               client_id = NULL,
                               client_secret = NULL, ...) {
  if (!is.null(access_token)) {
    access_token <- gsub("\\s", "", access_token)
  } else if (is.null(client_id) || is.null(client_secret)) {
    stop("Must provide either access_token OR both client ID and client secret")
  } else {
    client_id <- gsub("\\s", "", client_id)
    client_secret <- gsub("\\s", "", client_secret)
    scope <- paste(scope, collapse = " ")
    Sys.setenv("HTTR_SERVER" = "127.0.0.1")
    Sys.setenv("HTTR_SERVER_PORT" = "1410")
    app <- httr::oauth_app("useapitest_r_client", client_id, client_secret,
      redirect_uri = "http://127.0.0.1:1410")
    token <- httr::init_oauth2.0(useapitest_oauth_endpoint(), app, ...)
    access_token <- token$access_token
  }
  set_renv(USE_API_TEST_PAT = access_token)
  message("Token created and stored as `USE_API_TEST_PAT` environment ",
    "variable! To view your access token, use `useapitest_token()`.")
  invisible(structure(access_token, names = "access_token"))
}

useapitest_oauth_endpoint <- function() {
  httr::oauth_endpoint(base_url = "https://https://api.useapitest.com/oauth",
    authorize = "authorize", access = "access_token")
}
