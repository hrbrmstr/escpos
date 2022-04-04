#include <Rcpp.h>

using namespace Rcpp;

#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <unistd.h>
#include "lodepng.h"

#ifdef LODEPNG_NO_COMPILE_ALLOCATORS
/* modified lodepng allocators */

void *lodepng_malloc(size_t size) {
    /* for security reason I use calloc instead of malloc;
       here we redefine lodepng allocator */
    return calloc(size, 1);
}

void *lodepng_realloc(void *ptr, size_t new_size) {
    return realloc(ptr, new_size);
}

void lodepng_free(void *ptr) {
    free(ptr);
}
#endif

/* number of dots/lines in vertical direction in one F112 command
   set GS8L_MAX_Y env. var. to <= 128u for Epson TM-J2000/J2100
   default value is 1662, TM-T70, TM-T88 etc. */
#ifndef GS8L_MAX_Y
#define GS8L_MAX_Y 1662
#endif

/* max image width printer is able to process;
   printer_max_width must be divisible by 8!! */
#ifndef PRINTER_MAX_WIDTH
#define PRINTER_MAX_WIDTH 512u
#endif

struct dithering_matrix {
    int dx; /* x-offset */
    int dy; /* y-offset */
    int v; /* error = v * 1/1,024th of value */
};

struct app_config {
    unsigned int cut;
    unsigned int photo;
    char align;
    unsigned int rotate;
    const char *output;
    unsigned int gs8l_max_y;
    unsigned int printer_max_width;
    unsigned int speed;
};

/* app configuration */
struct app_config config = {
    .cut = 0,
    .photo = 0,
    .align = '?',
    .rotate = 0,
    .output = NULL,
    .gs8l_max_y = GS8L_MAX_Y,
    .printer_max_width = PRINTER_MAX_WIDTH,
    .speed = 0
};

unsigned char s_add_to_byte(unsigned char v, int d) {
    int a = v + d;
    if (a > 0xff) {
        a = 0xff;
    } else if (a < 0) {
        a = 0;
    }
    return a;
}

