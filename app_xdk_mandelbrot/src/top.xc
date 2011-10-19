// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <platform.h>

extern void createMandelbrot(chanend c_lcd,
								chanend cmbrot0, chanend cmbrot1, chanend cmbrot2, chanend cmbrot3,
								chanend cmbrot4, chanend cmbrot5, chanend cmbrot6, chanend cmbrot7,
								chanend cb, chanend c_xlog);
extern void mandelbrotfarm_fini(chanend c);
extern void mandelbrotfarm(chanend c);
extern void mandelbrot_lrsd_server_core0_fini(chanend c_sram, chanend c_lcd);
extern void mandelbrot_lrsd_server_core3_fini(chanend c_lcd);
extern void getButtonData(chanend pollChan);

int main()
{
  // Channel declarations
  chan c_lcd_gfx, c_lcd_txt;
  chan c_sram, c_lcd, c_sram2, c_sram3;
  chan cmbrot1,cmbrot2,cmbrot3,cmbrot4,cmbrot5,cmbrot6,cmbrot7,cmbrot8;
  chan cb, xl0, xl1, xl2, xl3;
  par
  {
    // XCore 0
    on stdcore[0] : mandelbrot_lrsd_server_core0_fini(c_sram, c_lcd);
    on stdcore[0] : getButtonData(cb);

    // XCore 1
    on stdcore[1] : createMandelbrot(c_sram, cmbrot1
                                                                  , cmbrot2
                                                                  , cmbrot3
                                                                  , cmbrot4
                                                                  , cmbrot5
                                                                  , cmbrot6
                                                                  , cmbrot7
                                                                  , cmbrot8
                                                                  , cb, xl0);
    on stdcore[1] : mandelbrotfarm_fini(cmbrot3);
    on stdcore[1] : mandelbrotfarm(cmbrot4);
    on stdcore[1] : mandelbrotfarm(cmbrot5);
    on stdcore[1] : mandelbrotfarm(cmbrot1);

    // XCore 2
    on stdcore[2] : mandelbrotfarm_fini(cmbrot6);
    on stdcore[2] : mandelbrotfarm(cmbrot7);
    on stdcore[2] : mandelbrotfarm(cmbrot8);
    on stdcore[2] : mandelbrotfarm(cmbrot2);

    // XCore 3
    on stdcore[3] : mandelbrot_lrsd_server_core3_fini(c_lcd);

  }
  return 0;
}
