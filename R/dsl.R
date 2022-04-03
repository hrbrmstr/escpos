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