//' @keywords internal
// [[Rcpp::export]]
std::string png_to_escpos_raster(std::string png_file, std::string raster_path, bool color = false) {

  unsigned char *img_rgba = NULL;
  unsigned char *img_grey = NULL;
  unsigned char *img_bw = NULL;

  config.photo = color ? 1 : 0;
  config.printer_max_width &= ~0x7u;

  FILE *fout = fopen(raster_path.c_str(), "wb");
  setvbuf(fout, NULL, _IOFBF, 8192);

  const unsigned char ESC_INIT[2] = {
      /* ESC @, Initialize printer, p. 412 */
      0x1b, 0x40
  };

  fwrite(ESC_INIT, 1, sizeof ESC_INIT, fout);
  fflush(fout);

  const char *input = png_file.c_str();

  /* load RGBA PNG */
  unsigned int img_w = 0;
  unsigned int img_h = 0;
  unsigned int lodepng_error = lodepng_decode32_file(&img_rgba,
                                                     &img_w, &img_h, input);

  if (lodepng_error) {
    // fprintf(stderr, "Could not load and process input PNG file, %s\n",
    //         lodepng_error_text(lodepng_error));
    return("");
  }

  if (img_w > config.printer_max_width) {
    // fprintf(stderr, "Image width %u px exceeds the printer's"
    //           " capability (%u px)\n", img_w, config.printer_max_width);
    return("");
  }

  unsigned int histogram[256] = { 0 };

  /* convert RGBA to greyscale */
  unsigned int img_grey_size = img_h * img_w;

  img_grey = (unsigned char *)calloc(img_grey_size, 1);
  if (!img_grey) {
    // fprintf(stderr, "Could not allocate enough memory\n");
    return("");// goto fail;
  }

  for (unsigned int i = 0; i != img_grey_size; ++i) {
    /* A */
    unsigned int a = img_rgba[(i << 2) | 3];

    /* RGBA → RGB → L* */
    unsigned int r = (255 - a) + a / 255 * img_rgba[i << 2];
    unsigned int g = (255 - a) + a / 255 * img_rgba[(i << 2) | 1];
    unsigned int b = (255 - a) + a / 255 * img_rgba[(i << 2) | 2];
    unsigned int L = (55 * r + 182 * g + 18 * b) / 255;

    img_grey[i] = L;

    /* prepare a histogram for HEA */
    ++histogram[img_grey[i]];
  }

  free(img_rgba);
  img_rgba = NULL;

  {
    /* -p hints */
    unsigned int colors = 0;

    for (unsigned int i = 0; i != 256; ++i) {
      if (histogram[i]) {
        ++colors;
      }
    }
    if (colors < 16 && config.photo) {
      fprintf(stderr, "Image seems to be B/W. -p is probably"
                " not good option this time\n");
    }
    if (colors >= 16 && !config.photo) {
      fprintf(stderr, "Image seems to be greyscale or colored."
                " Maybe you should use option -p for better results\n");
    }
  }

  /* post-processing convert to B/W bitmap */
  if (config.photo) {
    /* Histogram Equalization Algorithm */
    for (unsigned int i = 1; i != 256; ++i) {
      histogram[i] += histogram[i - 1];
    }
    for (unsigned int i = 0; i != img_grey_size; ++i) {
      img_grey[i] = 255 * histogram[img_grey[i]] / img_grey_size;
    }

    /* Jarvis, Judice, and Ninke Dithering
     http://www.tannerhelland.com/4660/
     dithering-eleven-algorithms-source-code/

     In the same year that Floyd and Steinberg published their
     famous dithering algorithm, a lesser-known – but much more
     powerful – algorithm was also published. With this
     algorithm, the error is distributed to three times as many
     pixels as in Floyd-Steinberg, leading to much smoother –
     and more subtle – output. */
    const struct dithering_matrix dithering_matrix[12] = {
      /* for simplicity of computation, all standard dithering
       formulas push the error forward, never backward */
      {.dx =  1, .dy = 0, .v = 149 /* 1024 * 7 / 48 */},
      {.dx =  2, .dy = 0, .v = 107 /* 1024 * 5 / 48 */},
      {.dx = -2, .dy = 1, .v =  64 /* 1024 * 3 / 48 */},
      {.dx = -1, .dy = 1, .v = 107 /* 1024 * 5 / 48 */},
      {.dx =  0, .dy = 1, .v = 149 /* 1024 * 7 / 48 */},
      {.dx =  1, .dy = 1, .v = 107 /* 1024 * 5 / 48 */},
      {.dx =  2, .dy = 1, .v =  64 /* 1024 * 3 / 48 */},
      {.dx = -2, .dy = 2, .v =  21 /* 1024 * 1 / 48 */},
      {.dx = -1, .dy = 2, .v =  64 /* 1024 * 3 / 48 */},
      {.dx =  0, .dy = 2, .v = 107 /* 1024 * 5 / 48 */},
      {.dx =  1, .dy = 2, .v =  64 /* 1024 * 3 / 48 */},
      {.dx =  2, .dy = 2, .v =  21 /* 1024 * 1 / 48 */}
    };

    for (unsigned int i = 0; i != img_grey_size; ++i) {
      unsigned int o = img_grey[i];
      unsigned int n = o <= 0x80 ? 0x00 : 0xff;

      int x = i % img_w;
      int y = i / img_w;

      img_grey[i] = n;
      for (unsigned int j = 0; j != 12; ++j) {
        int x0 = x + dithering_matrix[j].dx;
        int y0 = y + dithering_matrix[j].dy;

        if (x0 > (int) img_w - 1 || x0 < 0
              || y0 > (int) img_h - 1 || y0 < 0) {

          continue;
        }
        /* the residual quantization error, warning: !have to
         overcast to signed int before calculation! */
        int d = (int) (o - n) * dithering_matrix[j].v / 1024;

        /* keep a value in the <min; max> interval */
        img_grey[x0 + img_w * y0] =
        s_add_to_byte(img_grey[x0 + img_w * y0], d);
      }
    }
  }
  /* canvas size is width of printable area */
  unsigned int canvas_w = config.printer_max_width;

  unsigned int img_bw_size = img_h * (canvas_w >> 3);

  img_bw = (unsigned char *)calloc(img_bw_size, 1);
  if (!img_bw) {
    fprintf(stderr, "Could not allocate enough memory\n");
  }

  /* align rotated image to the right border */
  if (config.rotate && config.align == '?') {
    config.align = 'R';
  }

  /* left offset */
  unsigned int offset = 0;

  switch (config.align) {
  case 'C':
    offset = (canvas_w - img_w) / 2;
    break;

  case 'R':
    offset = canvas_w - img_w;
    break;

  case 'L':
  case '?':
  default:
    offset = 0;
  }

  /* compress bytes into bitmap */
  for (unsigned int i = 0; i != img_grey_size; ++i) {
    unsigned int idx = config.rotate ? img_grey_size - 1 - i : i;

    if (img_grey[idx] <= 0x80) {
      unsigned int x = i % img_w + offset;
      unsigned int y = i / img_w;

      img_bw[(y * canvas_w + x) >> 3] |= 0x80 >> (x & 0x07);
    }
  }

  free(img_grey);
  img_grey = NULL;

  /* chunking, l = lines already printed, currently processing a
   chunk of height k */
  for (unsigned int l = 0, k = config.gs8l_max_y; l < img_h; l += k) {

    if (k > img_h - l) {
      k = img_h - l;
    }

    const unsigned int f112_p = 10 + k * (canvas_w >> 3);
    unsigned char ESC_STORE[17];

    ESC_STORE[ 0] = 0x1d; /* GS 8 L, Store the graphics data in the print buffer (raster format), p. 252 */
    ESC_STORE[ 1] = 0x38;
    ESC_STORE[ 2] = 0x4c;
    ESC_STORE[ 3] = f112_p & 0xff; /* p1 p2 p3 p4 */
    ESC_STORE[ 4] = f112_p >> 8 & 0xff;
    ESC_STORE[ 5] = f112_p >> 16 & 0xff;
    ESC_STORE[ 6] = f112_p >> 24 & 0xff;
    ESC_STORE[ 7] = 0x30; /* Function 112 */
    ESC_STORE[ 8] = 0x70;
    ESC_STORE[ 9] = 0x30;
    ESC_STORE[10] = 0x01; /* bx by, zoom */
    ESC_STORE[11] = 0x01;
    ESC_STORE[12] = 0x31; /* c, single-color printing model */
    ESC_STORE[13] = canvas_w & 0xff; /* xl, xh, number of dots in the horizontal direction */
    ESC_STORE[14] = canvas_w >> 8 & 0xff;
    ESC_STORE[15] = k & 0xff; /* yl, yh, number of dots in the vertical direction */
    ESC_STORE[16] = k >> 8 & 0xff;


    // unsigned char ESC_STORE[17] = {
    //   /* GS 8 L, Store the graphics data in the print buffer
    //    (raster format), p. 252 */
    //   0x1d, 0x38, 0x4c,
    //   /* p1 p2 p3 p4 */
    //   f112_p & 0xff, f112_p >> 8 & 0xff, f112_p >> 16 & 0xff,
    //   f112_p >> 24 & 0xff,
    //   /* Function 112 */
    //   0x30, 0x70, 0x30,
    //   /* bx by, zoom */
    //   0x01, 0x01,
    //   /* c, single-color printing model */
    //   0x31,
    //   /* xl, xh, number of dots in the horizontal direction */
    //   canvas_w & 0xff, canvas_w >> 8 & 0xff,
    //   /* yl, yh, number of dots in the vertical direction */
    //   k & 0xff, k >> 8 & 0xff
    // };
    fwrite(ESC_STORE, 1, sizeof ESC_STORE, fout);
    fwrite(&img_bw[l * (canvas_w >> 3)], 1, k * (canvas_w >> 3), fout);

    const unsigned char ESC_FLUSH[7] = {
      /* GS ( L, Print the graphics data in the print buffer,
       p. 241 Moves print position to the left side of the
       print area after printing of graphics data is
       completed */
      0x1d, 0x28, 0x4c, 0x02, 0x00, 0x30,
      /* Fn 50 */
      0x32
    };
    fwrite(ESC_FLUSH, 1, sizeof ESC_FLUSH, fout);
    fflush(fout);
  }

  free(img_bw);
  img_bw = NULL;

  free(img_rgba);
  img_rgba = NULL;

  free(img_grey);
  img_grey = NULL;

  free(img_bw);
  img_bw = NULL;

  if (fout && fout != stdout) {
    fclose(fout);
    fout = NULL;
  }

  return(raster_path);

}


