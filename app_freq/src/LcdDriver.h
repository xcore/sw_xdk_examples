// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#ifndef _LCDDRIVER_H__
#define _LCDDRIVER_H_

void lcd_init(chanend toLCD, out port HSYNC_port, out port DCLK_port, out port DTMG_port, out port RGB_port, out port led);
void lcdDriver(chanend toLCD, out port HSYNC_port, out port DTMG_port, out port RGB_port);


#endif  /* _LCDDRIVER_H_ */

