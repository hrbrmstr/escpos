#' Create an `escpos` object for accumulating print commands
#'
#' @export
#' @examples
#' escpos(epson_ip) |>
#'   pos_plaintext(
#'     stringi::stri_rand_lipsum(1)
#'   ) |>
#'   pos_lf(2) |>
#'   pos_plaintext(
#'     paste0(capture.output(
#'       str(mtcars, width = 40, strict.width = "cut")
#'     ), collapse = "\n")
#'   ) |>
#'   pos_lf(2L) |>
#'   pos_plaintext(
#'     stringi::stri_rand_lipsum(1, start_lipsum = FALSE)
#'   ) |>
#'   pos_lf(3) |>
#'   pos_cut() |>
#'   pos_print()
escpos <- function(host, port = 9100L) {

  list(
    conn = list(
      host = host[1],
      port = port[1]
    ),
    sequence = vector("raw")
  ) -> res

  class(res) <- c("escpos", "list")

  invisible(res)

}

#' Issue a partial or full cut command to the printer
#'
#' @param pos_obj object created with [escpos()]
#' @param mode one of `part` or `full`
#' @param feed_lines how many line feeds to issue before the cut
#' @export
#' @examples
#' escpos(epson_ip) |>
#'   pos_plaintext(
#'     stringi::stri_rand_lipsum(1)
#'   ) |>
#'   pos_lf(2) |>
#'   pos_plaintext(
#'     paste0(capture.output(
#'       str(mtcars, width = 40, strict.width = "cut")
#'     ), collapse = "\n")
#'   ) |>
#'   pos_lf(2L) |>
#'   pos_plaintext(
#'     stringi::stri_rand_lipsum(1, start_lipsum = FALSE)
#'   ) |>
#'   pos_lf(3) |>
#'   pos_cut() |>
#'   pos_print()
pos_cut <- function(pos_obj, mode = c("part", "full"), feed_lines = 5L) {

  mode <- match.arg(tolower(mode[1]), c("part", "full"), several.ok = FALSE)

  c(
    pos_obj$sequence,
    charToRaw(stri_dup("\n", as.integer(feed_lines[1]))),
    if (mode == "part") PAPER_PART_CUT else PAPER_FULL_CUT
  ) -> pos_obj$sequence

  invisible(pos_obj)

}

#' Send collected print commands to the printer
#'
#' @param pos_obj object created with [escpos()]
#' @export
#' @examples
#' escpos(epson_ip) |>
#'   pos_plaintext(
#'     stringi::stri_rand_lipsum(1)
#'   ) |>
#'   pos_lf(2) |>
#'   pos_plaintext(
#'     paste0(capture.output(
#'       str(mtcars, width = 40, strict.width = "cut")
#'     ), collapse = "\n")
#'   ) |>
#'   pos_lf(2L) |>
#'   pos_plaintext(
#'     stringi::stri_rand_lipsum(1, start_lipsum = FALSE)
#'   ) |>
#'   pos_lf(3) |>
#'   pos_cut() |>
#'   pos_print()
pos_print <- function(pos_obj) {

  socketConnection(
    host = pos_obj[["conn"]][["host"]],
    port = pos_obj[["conn"]][["port"]],
    open = "a+b"
  ) -> con

  on.exit(close(con))

  writeBin(
    object = pos_obj[["sequence"]],
    con = con,
    useBytes = TRUE
  )

}

#' Send a LF to the printer
#'
#' @param pos_obj object created with [escpos()]
#' @param n number of feeds to send
#' @export
#' @examples
#' escpos(epson_ip) |>
#'   pos_plaintext(
#'     stringi::stri_rand_lipsum(1)
#'   ) |>
#'   pos_lf(2) |>
#'   pos_plaintext(
#'     paste0(capture.output(
#'       str(mtcars, width = 40, strict.width = "cut")
#'     ), collapse = "\n")
#'   ) |>
#'   pos_lf(2L) |>
#'   pos_plaintext(
#'     stringi::stri_rand_lipsum(1, start_lipsum = FALSE)
#'   ) |>
#'   pos_lf(3) |>
#'   pos_cut() |>
#'   pos_print()
pos_lf <- function(pos_obj, n = 1L) {
  pos_obj$sequence <- c(pos_obj$sequence, rep(CTL_LF, as.integer(n[1])))
  invisible(pos_obj)
}

