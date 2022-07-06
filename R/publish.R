
#' Publish Quarto Documents
#'
#' Publish Quarto documents to RStudio Connect and ShinyApps
#'
#' @inheritParams rsconnect::deployApp
#'
#' @param input The input file or project directory to be published. Defaults to
#'   the current working directory.
#' @param name Name for publishing (names must be unique within an account).
#'   Defaults to the name of the `input`.
#' @param title Free-form descriptive title of application. Optional; if
#'  supplied, will often be displayed in favor of the name. When deploying a new
#'  document, you may supply only the title to receive an auto-generated name
#' @param render `local` to render locally before publishing; `server` to
#'   render on the server; `none` to use whatever rendered content currently
#'   exists locally. (defaults to `local`)
#' @param server Server name. Use "shinyapps.io" when deploying applications
#'   to Shinyapps. Use "rpubs.com" when deploying documents to RPubs. Otherwise
#'   use the domain name or IP address of any RStudio Connect server.
#' @param ... Named parameters to pass along to `rsconnect::deployApp()`
#'
#' @examples
#' \dontrun{
#' library(quarto)
#' quarto_publish_doc("mydoc.qmd")
#' quarto_publish_app(server = "shinyapps.io")
#' quarto_publish_site(server = "rstudioconnect.example.com")
#' }
#'
#' @export
quarto_publish_doc <- function(input,
                               name = NULL,
                               title = NULL,
                               server = NULL,
                               account = NULL,
                               render = c("local", "server", "none"),
                               metadata = list(),
                               ...) {
  # resolve render
  render <- match.arg(render)

  # check for rpubs target
  rpubs_destination <- rpubs_publish_destination(input, server)

  # get metadata
  inspect <- quarto_inspect(input)
  input_formats <- inspect[["formats"]]
  resources <- inspect[["resources"]]

  # determine the output format
  format <- names(input_formats)[[1]]

  # render if requested (always render self-contained locally for rpubs)
  if (!is.null(rpubs_destination)) {
    render <- "local"
    quarto_render(input, output_format = format,
                  pandoc_args = "--self-contained")
  } else if (render == "local") {
    quarto_render(input, output_format = format)
  }

  # determine the target doc and app files
  if (render == "server") {
    doc <- input
  } else {
    doc <- file.path(dirname(normalizePath(input)),
                     input_formats[[format]]$pandoc[["output-file"]])
  }

  # determine title
  if (is.null(title)) {
    title <- input_formats[[format]]$metadata$title
  }

  # special case for rpubs
  if (!is.null(rpubs_destination)) {

    id <- rpubs_destination[["bundleId"]]
    if (!is.null(id)) {
      message("Updating document on rpubs.com...")
    }
    result <- rsconnect::rpubsUpload(title, doc, input, id)
    if (!is.null(result$continueUrl))
      utils::browseURL(result$continueUrl)
    else
      stop(result$error)

  } else {
    # resolve server/account
    destination <- resolve_destination(server, account, FALSE)

    # determine app_files
    app_files <- c(basename(doc))
    tryCatch({
      # this operation can be expensive and could also throw if e.g. the
      # document fails to parse or render
      deploy_frame <- rmarkdown::find_external_resources(doc)
    },
    error = function(e) {
      # errors are not fatal here; we just might miss some resources, which
      # the user will have to add manually
    })
    if (!is.null(deploy_frame)) {
      app_files <- c(app_files, deploy_frame$path)
    }

    # include any explicit resources with app files
    app_files <- unique(c(app_files, resources))

    # deploy doc
    if (render == "server") {
      rsc_metadata <- quarto_rsc_metadata(inspect)
      metadata$quarto_version <- rsc_metadata$version
      metadata$quarto_engines <- rsc_metadata$engines
    }
    rsconnect::deployApp(
      appDir = dirname(input),
      appPrimaryDoc = if (render == "server") NULL else basename(doc),
      appSourceDoc = input,
      appFiles = app_files,
      appName = name,
      appTitle = title,
      account = destination$account,
      server = destination$server,
      metadata = metadata,
      ...
    )
  }


}


#' @rdname quarto_publish_doc
#' @export
quarto_publish_app <- function(input = getwd(),
                               name = NULL,
                               title = NULL,
                               server = NULL,
                               account = NULL,
                               render = c("local", "server", "none"),
                               metadata = list(),
                               ...) {
  # resolve render
  render <- match.arg(render)

  # resolve primary doc
  if (file.info(input)$isdir) {
    app_primary_doc <- find_app_primary_doc(input)
    if (is.null(app_primary_doc)) {
      stop("Unable to find Quarto document with Shiny application runtime")
    }
    app_dir <- input
  } else {
    app_primary_doc <- basename(normalizePath(input))
    app_dir <- dirname(input)
  }
  app_path <- file.path(app_dir, app_primary_doc)

  # render if requested
  if (render == "local") {
    quarto_render(app_path)
  }

  # resolve server/account
  destination <- resolve_destination(server, account, TRUE)

  # delegate to deployApp
  rsc_metadata <- quarto_rsc_metadata(quarto_inspect(app_path))
  metadata$quarto_version <- rsc_metadata$version
  metadata$quarto_engines <- rsc_metadata$engines
  metadata$serverRender <- render == "server"
  rsconnect::deployApp(appDir = app_dir,
                       appPrimaryDoc = app_primary_doc,
                       appSourceDoc = file.path(app_dir, app_primary_doc),
                       appName = name,
                       appTitle = title,
                       server = destination$server,
                       account = destination$account,
                       metadata = metadata,
                       ...)
}


