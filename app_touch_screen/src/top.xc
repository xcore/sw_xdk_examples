// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

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
