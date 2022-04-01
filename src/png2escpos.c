/*
 * png2escpos
 * A converter to turn PNG files into binary data streams suitable
 * for printing on an Epson Point-Of-Sale thermal printer (ESC/POS format)
 *
 * Copyright (c) 2015 The Working Group, Inc. (peter@twg.ca), incorporating
 * modifications by Michael Billington < michael.billington@gmail.com >
 *
 * png2escpos's main conversion algorithm is inspired by work done by
 * Michael Franzl on his Ruby library, ruby-escper:
 * https://github.com/michaelfranzl/ruby-escper
 *
 * png2escpos is based on an example libpng program, which is
 * copyright 2002-2010 Guillaume Cottenceau: http://zarb.org/~gc/html/libpng.html
 * and modified by Yoshimasa Niwa to make it much simpler
 * and support all defined color_type.
 *
 * This software may be freely redistributed under the terms
 * of the X11 (MIT) license.
 */

// #include <stdlib.h>
// #include <stdio.h>
// #include <png.h>
// #include <stdbool.h>
//
// std::string png_to_escpos_raster(char *filename) {
//
//   int width, height;
//
//   png_byte color_type;
//   png_byte bit_depth;
//   png_bytep *row_pointers;
//
//   FILE *fp = fopen(filename, "rb");
//
//   png_structp png = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
//   if (!png) return("")
//
//   png_infop info = png_create_info_struct(png);
//   if (!info) abort();
//
//   if (setjmp(png_jmpbuf(png))) abort();
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
//   if(color_type == PNG_COLOR_TYPE_PALETTE)
//     png_set_palette_to_rgb(png);
//
//   // PNG_COLOR_TYPE_GRAY_ALPHA is always 8 or 16bit depth.
//   if(color_type == PNG_COLOR_TYPE_GRAY && bit_depth < 8)
//     png_set_expand_gray_1_2_4_to_8(png);
//
//   if(png_get_valid(png, info, PNG_INFO_tRNS))
//     png_set_tRNS_to_alpha(png);
//
//   // These color_type don't have an alpha channel then fill it with 0xff.
//   if(color_type == PNG_COLOR_TYPE_RGB ||
//      color_type == PNG_COLOR_TYPE_GRAY ||
//      color_type == PNG_COLOR_TYPE_PALETTE)
//     png_set_filler(png, 0xFF, PNG_FILLER_AFTER);
//
//   if(color_type == PNG_COLOR_TYPE_GRAY ||
//      color_type == PNG_COLOR_TYPE_GRAY_ALPHA)
//     png_set_gray_to_rgb(png);
//
//   png_read_update_info(png, info);
//
//   row_pointers = (png_bytep*)malloc(sizeof(png_bytep) * height);
//   for(int y = 0; y < height; y++) {
//     row_pointers[y] = (png_byte*)malloc(png_get_rowbytes(png,info));
//   }
//
//   png_read_image(png, row_pointers);
//   png_destroy_info_struct(png, &info);
//
//   fclose(fp);
//
//   fp = tmpfile();
//
//   int mask = 0x80;
//   int i = 0;
//   int temp = 0;
//
//   putchar(0x1D);
//   putchar(0x76);
//   putchar(0x30);
//   putchar(0x00);
//
//   //  Print image dimensions
//   unsigned short headerX = (width + 7) / 8; // width in characters
//   unsigned short headerY = height; // height in pixels
//
//   putchar((headerX >> 0) & 0xFF);
//   putchar((headerX >> 8) & 0xFF);
//   putchar((headerY >> 0) & 0xFF);
//   putchar((headerY >> 8) & 0xFF);
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
//         putchar(temp);
//         mask = 0x80;
//         i = 0;
//         temp = 0;
//       }
//
//     }
//
//     if (i != 0) {
//       putchar(temp);
//       i = 0;
//     }
//
//   }
//
//   //  Line breaks
//   for (int j = 0; j < 4; j++) putchar(0x0a);
//
//   //  "Cut paper" command
//   // putchar(0x1d);
//   // putchar(0x56);
//   // putchar(0x00);
//
//   fclose(fp);
//
// }

// int main(int argc, char *argv[]) {
//   if (argc != 2) {
//     printf("png2escpos v0.2 - converts PNGs into Epson ESC/POS format.\n");
//     printf("Copyright (c) 2015 The Working Group, Inc., incorporating \n");
//     printf("modifications by Michael Billington\n");
//     printf("\n");
//     printf("Usage: %s <file.png>\n", argv[0]);
//     printf("Binary output in ESC/POS format will be written directly to stdout.\n");
//     printf("\n");
//     printf("You can pipe this output directly into an Epson printer with:\n");
//     printf("\tLinux:    %s <file.png> > /dev/usb/lp0\n", argv[0]);
//     printf("\tMac OS X: %s <file.png> | lpr -P NAME_OF_PRINTER\n", argv[0]);
//     return 1;
//   }
//
//   read_png_file(argv[1]);
//   process_png_file();
//
//   return 0;
// }
