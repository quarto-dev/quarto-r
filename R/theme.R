#' Create a theme for a plotting or table package
#'
#' Create a theme using background and foreground colors (`theme_colors_*`) or
#' using a **brand.yml** file (`theme_brand_*`).
#'
#' The use of the theme will depend on the package. See the vignettes for
#' usage examples.
#'
#' @param bg The background color
#' @param fg The foreground color
#' @param brand_yml The path to a brand.yml file

#' @rdname theme_helpers
#'
#' @export
theme_colors_flextable <- function(bg, fg) {
  (function(x) {
    if (!inherits(x, "flextable")) {
      stop("theme_colors_flextable only supports flextable objects.")
    }
    x <- flextable::bg(x, bg = bg, part = "all")
    x <- flextable::color(x, color = fg, part = "all")
    flextable::autofit(x)
  })
}

#' @rdname theme_helpers
#'
#' @export
theme_brand_flextable <- function(brand_yml) {
  brand <- attr(bslib::bs_theme(brand=brand_yml), "brand")
  theme_colors_flextable(brand$color$background, brand$color$foreground)
}


#' @rdname theme_helpers
#'
#' @export
theme_colors_ggplot <- function(bg, fg) {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    return(NULL)
  }
  ggplot2::`%+%`(
    ggplot2::theme_minimal(base_size = 11),
    ggplot2::theme(
      panel.border = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_blank(),
      panel.grid.minor.y = ggplot2::element_blank(),
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.minor.x = ggplot2::element_blank(),
      text = ggplot2::element_text(colour = fg),
      axis.text = ggplot2::element_text(colour = fg),
      rect = ggplot2::element_rect(colour = bg, fill = bg),
      plot.background = ggplot2::element_rect(fill = bg, colour = NA),
      axis.line = ggplot2::element_line(colour = fg),
      axis.ticks = ggplot2::element_line(colour = fg)
    )
  )
}

#' @rdname theme_helpers
#'
#' @export
theme_brand_ggplot <- function(brand_yml) {
  brand <- attr(bslib::bs_theme(brand=brand_yml), "brand")
  theme_colors_ggplot(brand$color$background, brand$color$foreground)
}


#' @rdname theme_helpers
#'
#' @export
theme_colors_gt <- function(bg, fg) {
  (function(table) {
    table |>
      gt::tab_options(
        table.background.color = bg,
        table.font.color = fg,
      )
  })
}

#' @rdname theme_helpers
#'
#' @export
theme_brand_gt <- function(brand_yml) {
  brand <- attr(bslib::bs_theme(brand=brand_yml), "brand")
  theme_colors_gt(brand$color$background, brand$color$foreground)
}

#' @rdname theme_helpers
#'
#' @export
theme_colors_plotly <- function(bg, fg) {
  (function(plot) {
    plot |>
      plotly::layout(
        paper_bgcolor = bg,
        plot_bgcolor = bg,
        font = list(color = fg)
      )
  })
}

#' @rdname theme_helpers
#'
#' @export
theme_brand_plotly <- function(brand_yml) {
  brand <- attr(bslib::bs_theme(brand=brand_yml), "brand")
  theme_colors_plotly(brand$color$background, brand$color$foreground)
}


#' @rdname theme_helpers
#'
#' @export
theme_colors_thematic <- function(bg, fg) {
  (function() {
    thematic::thematic_rmd(
      bg = bg,
      fg = fg,
    )
  })
}

#' @rdname theme_helpers
#'
#' @export
theme_brand_thematic <- function(brand_yml) {
  brand <- attr(bslib::bs_theme(brand=brand_yml), "brand")
  theme_colors_thematic(brand$color$background, brand$color$foreground)
}
