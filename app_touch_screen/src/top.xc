/**
 * Module:  touch_screen
 * Version: 1v1
 * Build:   b454f88b0e425ad38993188bdace5bbbcdf50276
 * File:    top.xc
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
#include <platform.h>

extern void buttons(chanend c_but);
extern void LcdDriver(chanend c_lcd);
extern void posKeeper(chanend c_adc, chanend c_lcd);
extern void touch(chanend c_tou, chanend c_but);

int main()
{
  chan c_lcd, c_tou;
  chan c_but;
  par
  {
    on stdcore[0] : buttons(c_but);
    on stdcore[3] : touch(c_tou, c_but);
    on stdcore[3] : LcdDriver(c_lcd);
    on stdcore[3] : posKeeper(c_tou, c_lcd);
  }
  return 0;
}
