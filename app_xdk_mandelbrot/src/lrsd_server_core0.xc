// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "lrsd_ctrl.h"
#include "lrsd_sram.h"
#include "lrsd_lcdc.h"
#include "lrsd_sem.h"
#include "lrsd_render.h"
#include "lrsd_server.h"

void lrsd_server_core0(chanend c_client, chanend c_lcd)
{
  chan c, p;
  chan s;
  chan l;
  chan r;
  par
  {
    ctrl(p, c);
    sram(s);
    lcdc(l, c_lcd);
    sem(p, c, r, s, l);
    render(r, c_client);
  }
}
