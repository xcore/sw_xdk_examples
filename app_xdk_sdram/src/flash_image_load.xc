/* File to load image from flash and send to SDRam thread */
#include <xs1.h>
#include <flashlib.h>
#include <flash.h>
#include <print.h>
#include "lcd_defines.h"
#include <platform.h>

//#define DEBUG

unsigned int rgb565(unsigned int r, unsigned int g, unsigned int b)
{
  return (((r>>3) & 0x1F)<<11) | (((g>>2) & 0x3F)<<5) | ((b>>3) & 0x1F);
}

// XDK screen is 666, not 565

unsigned int rgb666(unsigned int r, unsigned int g, unsigned int b)
{
  return (((r>>2) & 0x3F)<<12) | (((g>>2) & 0x3F)<<6) | ((b>>2) & 0x3F);
}


on stdcore[0]: fl_SPIPorts p_flash = {
    XS1_PORT_1A,
    XS1_PORT_1B,
    XS1_PORT_1C,
    XS1_PORT_1D,
    XS1_CLKBLK_5
};


void flash_image_load(chanend c_flash, chanend c_lcd_ready) {
  unsigned char buf[LCD_WIDTH * 3]; // needs to hold up to lcd_width * 3 bytes per pixel of chars
  unsigned int intbuf[LCD_ROW_WORDS]; // int encoding of charbuf
  unsigned int bfOffBits;
  unsigned int img_width;
  int img_size;
  int height;
  unsigned int bitsPerPixel;
  unsigned int pixelNum;
  unsigned int numBytesRead;
  unsigned int data_offset = 0;
  unsigned int img_base_offset = 0;
  int i;
  unsigned int panel_size;
  // Code copied from XDK splash loader.

  // Initialise the buffer to an obvious colour
  for (int i=0; i< LCD_ROW_WORDS; i++) {
    intbuf[i] = LCD_RED;
  }

  fl_connect(p_flash);


  // Flash can access at random, not like file system.
    fl_readStore(0, 10, buf);

    data_offset += 10;

    // check its a bmp file
    if ((buf[0] != 'B') || (buf[1] != 'M'))
    {
#ifdef DEBUG
      printstrln("Error - invalid bitmap\n");
#endif
    }


    // Next read header:

    fl_readStore(data_offset, 40, buf);
    data_offset += 40;

    bfOffBits = 0;
    for (i=4; i>=0; i--)
    {
      bfOffBits = (bfOffBits << 8) | buf[i];
    }
    img_width = 0;
    for (i=12; i>=8; i--)
    {
      img_width = (img_width << 8) | buf[i];
    }

    height = 0;
    for (i=16; i>=12; i--)
    {
      height = (height << 8) | buf[i];
    }

#ifdef DEBUG
    printintln(height);
    printintln(img_width);
#endif

    bitsPerPixel = 0;
    for (i=20; i>=18; i--)
    {
      bitsPerPixel = (bitsPerPixel << 8) | buf[i];
    }

    if (bitsPerPixel != 24)
    {
      printstrln( "Error. bitsPerPixel must be 24");
      printintln(bitsPerPixel);
    }

    // read until start of pixels - already read 50 bytes
    data_offset += bfOffBits-50;
    img_base_offset = data_offset;
    // read pixels - write to sram
    pixelNum = 0;
    numBytesRead = 1;
    // bytes to read = image size? No - 24 bits per pixel or 3 bytes.

    panel_size = LCD_HEIGHT * LCD_WIDTH * 3; //size in bytes.
    img_size = img_width * height * 3;

    for (int i = 0; i < height; i++)
    {
      int buf_addr = LCD_ROW_WORDS - 1;

      // Need to block on SD thread being ready.
      // Read 3 bytes for each pixel

      fl_readStore(data_offset, img_width *3, buf);
      data_offset += img_width *3;
      if (data_offset > (img_size+img_base_offset)) {
        data_offset = img_base_offset; // start sending image again.
      }

#ifdef LCD_565
      // TODO - image will currently be flipped L/R. change to match 666 case
      for (int k=0; k < img_width *3; k += 6) {
        intbuf[buf_addr++] = (rgb565(buf[k+0], buf[k+1], buf[k+2]) ) | (rgb565(buf[k+3], buf[k+4], buf[k+5])<<16) ; // storing 6 bytes of read data into 2 words
      }
#else
      for (int k=0; k < img_width *3; k += 3) {
        intbuf[buf_addr--] = (rgb666(buf[k+0], buf[k+1], buf[k+2]) );
      }
#endif

      // Having read a row, tell SD thread we are ready to send it.
      // LCD pixel is addressed right to left, so flip image here to get correct L/R
      c_flash <: 0;
    c_flash :> int _;
      for (int j=0; j< (LCD_ROW_WORDS); j++ ) {
        c_flash <: intbuf[j] ;
      }
    }
    // Signal to LCD thread ready to go:
    c_lcd_ready <: 1;
    while (1); // allow debug of this thread as variables still available.
}
