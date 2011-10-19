// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "lrsd_lcd.h"
#include "lrsd_server.h"

void lrsd_server_core3(chanend c_core3)
{
  par
  {
    lcd(c_core3);
  }
}
