/**
 * Module:  pong
 * Version: 1v1
 * Build:   09eb107119f1beff657cf7dc11fdadf918468539
 * File:    LCD_Comp_Def.h
 *
 * The copyrights, all other intellectual and industrial 
 * property rights are retained by XMOS and/or its licensors. 
 * Terms and conditions covering the use of this code can
 * be found in the Xmos End User License Agreement.
 *
 * Copyright XMOS Ltd 2010
 *
 * In the case where this code is a modification of existing code
 * under a separate license, the separate license terms are shown
 * below. The modifications to the code are still covered by the 
 * copyright notice above.
 *
 **/                                   
/**
 * @ModuleName Generic LCD Common Client/Server Component definations.
 * @Description: Generic LCD Common Client/Server Component definations.
 **/

#ifndef _LCD_COMP_DEF_H_
#define _LCD_COMP_DEF_H_ 1

#include <xs1.h>

typedef enum
{
   XMOS_SUCCESS = 0,    // Success
   XMOS_FAIL,           // Fail
   XMOS_INVALID_PARA,   // Invalid parameter
   XMOS_TIME_OUT,       // Time out
   XMOS_RES_UNAVB,      // Resource unavaliable
   XMOS_ACK,            // acknowledged.
   XMOS_NACK            // negative acknowledged
} XMOS_RTN_t;

// LCD Timing defines
#define T_HFP                 750
#define T_HBP                 650
#define T_WH                  250
#define T_VBP                 35000
#define LCD_CLKDIV            30

#define LCD_WIDTH_PX          240
#define LCD_HEIGHT_PX         320

// Supported resposes
#define LCD_RESP_ACK          0x80000001
#define LCD_RESP_NACK         0x80000002

// | BLUE | GREEN | RED |

// Some useful colour defines
#define LCD_WHITE             0x3ffff
#define LCD_BLACK             0x00000
#define LCD_RED               0x0003f
#define LCD_GREEN             0x0FC00
#define LCD_BLUE              0x3f000
#define LCD_YELLOW            0x0FFFF
#define LCD_TEAL              0x3FFC0

// RGB (BGR!)565 colour defines
#define LCD_565_RED           0x001F
#define LCD_565_BLUE        0xf800
#define LCD_565_GREEN       0x07e0
#define LCD_565_BLACK       0

// Default foreground colour
#define LCD_DEFAULT_FG        LCD_WHITE


#endif /* _LCD_COMP_DEF_H */






