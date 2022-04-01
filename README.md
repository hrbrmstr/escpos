
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Signed
by](https://img.shields.io/badge/Keybase-Verified-brightgreen.svg)](https://keybase.io/hrbrmstr)
![Signed commit
%](https://img.shields.io/badge/Signed_Commits-100%25-lightgrey.svg)
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

## NOTE

I’ve only tested this on a single, networked EPSON TM-T88V printer.

## Installation

``` r
remotes::install_github("hrbrmstr/ggpos")
```

NOTE: To use the ‘remotes’ install options you will need to have the
[{remotes} package](https://github.com/r-lib/remotes) installed.

## Usage

``` r
library(ggpos)

# current version
packageVersion("ggpos")
## [1] '0.1.0'
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
| C++  |        2 | 0.10 | 114 | 0.25 |          53 | 0.25 |       36 | 0.06 |
| R    |        4 | 0.20 |  54 | 0.12 |          19 | 0.09 |       29 | 0.05 |
| YAML |        2 | 0.10 |  35 | 0.08 |          10 | 0.05 |        2 | 0.00 |
| Rmd  |        1 | 0.05 |  21 | 0.05 |          20 | 0.10 |       33 | 0.06 |
| C    |        1 | 0.05 |   0 | 0.00 |           2 | 0.01 |      177 | 0.32 |
| SUM  |       10 | 0.50 | 224 | 0.50 |         104 | 0.50 |      277 | 0.50 |

clock Package Metrics for ggpos

## Code of Conduct

Please note that this project is released with a Contributor Code of
Conduct. By participating in this project you agree to abide by its
terms.