#' @rdname quarto_publish_doc
#' @export
quarto_publish_site <- function(input = getwd(),
                                name = NULL,
                                title = NULL,
                                server = NULL,
                                account = NULL,
                                render = c("local", "server", "none"),
                                metadata = list(),
                                ...) {

  # resolve render
  render <- match.arg(render)

  # get metadata
  inspect <- quarto_inspect(input)
  config <- inspect[["config"]]

  # render if requested
  if (render == "local") {
    quarto_render(input, as_job = FALSE)
  }

  # title
  title <- config$site[["title"]]
  # name
  if (is.null(name)) {
    name <- basename(normalizePath(input))
  }

  # output-dir
  output_dir <- config$project[["output-dir"]]

  if (render != "server" && !is.null(output_dir))
    app_dir <- output_dir
  else
    app_dir <- input

  # resolve server/account
  destination <- resolve_destination(server, account, FALSE)

  # deploy project
  if (render == "server") {
    rsc_metadata <- quarto_rsc_metadata(inspect)
    metadata$quarto_version <- rsc_metadata$version
    metadata$quarto_engines <- rsc_metadata$engines
  }
  rsconnect::deployApp(
    appDir = app_dir,
    recordDir = input,
    appName = name,
    appTitle = title,
    account = destination$account,
    server = destination$server,
    metadata = metadata,
    contentCategory = "site"
  )

}


find_app_primary_doc <- function(dir) {
  preferred <- c("index.Rmd", "index.rmd", "index.qmd",
                 "ui.Rmd", "ui.rmd", "ui.qmd")
  preferred <- preferred[file.exists(file.path(dir, preferred))]
  if (length(preferred) > 0) {
    return(preferred[[1]])
  } else {
    all_docs <- list.files(path = dir, pattern = "^[^_].*\\.[Rrq][Mm][Dd]$")
    if (length(all_docs) == 1) {
      return(all_docs)
    } else {
      primary_doc <- NULL
      for (doc in all_docs) {
        yaml <- rmarkdown::yaml_front_matter(file.path(dir, doc))
        if (is_shiny_prerendered(yaml[["runtime"]], yaml[["server"]])) {
          primary_doc <- doc
          break
        }
      }
      return (primary_doc)
    }
  }
  return(NULL)
}

is_shiny_prerendered <- function(runtime, server = NULL) {
  if (identical(runtime, "shinyrmd") || identical(runtime, "shiny_prerendered")) {
    TRUE
  } else if (identical(server, "shiny")) {
    TRUE
  } else if (is.list(server) && identical(server[["type"]], "shiny")) {
    TRUE
  } else {
    FALSE
  }
}


rpubs_publish_destination <- function(doc, server) {
  if (identical(server, "rpubs.com")) {
    deployments <- rsconnect::deployments(doc, serverFilter = "rpubs.com")
    if (nrow(deployments) > 0) {
      as.list(deployments[1,])
    } else {
      list()
    }
  } else if (is.null(server)) {
    deployments <- rsconnect::deployments(doc)
    if (nrow(deployments) == 1 && identical(deployments$server, "rpubs.com")) {
      as.list(deployments)
    } else {
      NULL
    }
  }
}

resolve_destination <- function(server, account, allowShinyapps) {

  # validate we have the right version of rsconnect
  validate_rsconnect()

  # check for  accounts
  accounts <- rsconnect::accounts()
  if (!allowShinyapps)
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
    if (is.null(accounts) || nrow(accounts) == 0) {

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

  list(
    server = server,
    account = account
  )
}


validate_rsconnect <- function() {

  # confirm that we have rsconnect
  if (!requireNamespace("rsconnect", quietly = FALSE)) {
    stop("The rsconnect package is required for publishing. ",
         "Please install rsconnect with:\n  remotes::install_github(\"rstudio/rsconnect\")")
  }

  # confirm we have a recent enough version
  rsc_version <- "0.8.24"
  if (utils::packageVersion("rsconnect") < rsc_version) {
    stop("Version ", rsc_version, " or greater of the rsconnect package is required ",
         "for publishing. Please install with:\n  remotes::install_github(\"rstudio/rsconnect\")")
  }
}

quarto_rsc_metadata <- function(inspect) {
  list(
    version = inspect[["quarto"]][["version"]],
    engines = I(inspect[["engines"]])
  )
}

