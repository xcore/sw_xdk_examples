/**
 * Module:  freq
 * Version: 1v1
 * Build:   b45a0fb9ab3e66156caa93683e6c6968b24e3366
 * File:    LcdDriver.h
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
#ifndef _LCDDRIVER_H__
#define _LCDDRIVER_H_

void lcd_init(chanend toLCD, out port HSYNC_port, out port DCLK_port, out port DTMG_port, out port RGB_port, out port led);
void lcdDriver(chanend toLCD, out port HSYNC_port, out port DTMG_port, out port RGB_port);


#endif  /* _LCDDRIVER_H_ */

