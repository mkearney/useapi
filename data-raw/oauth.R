
#' {PKG}_token
#'
#' Accessing the user's instagram token
#'
#' @return The user's access token, if available.
#' @export
#' @rdname {PKG}_token
{PKG}_token <- function() {
  if (identical(Sys.getenv("{SITE_UPPERCASE}_PAT"), "")) {
    stop("Couldn't find access token. See `?{PKG}_create_token()` for ",
      "instructions on setting up and storying your access token.")
  }
  structure(Sys.getenv("{SITE_UPPERCASE}_PAT"), names = "access_token")
}


#' Create {PKG}_token
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
#' @rdname {PKG}_token
#' @export
{PKG}_create_token <- function(access_token = NULL,
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
    app <- httr::oauth_app("{PKG}_r_client", client_id, client_secret,
      redirect_uri = "http://127.0.0.1:1410")
    token <- httr::init_oauth2.0({PKG}_oauth_endpoint(), app, ...)
    access_token <- token$access_token
  }
  set_renv({SITE_UPPERCASE}_PAT = access_token)
  message("Token created and stored as `{SITE_UPPERCASE}_PAT` environment ",
    "variable! To view your access token, use `{PKG}_token()`.")
  invisible(structure(access_token, names = "access_token"))
}

{PKG}_oauth_endpoint <- function() {
  httr::oauth_endpoint(base_url = "https://{BASE_API_URL}/oauth",
    authorize = "authorize", access = "access_token")
}
