# via: https://github.com/Simonefardella/escposprinter/blob/master/escposprinter/constants.py

# Feed control sequences
CTL_LF <- as.raw(c(0x0a)) # Line feed
CTL_FF <- as.raw(c(0x0c)) # Form feed
CTL_CR <- as.raw(c(0x0d)) # Carriage return
CTL_HT <- as.raw(c(0x09)) # Horizontal tab
CTL_VT <- as.raw(c(0x0b)) # Vertical tab

# Printer hardware
HW_INIT   <- as.raw(c(0x1b,0x40))           # Clear data in buffer and reset modes
HW_SELECT <- as.raw(c(0x1b,0x3d,0x01))      # Printer select
HW_RESET  <- as.raw(c(0x1b,0x3f,0x0a,0x00)) # Reset printer hardware

# Cash Drawer
CD_KICK_2  <- as.raw(c(0x1b,0x70,0x00))     # Sends a pulse to pin 2 []
CD_KICK_5  <- as.raw(c(0x1b,0x70,0x01))     # Sends a pulse to pin 5 []

# Paper
PAPER_FULL_CUT  <- as.raw(c(0x1d,0x56,0x00)) # Full cut paper
PAPER_PART_CUT  <- as.raw(c(0x1d,0x56,0x01)) # Partial cut paper

# Text format
BARCODE_TXT_OFF  <- as.raw(c(0x1d,0x48,0x00)) # HRI barcode chars OFF
BARCODE_TXT_ABV  <- as.raw(c(0x1d,0x48,0x01)) # HRI barcode chars above
BARCODE_TXT_BLW  <- as.raw(c(0x1d,0x48,0x02)) # HRI barcode chars below
BARCODE_TXT_BTH  <- as.raw(c(0x1d,0x48,0x03)) # HRI barcode chars both above and below
BARCODE_FONT_A   <- as.raw(c(0x1d,0x66,0x00)) # Font type A for HRI barcode chars
BARCODE_FONT_B   <- as.raw(c(0x1d,0x66,0x01)) # Font type B for HRI barcode chars
BARCODE_HEIGHT   <- as.raw(c(0x1d,0x68,0x64)) # Barcode Height [1-255]
BARCODE_WIDTH    <- as.raw(c(0x1d,0x77,0x03)) # Barcode Width  [2-6]
BARCODE_UPC_A    <- as.raw(c(0x1d,0x6b,0x00)) # Barcode type UPC-A
BARCODE_UPC_E    <- as.raw(c(0x1d,0x6b,0x01)) # Barcode type UPC-E
BARCODE_EAN13    <- as.raw(c(0x1d,0x6b,0x02)) # Barcode type EAN13
BARCODE_EAN8     <- as.raw(c(0x1d,0x6b,0x03)) # Barcode type EAN8
BARCODE_CODE39   <- as.raw(c(0x1d,0x6b,0x04)) # Barcode type CODE39
BARCODE_ITF      <- as.raw(c(0x1d,0x6b,0x05)) # Barcode type ITF
BARCODE_NW7      <- as.raw(c(0x1d,0x6b,0x06)) # Barcode type NW7
BARCODE_CENTERED <- as.raw(c(0x1b,0x61,0x01)) # Barcode Centered, needs tests

# Image format
S_RASTER_N  <- as.raw(c(0x1d,0x76,0x30,0x00)) # Set raster image normal size
S_RASTER_2W <- as.raw(c(0x1d,0x76,0x30,0x01)) # Set raster image double width
S_RASTER_2H <- as.raw(c(0x1d,0x76,0x30,0x02)) # Set raster image double height
S_RASTER_Q  <- as.raw(c(0x1d,0x76,0x30,0x03)) # Set raster image quadruple

RESET = as.raw(c(0x1b,0x40))

list(

  'bold' = list(
    'off' = as.raw(c(0x1b, 0x45, 0x00)), # Bold font OFF
     'on' = as.raw(c(0x1b, 0x45, 0x01))  # Bold font ON
  ),

  'underline'= list(
     'off' = as.raw(c(0x1b,0x2d,0x00)), # Underline font OFF
    '1dot' = as.raw(c(0x1b,0x2d,0x01)), # Underline font 1-dot ON
    '2dot' = as.raw(c(0x1b,0x2d,0x02))  # Underline font 2-dot ON
  ),

  'size' = list(
    'normal' = as.raw(c(0x1b,0x21,0x00)), # Normal text
        '2h' = as.raw(c(0x1b,0x21,0x10)), # Double height text
        '2w' = as.raw(c(0x1b,0x21,0x20)), # Double width text
        '2x' = as.raw(c(0x1b,0x21,0x30))  # Quad area text
  ),

  'font' = list(
    'a' = as.raw(c(0x1b,0x4d,0x00)), # Font type A
    'b' = as.raw(c(0x1b,0x4d,0x01)), # Font type B
    'c' = as.raw(c(0x1b,0x4d,0x02))  # Font type C (may not support)
  ),

  'align' = list(
      'left' = as.raw(c(0x1b,0x61,0x00)), # Left justification
     'right' = as.raw(c(0x1b,0x61,0x02)), # Right justification
    'center' = as.raw(c(0x1b,0x61,0x01))  # Centering
  ),

  'inverted' = list(
     'true' = as.raw(c(0x1d,0x42,0x00)), # Inverted mode ON
    'false' = as.raw(c(0x1d,0x42,0x01))  # Inverted mode OFF
  ),

  'color' = list(
    'col1' = as.raw(c(0x1b,0x72,0x00)), # Select 1st printing color
    'col2' = as.raw(c(0x1b,0x72,0x00))  # Select 2nd printing color
  )

) -> TEXT_STYLE
