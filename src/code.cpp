// // Most of the bits below are from the png2escpos utility C code (copyright below)
// // My only contribution was the consolidation into one function and file output.
// // https://github.com/twg/png2escpos
//
// /*
//  * png2escpos
//  * A converter to turn PNG files into binary data streams suitable
//  * for printing on an Epson Point-Of-Sale thermal printer (ESC/POS format)
//  *
//  * Copyright (c) 2015 The Working Group, Inc. (peter@twg.ca), incorporating
//  * modifications by Michael Billington < michael.billington@gmail.com >
//  *
//  * png2escpos's main conversion algorithm is inspired by work done by
//  * Michael Franzl on his Ruby library, ruby-escper:
//  * https://github.com/michaelfranzl/ruby-escper
//  *
//  * png2escpos is based on an example libpng program, which is
//  * copyright 2002-2010 Guillaume Cottenceau: http://zarb.org/~gc/html/libpng.html
//  * and modified by Yoshimasa Niwa to make it much simpler
//  * and support all defined color_type.
//  *
//  * This software may be freely redistributed under the terms
//  * of the X11 (MIT) license.
//  */
//
// #include <Rcpp.h>
//
// #include <stdlib.h>
// #include <stdio.h>
// #include <png.h>
// #include <stdbool.h>
//
// using namespace Rcpp;
//
// //' @keywords internal
// // [[Rcpp::export]]
// std::string png_to_escpos_raster(std::string png_path, std::string raster_path) {
//
//   int width, height;
//
//   png_byte color_type;
//   png_byte bit_depth;
//   png_bytep *row_pointers;
//
//   FILE *fp = fopen(png_path.c_str(), "rb");
//
//   png_structp png = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
//   if (!png) return("");
//
//   png_infop info = png_create_info_struct(png);
//   if (!info) return("");
//
//   if (setjmp(png_jmpbuf(png))) return("");
//
//   png_init_io(png, fp);
//
//   png_read_info(png, info);
//
//   width      = png_get_image_width(png, info);
//   height     = png_get_image_height(png, info);
//   color_type = png_get_color_type(png, info);
//   bit_depth  = png_get_bit_depth(png, info);
//
//   if (color_type == PNG_COLOR_TYPE_PALETTE) png_set_palette_to_rgb(png);
//
//   // PNG_COLOR_TYPE_GRAY_ALPHA is always 8 or 16bit depth.
//   if (color_type == PNG_COLOR_TYPE_GRAY && bit_depth < 8) png_set_expand_gray_1_2_4_to_8(png);
//
//   if (png_get_valid(png, info, PNG_INFO_tRNS)) png_set_tRNS_to_alpha(png);
//
//   // These color_type don't have an alpha channel then fill it with 0xff.
//   if (color_type == PNG_COLOR_TYPE_RGB ||
//       color_type == PNG_COLOR_TYPE_GRAY ||
//       color_type == PNG_COLOR_TYPE_PALETTE) {
//     png_set_filler(png, 0xFF, PNG_FILLER_AFTER);
//   }
//
//   if (color_type == PNG_COLOR_TYPE_GRAY ||
//       color_type == PNG_COLOR_TYPE_GRAY_ALPHA) {
//     png_set_gray_to_rgb(png);
//   }
//
//   png_read_update_info(png, info);
//
//   row_pointers = (png_bytep*)malloc(sizeof(png_bytep) * height);
//   for (int y = 0; y < height; y++) {
//     row_pointers[y] = (png_byte*)malloc(png_get_rowbytes(png,info));
//   }
//
//   png_read_image(png, row_pointers);
//   png_destroy_info_struct(png, &info);
//
//   fclose(fp);
//
//   fp = fopen(raster_path.c_str(), "wb");
//
//   int mask = 0x80;
//   int i = 0;
//   int temp = 0;
//
//   fputc(0x1D, fp);
//   fputc(0x76, fp);
//   fputc(0x30, fp);
//   fputc(0x00, fp);
//
//   //  Print image dimensions
//   unsigned short headerX = (width + 7) / 8; // width in characters
//   unsigned short headerY = height; // height in pixels
//
//   fputc((headerX >> 0) & 0xFF, fp);
//   fputc((headerX >> 8) & 0xFF, fp);
//   fputc((headerY >> 0) & 0xFF, fp);
//   fputc((headerY >> 8) & 0xFF, fp);
//
//   for (int y = 0; y < height; y++) {
//
//     png_bytep row = row_pointers[y];
//
//     for (int x = 0; x < width; x++) {
//
//       png_bytep px = &(row[x * 4]);
//
//       int value = px[0] + px[1] + px[2];
//
//       if (px[3] < 128) {
//         value = 255;
//       } else if (value > 384) {
//         value = 255;
//       } else {
//         value = 0;
//       }
//
//       value = (value << 8) | value;
//
//       if (value == 0) temp |= mask;
//
//       mask = mask >> 1;
//
//       i++;
//
//       if (i == 8) {
//         fputc(temp, fp);
//         mask = 0x80;
//         i = 0;
//         temp = 0;
//       }
//
//     }
//
//     if (i != 0) {
//       fputc(temp, fp);
//       i = 0;
//     }
//
//   }
//
//   //  Line breaks
//   for (int j = 0; j < 4; j++) fputc(0x0a, fp);
//
//   //  "Cut paper" command
//   // fputc(0x1d);
//   // fputc(0x56);
//   // fputc(0x00);
//
//   fclose(fp);
//
//   return(raster_path);
//
// }