#' Send a FF to the printer
#'
#' @param pos_obj object created with [escpos()]
#' @param n number of feeds to send
#' @export
#' @examples
#' escpos(epson_ip) |>
#'   pos_plaintext(
#'     stringi::stri_rand_lipsum(1)
#'   ) |>
#'   pos_lf(2) |>
#'   pos_plaintext(
#'     paste0(capture.output(
#'       str(mtcars, width = 40, strict.width = "cut")
#'     ), collapse = "\n")
#'   ) |>
#'   pos_lf(2L) |>
#'   pos_plaintext(
#'     stringi::stri_rand_lipsum(1, start_lipsum = FALSE)
#'   ) |>
#'   pos_lf(3) |>
#'   pos_cut() |>
#'   pos_print()
pos_ff <- function(pos_obj, n = 1L) {
  pos_obj$sequence <- c(pos_obj$sequence, rep(CTL_FF, as.integer(n[1])))
  invisible(pos_obj)
}

#' Send a CR to the printer
#'
#' @param pos_obj object created with [escpos()]
#' @param n number of returns to send
#' @export
#' @examples
#' escpos(epson_ip) |>
#'   pos_plaintext(
#'     stringi::stri_rand_lipsum(1)
#'   ) |>
#'   pos_lf(2) |>
#'   pos_plaintext(
#'     paste0(capture.output(
#'       str(mtcars, width = 40, strict.width = "cut")
#'     ), collapse = "\n")
#'   ) |>
#'   pos_lf(2L) |>
#'   pos_plaintext(
#'     stringi::stri_rand_lipsum(1, start_lipsum = FALSE)
#'   ) |>
#'   pos_lf(3) |>
#'   pos_cut() |>
#'   pos_print()
pos_cr <- function(pos_obj, n = 1L) {
  pos_obj$sequence <- c(pos_obj$sequence, rep(CTL_CR, as.integer(n[1])))
  invisible(pos_obj)
}

#' Send a HT to the printer
#'
#' @param pos_obj object created with [escpos()]
#' @param n number of horizontal tabs to send
#' @export
#' @examples
#' escpos(epson_ip) |>
#'   pos_plaintext(
#'     stringi::stri_rand_lipsum(1)
#'   ) |>
#'   pos_lf(2) |>
#'   pos_plaintext(
#'     paste0(capture.output(
#'       str(mtcars, width = 40, strict.width = "cut")
#'     ), collapse = "\n")
#'   ) |>
#'   pos_lf(2L) |>
#'   pos_plaintext(
#'     stringi::stri_rand_lipsum(1, start_lipsum = FALSE)
#'   ) |>
#'   pos_lf(3) |>
#'   pos_cut() |>
#'   pos_print()
pos_ht <- function(pos_obj, n = 1L) {
  pos_obj$sequence <- c(pos_obj$sequence, rep(CTL_HT, as.integer(n[1])))
  invisible(pos_obj)
}

#' Send a VT to the printer
#'
#' @param pos_obj object created with [escpos()]
#' @param n number of vertical tabs to send
#' @export
#' @examples
#' escpos(epson_ip) |>
#'   pos_plaintext(
#'     stringi::stri_rand_lipsum(1)
#'   ) |>
#'   pos_lf(2) |>
#'   pos_plaintext(
#'     paste0(capture.output(
#'       str(mtcars, width = 40, strict.width = "cut")
#'     ), collapse = "\n")
#'   ) |>
#'   pos_lf(2L) |>
#'   pos_plaintext(
#'     stringi::stri_rand_lipsum(1, start_lipsum = FALSE)
#'   ) |>
#'   pos_lf(3) |>
#'   pos_cut() |>
#'   pos_print()
pos_vt <- function(pos_obj, n = 1L) {
  pos_obj$sequence <- c(pos_obj$sequence, rep(CTL_VT, as.integer(n[1])))
  invisible(pos_obj)
}

#' Send plaintext to the printer
#'
#' @param pos_obj object created with [escpos()]
#' @param txt character vector. If length > 1, each will be sent to the printer
#' @export
#' @examples
#' escpos(epson_ip) |>
#'   pos_plaintext(
#'     stringi::stri_rand_lipsum(1)
#'   ) |>
#'   pos_lf(2) |>
#'   pos_plaintext(
#'     paste0(capture.output(
#'       str(mtcars, width = 40, strict.width = "cut")
#'     ), collapse = "\n")
#'   ) |>
#'   pos_lf(2L) |>
#'   pos_plaintext(
#'     stringi::stri_rand_lipsum(1, start_lipsum = FALSE)
#'   ) |>
#'   pos_lf(3) |>
#'   pos_cut() |>
#'   pos_print()
pos_plaintext <- function(pos_obj, txt) {
  for (item in txt) {
    pos_obj$sequence <- c(pos_obj$sequence, charToRaw(item))
  }
  invisible(pos_obj)
}

