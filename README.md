
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Signed
by](https://img.shields.io/badge/Keybase-Verified-brightgreen.svg)](https://keybase.io/hrbrmstr)
![Signed commit
%](https://img.shields.io/badge/Signed_Commits-67%25-lightgrey.svg)
[![R-CMD-check](https://github.com/hrbrmstr/ggpos/workflows/R-CMD-check/badge.svg)](https://github.com/hrbrmstr/ggpos/actions?query=workflow%3AR-CMD-check)
[![Linux build
Status](https://travis-ci.org/hrbrmstr/ggpos.svg?branch=master)](https://travis-ci.org/hrbrmstr/ggpos)
[![Coverage
Status](https://codecov.io/gh/hrbrmstr/ggpos/branch/master/graph/badge.svg)](https://codecov.io/gh/hrbrmstr/ggpos)
![Minimal R
Version](https://img.shields.io/badge/R%3E%3D-3.6.0-blue.svg)
![License](https://img.shields.io/badge/License-MIT-blue.svg)

# ggpos

Print {ggplot2} or {grid} Objects to ESC/POS Compatible Network Devices

## Description

ESC/POS devices, such as receipt printers, have the ability to print
their own form of raster bitmap graphics. Tools are provided to turn
{ggplot2} or {grid} objects into such raster bitmaps and print them to
ESC/POS compatible devices.

## What’s Inside The Tin

The following functions are implemented:

-   `escpos`: Create an escpos object for accumulating print commands
-   `pos_cr`: Send a CR to the printer
-   `pos_cut`: Issue a partial or full cut command to the printer
-   `pos_ff`: Send a FF to the printer
-   `pos_ht`: Send a HT to the printer
-   `pos_lf`: Send a LF to the printer
-   `pos_plaintext`: Send plaintext to the printer
-   `pos_print`: Send collected print commands to the printer
-   `pos_vt`: Send a VT to the printer
-   `ggpos`: Print a ggplot (or other grid object) to an ESC/POS
    compatible network device with sensible defaults

## NOTE

I’ve only tested this on a single, networked EPSON TM-T88V printer.

## Installation

``` r
remotes::install_github("hrbrmstr/ggpos", ref = "batman")
```

## Usage

``` r
library(ggpos)

# current version
packageVersion("ggpos")
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

| Lang | \# Files |  (%) | LoC |  (%) | Blank lines |  (%) | \# Lines |  (%) |
|:-----|---------:|-----:|----:|-----:|------------:|-----:|---------:|-----:|
| R    |        7 | 0.27 | 184 | 0.26 |          47 | 0.18 |      254 | 0.25 |
| C++  |        2 | 0.08 | 114 | 0.16 |          53 | 0.20 |       36 | 0.04 |
| YAML |        2 | 0.08 |  35 | 0.05 |          10 | 0.04 |        2 | 0.00 |
| Rmd  |        1 | 0.04 |  21 | 0.03 |          21 | 0.08 |       34 | 0.03 |
| C    |        1 | 0.04 |   0 | 0.00 |           2 | 0.01 |      177 | 0.18 |
| SUM  |       13 | 0.50 | 354 | 0.50 |         133 | 0.50 |      503 | 0.50 |

clock Package Metrics for ggpos

## Code of Conduct

Please note that this project is released with a Contributor Code of
Conduct. By participating in this project you agree to abide by its
terms.
