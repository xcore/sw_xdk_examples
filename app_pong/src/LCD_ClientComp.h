/**
 * Module:  pong
 * Version: 1v1
 * Build:   09eb107119f1beff657cf7dc11fdadf918468539
 * File:    LCD_ClientComp.h
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


