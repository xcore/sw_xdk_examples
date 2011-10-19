// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>
#include <platform.h>
#include "mandelbrot_traphandler.h"
#include "streaming.h"

#define LCD_CLKDIV     26
#define T_HFP          600 // 400
#define T_HBP          900 // 600
#define T_WH           300 // 150
#define T_VBP          25000 //20000
#define LCD_BLACK      0
#define LCD_WIDTH_PX   240
#define LCD_HEIGHT_PX  320
#define CLKBLK_LCD XS1_CLKBLK_1

on stdcore[3] : out port hsync = PORT_LCD_HSYNC;
on stdcore[3] : out port dtmg  = PORT_LCD_DTMG;
on stdcore[3] : out port dclk  = PORT_LCD_DCLK;
on stdcore[3] : out port rgb   = PORT_LCD_RGB;
on stdcore[3] : clock clk      = CLKBLK_LCD;

void static init(chanend ll)
{
  set_port_use_off(dclk);
  set_port_use_off(dtmg);
  set_port_use_off(rgb);
  set_port_use_off(hsync);
  set_clock_off(clk);

  set_port_use_on(dclk);
  set_port_use_on(dtmg);
  set_port_use_on(rgb);
  set_port_use_on(hsync);
  set_clock_on(clk);

  // Don't output on DCLK -- outclock mode might fail
  hsync <: 0;
  dtmg <: 0;
  rgb <: 0;

  set_clock_div(clk, LCD_CLKDIV);
  set_port_inv(dclk);

  set_port_clock(hsync, clk);
  set_port_clock(dclk, clk);
  set_port_clock(dtmg, clk);
  set_port_clock(rgb, clk);

  set_port_mode_clock(dclk);

  start_clock(clk);

	outuint(ll, 0);
	outct(ll, XS1_CT_END);
	inuint(ll);
}

void static shutdown(chanend ll)
{
  inct(ll);
  set_port_use_off(dclk);
  set_port_use_off(dtmg);
  set_port_use_off(rgb);
  set_port_use_off(hsync);
  set_clock_off(clk);
}

void lcd(chanend ll)
{
  unsigned tmp=0;
  unsigned data = LCD_BLACK;
  unsigned VCount, HCount;
  timer t;
  unsigned time;

  mandelbrot_register_traphandler();
  start_streaming_slave(ll);
  set_thread_fast_mode_on();
  init(ll);

  while (inuint(ll) == 0)
  {
    t :> time;
		t when timerafter(time+T_VBP) :> time;
		tmp = time;


		for(VCount = 0; VCount < LCD_HEIGHT_PX; VCount+=1)
		{
			t when timerafter(tmp + T_WH) :> tmp;

			hsync <: 1;
			t :> tmp;
			t when timerafter(tmp+T_HBP) :> tmp;


			// 2 RGB565 pixels
			data = inuint(ll);

			// LCD is RGB666 all our data is RGB565, do 565 -> 666 conversion...
			tmp =  ((data&0xf800)<<2)| ((data&0x7e0)<<1) | ((data&0x1f)<<1);

      sync(dtmg);
			rgb <: tmp;
      dtmg <: 1;

			data = data >> 16;

			tmp =  ((data&0xf800)<<2)| ((data&0x7e0)<<1) | ((data&0x1f)<<1);

			rgb <: tmp;


			for(HCount = 1; HCount < LCD_WIDTH_PX>>1; HCount++)
			{
				// 2 RGB565 pixels
				data = inuint(ll);

				// LCD is RGB666 all our data is RGB565, do 565 -> 666 conversion...
				tmp =  ((data&0xf800)<<2)| ((data&0x7e0)<<1) | ((data&0x1f)<<1);

				rgb <: tmp;

				data = data >> 16;

				tmp =  ((data&0xf800)<<2)| ((data&0x7e0)<<1) | ((data&0x1f)<<1);

				rgb <: tmp;
			}
			dtmg <: 0;
			sync(dtmg);

			t :> tmp;
			t when timerafter( tmp + T_HFP) :> tmp;

			hsync <:0;
		}
  }

  shutdown(ll);
  set_thread_fast_mode_off();
  stop_streaming_slave(ll);
}
