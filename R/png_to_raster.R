#' Convert any png file to ESC/POS raster format
#'
#' @param png_file path to PNG file
#' @param color if `TRUE`, an attempt will be made to dither the result
#' @return path to a temporary file in ESC/POS raster bitmap format or `""` if an error occurred
#' @export
png_to_raster <- function(png_file, color = FALSE) {

  png_file <- path.expand(png_file[1])
  out_file <- tempfile()

  .Call(
    "_escpos_png_to_escpos_raster",
    png_file,
    out_file,
    color[1],
    PACKAGE = "escpos"
  )

}

#' Print a ggplot (or other grid object) to an ESC/POS compatible network device with sensible defaults
#'
#' ESC/POS printers do not have a standard width and some have higher resolutions than others.
#' These defaults work well for a small, square plot on my used
#' [Epson TM-T88V](https://www.epson.com.au/pos/products/receiptprinters/DisplaySpecs.asp?id=tmt88v)
#'
#' @param plot Plot to save, defaults to last plot displayed.
#' @param color color?
#' @param host_pos hostname or IP address of the ESC/POS compatible network device
#' @param port port the ESC/POS compatible device is listening on; defaults to `9100L`
#' @param scale,width,height,units,dpi,bg same as their [ggplot2::ggsave()] counterparts but with
#'        sensible defaults for ESC/POS devices.
#' @param ... other parameters to pass on to [ggplot2::ggsave()]
#' @export
ggpos <- function(plot = ggplot2::last_plot(),
                  color = FALSE,
                  host_pos,
                  port = 9100L,
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

