#' Print Text, Images, and {ggplot2} or {grid} Objects to ESC/POS Compatible Network Devices
#'
#' ESC/POS devices, such as receipt printers, have the ability to print their own form of
#' raster bitmap graphics as well as text. Tools are provided to turn {ggplot2} or {grid} objects
#' into such raster bitmaps and print them, along with text and regular impages, to ESC/POS
#' compatible devices.#'
#' @md
#' @name escpos
#' @keywords internal
#' @author Bob Rudis (bob@@rud.is)
#' @importFrom ggplot2 last_plot ggsave
#' @importFrom stringi stri_read_raw
#' @useDynLib escpos, .registration = TRUE
#' @importFrom Rcpp sourceCpp
"_PACKAGE"
