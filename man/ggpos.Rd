% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/png_to_raster.R
\name{ggpos}
\alias{ggpos}
\title{Print a ggplot (or other grid object) to an ESC/POS compatible network device with sensible defaults}
\usage{
ggpos(
  plot = ggplot2::last_plot(),
  color = FALSE,
  host_pos,
  port = 9100L,
  scale = 2,
  width = 256,
  height = 256,
  units = "px",
  dpi = 144,
  bg = "white",
  ...
)
}
\arguments{
\item{plot}{Plot to save, defaults to last plot displayed.}

\item{color}{color?}

\item{host_pos}{hostname or IP address of the ESC/POS compatible network device}

\item{port}{port the ESC/POS compatible device is listening on; defaults to \code{9100L}}

\item{scale, width, height, units, dpi, bg}{same as their \code{\link[ggplot2:ggsave]{ggplot2::ggsave()}} counterparts but with
sensible defaults for ESC/POS devices.}

\item{...}{other parameters to pass on to \code{\link[ggplot2:ggsave]{ggplot2::ggsave()}}}
}
\description{
ESC/POS printers do not have a standard width and some have higher resolutions than others.
These defaults work well for a small, square plot on my used
\href{https://www.epson.com.au/pos/products/receiptprinters/DisplaySpecs.asp?id=tmt88v}{Epson TM-T88V}
}
