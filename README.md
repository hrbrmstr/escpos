
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Signed
by](https://img.shields.io/badge/Keybase-Verified-brightgreen.svg)](https://keybase.io/hrbrmstr)
![Signed commit
%](https://img.shields.io/badge/Signed_Commits-100%25-lightgrey.svg)
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
-   `pos_cr`: Send a CR to the printer
-   `pos_cut`: Issue a partial or full cut command to the printer
-   `pos_ff`: Send a FF to the printer
-   `pos_ht`: Send a HT to the printer
-   `pos_lf`: Send a LF to the printer
-   `pos_plaintext`: Send plaintext to the printer
-   `pos_print`: Send collected print commands to the printer
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
library(ggplot2)

# current version
packageVersion("escpos")
## [1] '0.2.0'
```

``` r
ggplot(mtcars) +
  geom_point(
    aes(wt, mpg)
  ) +
  labs(
    title = "Test of {ggpos}"
  ) +
  theme_ipsum_es(grid="XY") +
  theme(
    panel.grid.major.x = element_line(color = "black"),
    panel.grid.major.y = element_line(color = "black")
  ) -> gg

ggpos(gg, host_pos = HOSTNAME_OR_IP_ADDRESS_OF_YOUR_PRINTER)
```

![](man/figures/IMG_0217.png)

## ggpos Metrics

| Lang         | \# Files |  (%) |  LoC |  (%) | Blank lines |  (%) | \# Lines |  (%) |
|:-------------|---------:|-----:|-----:|-----:|------------:|-----:|---------:|-----:|
| C++          |        7 | 0.17 | 7566 | 0.45 |        1233 | 0.36 |     1414 | 0.23 |
| C/C++ Header |        3 | 0.07 |  629 | 0.04 |         396 | 0.12 |     1374 | 0.22 |
| R            |        7 | 0.17 |  186 | 0.01 |          47 | 0.01 |      261 | 0.04 |
| YAML         |        2 | 0.05 |   35 | 0.00 |          10 | 0.00 |        2 | 0.00 |
| Rmd          |        1 | 0.03 |   22 | 0.00 |          20 | 0.01 |       34 | 0.01 |
| SUM          |       20 | 0.50 | 8438 | 0.50 |        1706 | 0.50 |     3085 | 0.50 |

clock Package Metrics for escpos

## Code of Conduct

Please note that this project is released with a Contributor Code of
Conduct. By participating in this project you agree to abide by its
terms.
