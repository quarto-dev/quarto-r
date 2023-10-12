skip_if_no_quarto <- function() {
  skip_if(is.null(quarto_path()))
}

skip_if_quarto <- function() {
  skip_if(!is.null(quarto_path()))
}