#' Bold text
#'
#' @param pos_obj object created with [escpos()]
#' @param set one of "`on`", "`off`"
#' @return `pos_obj` (invisibly)
#' @export
pos_bold <- function(pos_obj, set = c("on", "off")) {
  set <- match.arg(tolower(set[1]), c("on", "off"), several.ok = FALSE)
  pos_obj$sequence <- c(pos_obj$sequence, TEXT_STYLE$bold[[set]])
  invisible(pos_obj)
}

#' Underline
#'
#' @param pos_obj object created with [escpos()]
#' @param set one of "`1dot`", "`2dot`", "`off`"
#' @return `pos_obj` (invisibly)
#' @export
pos_underline <- function(pos_obj, set = c("1dot", "2dot", "off")) {
  set <- match.arg(tolower(set[1]), c("1dot", "2dot", "off"), several.ok = FALSE)
  pos_obj$sequence <- c(pos_obj$sequence, TEXT_STYLE$underline[[set]])
  invisible(pos_obj)
}

#' Text size
#'
#' @param pos_obj object created with [escpos()]
#' @param set one of "`normal`", "`2h`", "`2w`", "`2x`"
#' @return `pos_obj` (invisibly)
#' @export
pos_size <- function(pos_obj, set = c('normal', '2h', '2w', '2x')) {
  set <- match.arg(tolower(set[1]), c('normal', '2h', '2w', '2x'), several.ok = FALSE)
  pos_obj$sequence <- c(pos_obj$sequence, TEXT_STYLE$size[[set]])
  invisible(pos_obj)
}

#' Font choice
#'
#' @param pos_obj object created with [escpos()]
#' @param set one of "`a`", "`b`", "`c`"
#' @return `pos_obj` (invisibly)
#' @export
pos_font <- function(pos_obj, set = c('a', 'b', 'c')) {
  set <- match.arg(tolower(set[1]), c('a', 'b', 'c'), several.ok = FALSE)
  pos_obj$sequence <- c(pos_obj$sequence, TEXT_STYLE$font[[set]])
  invisible(pos_obj)
}

#' Text alignment
#'
#' @param pos_obj object created with [escpos()]
#' @param set one of "`left`", "`right`", "`center`"
#' @return `pos_obj` (invisibly)
#' @export
pos_align <- function(pos_obj, set = c('left', 'right', 'center')) {
  set <- match.arg(tolower(set[1]), c('left', 'right', 'center'), several.ok = FALSE)
  pos_obj$sequence <- c(pos_obj$sequence, TEXT_STYLE$align[[set]])
  invisible(pos_obj)
}

#' Invert printing
#'
#' @param pos_obj object created with [escpos()]
#' @param set one of "`true`", "`false`"
#' @return `pos_obj` (invisibly)
#' @export
pos_inverted <- function(pos_obj, set = c('true', 'false')) {
  set <- match.arg(tolower(set[1]), c('true', 'false'), several.ok = FALSE)
  pos_obj$sequence <- c(pos_obj$sequence, TEXT_STYLE$inverted[[set]])
  invisible(pos_obj)
}

#' Set color
#'
#' @param pos_obj object created with [escpos()]
#' @param set one of "`one`", "`two`"
#' @return `pos_obj` (invisibly)
#' @export
pos_color <- function(pos_obj, set = c('one', 'two')) {
  set <- match.arg(tolower(set[1]), c('one', 'two'), several.ok = FALSE)
  pos_obj$sequence <- c(pos_obj$sequence, TEXT_STYLE$color[[set]])
  invisible(pos_obj)
}

#' Turn a ggplot (or other grid object) intto an ESC/POS bitmap for use in the DSL
#'
#' @param pos_obj object created with [escpos()]
#' @param plot Plot to save, defaults to last plot displayed.
#' @param color color?
#' @param host_pos hostname or IP address of the ESC/POS compatible network device
#' @param port port the ESC/POS compatible device is listening on; defaults to `9100L`
#' @param scale,width,height,units,dpi,bg same as their [ggplot2::ggsave()] counterparts but with
#'        sensible defaults for ESC/POS devices.
#' @param ... other parameters to pass on to [ggplot2::ggsave()]
#' @export
pos_plot <- function(pos_obj,
                     plot = ggplot2::last_plot(),
                     color = FALSE,
                     scale = 2,
                     width = 256,
                     height = 256,
                     units = "px",
                     dpi = 144,
                     bg = "white",
                     ...) {

  png_file <- tempfile(fileext = ".png")

  ggplot2::ggsave(
    filename = png_file,
    plot = plot,
    scale = scale,
    width = width,
    height = height,
    units = units,
    dpi = dpi,
    bg = bg,
    ...
  )

  res <- png_to_raster(png_file, color = color[1])

  if (res != "") {
    escpos_raster <- stringi::stri_read_raw(res)
    pos_obj$sequence <- c(pos_obj$sequence, stringi::stri_read_raw(res))
  }

  pos_obj

}










