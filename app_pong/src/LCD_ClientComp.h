// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>


/**
 * ModuleName LCD Client Component.
 * @Description: Simple LCD Client Component functions. 
 **/


#ifndef _LCD_CLIENT_COMP_H_ 
#define _LCD_CLIENT_COMP_H_ 1

#include "LCD_Comp_Def.h"

// Sets mode of server
XMOS_RTN_t CC_LCD_SetMode(chanend c, unsigned mode);

// Start raw pixel frame
XMOS_RTN_t CC_LCD_StartFrame(chanend c);

// Send one raw pixel
XMOS_RTN_t CC_LCD_WritePixel(chanend c, unsigned pixel);

// Send a raw pixel array
XMOS_RTN_t CC_LCD_WritePixels(chanend c, unsigned pixels[], unsigned numpixels);

// Kill LCD
XMOS_RTN_t CC_LCD_KillServer(chanend c);

#endif /* _LCD_CLIENT_COMP_H_ */


