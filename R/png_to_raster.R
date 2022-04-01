png_to_raster <- function(png_file) {

  png_file <- path.expand(png_file[1])
  out_file <- tempfile()

  .Call(
    "_ggpos_png_to_escpos_raster",
    png_file,
    out_file,
    PACKAGE = "ggpos"
  )

}

#' Print a ggplot (or other grid object) to an ESC/POS compatible network device with sensible defaults
#'
#' ESC/POS printers do not have a standard width and some have higher resolutions than others.
#' These defaults work well for a small, square plot on my used
#' [Epson TM-T88V](https://www.epson.com.au/pos/products/receiptprinters/DisplaySpecs.asp?id=tmt88v)
#'
#' @param plot Plot to save, defaults to last plot displayed.
#' @param host_pos hostname or IP address of the ESC/POS compatible network device
#' @param port port the ESC/POS compatible device is listening on; defaults to `9100L`
#' @param scale,width,height,units,dpi,bg same as their [ggplot2::ggsave()] counterparts but with
#'        sensible defaults for ESC/POS devices.
#' @export
ggpos <- function(plot = ggplot2::last_plot(),
                  host_pos,
                  port = 9100L,
                  scale = 2,
                  width = 280,
                  height = 280,
                  units = "px",
                  dpi = 144,
                  bg = "white") {

  png_file <- tempfile(fileext = ".png")

  ggplot2::ggsave(
    filename = png_file,
    plot = plot,
    scale = scale,
    width = width,
    height = height,
    units = units,
    dpi = dpi,
    bg = bg
  )

  res <- png_to_raster(png_file)

  if (res != "") {

    escpos_raster <- stringi::stri_read_raw(res)

    socketConnection(
      host = host_pos,
      port = port,
      open = "a+b"
    ) -> con

    on.exit(close(con))

    writeBin(
      object = escpos_raster,
      con = con,
      useBytes = TRUE
    )

  }

  invisible(res)

}