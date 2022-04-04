
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Signed
by](https://img.shields.io/badge/Keybase-Verified-brightgreen.svg)](https://keybase.io/hrbrmstr)
![Signed commit
%](https://img.shields.io/badge/Signed_Commits-0%25-lightgrey.svg)
[![R-CMD-check](https://github.com/hrbrmstr/escpos/workflows/R-CMD-check/badge.svg)](https://github.com/hrbrmstr/escpos/actions?query=workflow%3AR-CMD-check)
[![Linux build
Status](https://travis-ci.org/hrbrmstr/escpos.svg?branch=master)](https://travis-ci.org/hrbrmstr/escpos)  
![Minimal R
Version](https://img.shields.io/badge/R%3E%3D-3.6.0-blue.svg)
![License](https://img.shields.io/badge/License-MIT-blue.svg)

# escpos

Print Text, Images, and {ggplot2} or {grid} Objects to ESC/POS
Compatible Network Devices

## Description

ESC/POS devices, such as receipt printers, have the ability to print
their own form of raster bitmap graphics as well as text. Tools are
provided to turn {ggplot2} or {grid} objects into such raster bitmaps
and print them, along with text and regular impages, to ESC/POS
compatible devices.

## What’s Inside The Tin

The following functions are implemented:

-   `ggpos`: Print a ggplot (or other grid object) to an ESC/POS
    compatible network device with sensible defaults
-   `png_to_raster`: Convert any png file to ESC/POS raster format
-   `pos_align`: Text alignment
-   `pos_bold`: Bold text
-   `pos_color`: Set color
-   `pos_cr`: Send a CR to the printer
-   `pos_cut`: Issue a partial or full cut command to the printer
-   `pos_ff`: Send a FF to the printer
-   `pos_font`: Font choice
-   `pos_ht`: Send a HT to the printer
-   `pos_inverted`: Invert printing
-   `pos_lf`: Send a LF to the printer
-   `pos_plaintext`: Send plaintext to the printer
-   `pos_plot`: Turn a ggplot (or other grid object) intto an ESC/POS
    bitmap for use in the DSL
-   `pos_print`: Send collected print commands to the printer
-   `pos_size`: Text size
-   `pos_underline`: Underline
-   `pos_vt`: Send a VT to the printer
-   `escpos`: Create an `escpos` object for accumulating print commands

## NOTE

I’ve only tested this on a single, networked EPSON TM-T88V printer.

## Installation

``` r
remotes::install_github("hrbrmstr/escpos", ref = "batman")
```

## Usage

``` r
library(escpos)

# current version
packageVersion("escpos")
## [1] '0.2.0'
```

``` r
library(stringi)
library(hrbrthemes)
library(ggplot2)

ggplot() +
  geom_point(
    data = mtcars,
    aes(wt, mpg),
    color = "red"
  ) +
  labs(
    title = "A good title"
  ) +
  theme_ipsum_es(grid="XY") -> gg

epson_ip = "HOSTNAME_OR_IP_OF_YOUR_PRINTER"

escpos(epson_ip) |>
  pos_bold("on") %>%
  pos_align("center") %>%
  pos_size("2x") %>%
  pos_underline("2dot") %>%
  pos_plaintext("This Is A Title") %>%
  pos_lf(2) |>
  pos_underline("off") %>%
  pos_size("normal") %>%
  pos_align("left") %>%
  pos_bold("off") %>%
  pos_font("b") %>%
  pos_plaintext(
    stringi::stri_rand_lipsum(1)
  ) |>
  pos_lf(2) |>
  pos_font("a") %>%
  pos_plaintext(
    paste0(capture.output(
      str(mtcars, width = 40, strict.width = "cut")
    ), collapse = "\n")
  ) |>
  pos_lf(2L) |>
  pos_plot(gg, color = TRUE) %>%
  pos_lf(2L) |>
  pos_font("c") %>%
  pos_plaintext(
    stringi::stri_rand_lipsum(1, start_lipsum = FALSE)
  ) |>
  pos_lf(3) |>
  pos_cut() %>%
  pos_print()
```

![](man/figures/escpos-complex.png)

## escpos Metrics

| Lang         | \# Files |  (%) |  LoC |  (%) | Blank lines |  (%) | \# Lines |  (%) |
|:-------------|---------:|-----:|-----:|-----:|------------:|-----:|---------:|-----:|
| C++          |        6 | 0.16 | 7566 | 0.44 |        1233 | 0.35 |     1240 | 0.21 |
| C/C++ Header |        3 | 0.08 |  629 | 0.04 |         396 | 0.11 |     1374 | 0.23 |
| R            |        7 | 0.18 |  250 | 0.01 |          80 | 0.02 |      315 | 0.05 |
| Rmd          |        1 | 0.03 |   54 | 0.00 |          22 | 0.01 |       34 | 0.01 |
| YAML         |        2 | 0.05 |   35 | 0.00 |          10 | 0.00 |        2 | 0.00 |
| SUM          |       19 | 0.50 | 8534 | 0.50 |        1741 | 0.50 |     2965 | 0.50 |

clock Package Metrics for escpos

## Code of Conduct

Please note that this project is released with a Contributor Code of
Conduct. By participating in this project you agree to abide by its
terms.
