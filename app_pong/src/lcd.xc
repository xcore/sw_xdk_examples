// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 * @ModuleName Generic LCD Server Component.
 * @Description: Generic LCD Server Component.
 **/

#include "LCD_Comp_Def.h"
#include "pong.h"


//
// main Server thread (no sram)
//
void lcd(out port HSYNC_port, out port DTMG_port, out port DCLK_port, out port RGB_port, clock clk, chanend c)
{
  timer t;
  unsigned time;
  unsigned lineCount, rowCount, tmp;
  unsigned buf[PONG_BUFFER_WIDTH];
  int keepalive=1;

  // Initialise physical interface
  //set_clock_ref(clk);
  set_clock_div(clk, LCD_CLKDIV);
  start_clock(clk);
  set_port_inv(DCLK_port);

  set_port_clock(HSYNC_port, clk);
  set_port_clock(DCLK_port, clk);
  set_port_clock(DTMG_port, clk);
  set_port_clock(RGB_port, clk);

  // Set to outclock mode
  set_port_mode_clock(DCLK_port);

  while (keepalive)
  {
    t :> time;
    do
    {
      slave
      {
        for (int i=0; i<PONG_BUFFER_WIDTH; i++)
          c :> buf[i];
      }
    } while (buf[0]!=-2 && buf[0]!=-1);

    if (buf[0] == -1)
      keepalive = 0;

    if (keepalive)
    {
      t when timerafter(time+T_VBP) :> time;

      for(lineCount = 0; lineCount < LCD_HEIGHT_PX && keepalive; lineCount++)
      {
        t when timerafter(time + T_WH) :> time;

        // Read a line into local buffer
        slave
        {
          for (int i=0; i<PONG_BUFFER_WIDTH; i++)
            c :> buf[i];
        }
        if (buf[0] == -1)
          keepalive=0;

        HSYNC_port <: 1;

        t when timerafter(time+T_HBP) :> time;

        tmp = buf[0];
        DTMG_port <: 1;

        for(rowCount = 0; rowCount < LCD_WIDTH_PX-1; rowCount+=1)
        {
            RGB_port <: tmp;
            tmp = buf[rowCount];
        }
        RGB_port <: tmp;
        DTMG_port <: 0;

        t :> time;
        t when timerafter( time + T_HFP) :> time;

        HSYNC_port <:0;
      }
    }
  }

}



