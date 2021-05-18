
#' Publish to RStudio Connect
#'
#' Publish a quarto document or project to RStudio Connect
#'
#' @inheritParams rsconnect::deployApp
#'
#' @param input The input file or project directory to be published. Defaults to
#'   current working directory.
#' @param name Name for publishing (names must be unique within an account). For
#'   projects, defaults to the `name` provided by the project (alternatively
#'   uses the base name of the `input`).
#' @param account Account to deploy to. This parameter is only required for the
#'   initial deployment when there are multiple accounts configured on the
#'   system.
#' @param method Publishing method (currently only "rsconnect" is available)
#' @param render `TRUE` to render locally before publishing.
#' @param launch_browser If `TRUE`, the system's default web browser will be
#'   launched automatically after deployment. Defaults to `TRUE` in interactive
#'   sessions only.
#'
#' @examples
#' \dontrun{
#' library(quarto)
#' quarto_publish()
#' }
#'
#' @export
quarto_publish <- function(input = ".", name = NULL,
                           method = c("rsconnect"), server = NULL, account = NULL,
                           render = TRUE, launch_browser = interactive()) {

  # resolve method
  method <- match.arg(method)

  if (identical(method, "rsconnect")) {

    # confirm that we have rsconnect
    if (!requireNamespace("rsconnect", quietly = FALSE)) {
      stop("The rsconnect package is required to publish projects ",
           "Please install rsconnect with install.packages(\"rsconnect\")")
    }

    # check for non shinyapps.io accounts
    accounts <- rsconnect::accounts()
    accounts <- subset(accounts, server != "shinyapps.io")

    # if there is no server or account specified then see if we
    # can default the account
    if (is.null(server) && is.null(account)) {
      if (is.null(accounts) || nrow(accounts) == 0)
        stop("You must specify a server to publish the website to")
      else if (nrow(accounts) == 1) {
        account <- accounts$name
        server <- accounts$server
      }
    }

    # handle server
    if (!is.null(server) && is.null(account)) {

      # get a version of the server with the protocol (strip trailing slash)
      if (!grepl("^https?://", server))
        server_with_protocol <- paste0("https://", server)
      else
        server_with_protocol <- server
      server_with_protocol <- sub("/+$", "", server_with_protocol)

      # now strip the protocol if it's there
      server <- sub("^https?://", "", server_with_protocol)
      server_name <- server

      # ensure we have this server available
      accounts <- rsconnect::accounts()
      accounts <- subset(accounts, server == server_name)
      if (nrow(accounts) == 0) {

        # prompt
        message(sprintf("You do not currently have a %s publishing account ", server),
                "configured on this system.")
        result = readline("Would you like to configure one now? [Y/n]: ")
        if (tolower(result) == "n")
          return(invisible())

        # create server if we need to
        servers <- rsconnect::servers()
        if (nrow(subset(servers, servers$name == server)) == 0) {

          rsconnect::addServer(sprintf("%s/__api__", server_with_protocol), server)
        }

        # connect user
        rsconnect::connectUser(server = server)

      }
      else if (nrow(accounts) == 1) {

        account <- accounts$name

      } else {

        stop("There is more than one account registered for ", server,
             "\nPlease specify which account you want to publish to.")

      }
    }

    # get metadata that will be used for publishing
    metadata <- quarto_metadata(input)

    # is this a site or an individual doc?
    if (file.info(input)$isdir) {

      # render if requested
      if (render) {
        quarto_render(input)
      }

      # title
      title <- metadata$site[["title"]]
      # name
      if (is.null(name)) {
        name <- basename(normalizePath(input))
      }

      # output-dir
      output_dir <- metadata$project[["output-dir"]]
      if (!is.null(output_dir))
        app_dir <- output_dir
      else
        app_dir <- input

      # deploy project
      rsconnect::deployApp(
        appDir = app_dir,
        recordDir = input,
        appName = name,
        appTitle = title,
        account = account,
        server = server,
        launch.browser = launch_browser,
        lint = FALSE,
        contentCategory = "site"
      )
    } else {

      # determine the output format
      format <- names(metadata)[[1]]

      # render self-contained
      if (render) {
        quarto_render(
          input,
          output_format = format,
          pandoc_args = c("--self-contained")
        )
      }

      # determine the output file
      output_file <- metadata[[format]]$pandoc[["output-file"]]
      output_file <- file.path(dirname(input), output_file)

      # publish
      rsconnect::deployDoc(
        doc = output_file,
        appTitle = metadata[[format]]$metadata$title,
        account = account,
        server = server,
        launch.browser = launch_browser,
        lint = FALSE,
        contentCategory = "document"
      )
    }
  }
}
