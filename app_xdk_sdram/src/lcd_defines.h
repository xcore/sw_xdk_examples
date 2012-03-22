#ifndef __LCD_DEFINES_H__
#define __LCD_DEFINES_H__

/* Defines for LCD panel */

#define LCD_WIDTH 240
#define LCD_HEIGHT 320

//#define LCD_565
// 565 colour encoding can fit 2 pixels into a word for storage.
#ifdef LCD_565
#define LCD_ROW_WORDS (LCD_WIDTH/2)
#else
#define LCD_ROW_WORDS LCD_WIDTH
#endif

// LCD Timing defines
#define T_HFP                 280 // 400
#define T_HBP                 620 //600
#define T_WH                  150 // 150
#define T_VBP                 20000 //20000
#define LCD_CLKDIV            20

// LCD ports
#define LCD_PORT_HSYNC        XS1_PORT_4F    /* !! 4F on XDK !! */
#define LCD_PORT_DTMG         XS1_PORT_1B
#define LCD_PORT_DCLK         XS1_PORT_1A
#define LCD_PORT_RGB          XS1_PORT_32A

// LCD clockblock
#define LCD_CLKBLK            XS1_CLKBLK_4

// Some useful colour defines for 666 displays
#define LCD_WHITE             0x3ffff
#define LCD_BLACK             0x00000
#define LCD_RED               0x3f000 // screen goes blue.
#define LCD_GREEN             0x0FC00
#define LCD_BLUE              0x0003F // screen goes red.
#define LCD_TEAL              0x0FFFF // yellow
#define LCD_YELLOW            0x3FFC0 // teal

#define BURST 256
#define BURST_MASK (BURST - 1)


#endif
