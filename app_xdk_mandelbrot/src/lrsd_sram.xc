// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>
#include <platform.h>
#include <stdlib.h>
#include "mandelbrot_traphandler.h"
#include "lrsd_tokens.h"
#include "lrsd_sram.h"
#include "streaming.h"
#define PORT_SRAM_GATEWR   0x10600    // PORT_1E (former PORT_1G)
#define PORT_SRAM_GATEWE   0x10500    // PORT_1G (former PORT_1F)
#define PORT_SRAM_GATERD   0x10400    // PORT_1F (former PORT_1E)
// Note: ADDR must be buffered otherwise it can't be strobed
on stdcore[0] : buffered out port:32 sramaddr = PORT_SRAM_ADDR;
on stdcore[0] : buffered port:32 data = PORT_SRAM_DATA;
on stdcore[0] : out port sramctrl = PORT_SRAM_CTRL;
on stdcore[0] : out port we = PORT_SRAM_WE_N;
on stdcore[0] : buffered out port:8 gatewr = PORT_SRAM_GATEWR;
on stdcore[0] : buffered out port:32 gatewe = PORT_SRAM_GATEWE;
on stdcore[0] : buffered out port:32 gaterd = PORT_SRAM_GATERD;
on stdcore[0] : clock cwr = XS1_CLKBLK_1;
on stdcore[0] : clock cwe = XS1_CLKBLK_2;

static void init();
static void finish();
static void w2b(chanend s, buffered out port:32 addr, buffered out port:32 data, buffered out port:8 gatewr, buffered out port:32 gatewe);
static void r4w(chanend s, buffered out port:32 addr, buffered port:32 data, buffered out port:8 gatewr, buffered out port:32 gatewe, out port ctrl, clock cwe);
static void delay(int d);
static void error();

#define SLOW_SRAM

void sram(chanend s)
{
  int done = 0;

  mandelbrot_register_traphandler();
  start_streaming_slave(s);

	set_thread_fast_mode_on();

  init();

  while (done == 0)
  {
    unsigned char cmd = inuchar(s);
    switch (cmd)
    {
      case T_SRAM_W2B:
        w2b(s, sramaddr, data, gatewr, gatewe);
        break;

      case T_SRAM_R4W:
        r4w(s, sramaddr, data, gatewr, gatewe, sramctrl, cwe);
        break;

      case T_SHUTDOWN:
        done = 1;
        break;

      default:
        error();
        break;
    }
  }

  finish();

  set_thread_fast_mode_off();
  stop_streaming_slave(s);
}

static void delay(int d)
{
	timer tmr;
	int t;
  if (d > 0)
  {
    tmr :> t;
    tmr when timerafter(t + d) :> t;
  }
}

static void init()
{
  set_clock_on(cwr);
  set_clock_on(cwe);

  set_port_use_on(sramaddr);
  set_port_use_on(data);
  set_port_use_on(sramctrl);
  set_port_use_on(we);
  set_port_use_on(gatewr);
  set_port_use_on(gatewe);
  set_port_use_on(gaterd);

  sramctrl <: 1;
  we <: 1;
  gatewr <: 0;
  gatewe <: 0;
  gaterd <: 0;
  data <: 0;
  sramaddr <: 0;

  set_port_strobed(sramaddr);
  set_port_strobed(data);
  set_port_slave(sramaddr);
  set_port_slave(data);
  set_port_inv(we);
  set_pad_delay(we, 5);
  set_port_mode_clock(we);
  set_port_clock(we, cwe);

  set_port_clock(sramaddr, cwr);
  set_port_clock(data, cwr);
  set_port_clock(gatewr, cwe);
  set_clock_src(cwe, gatewe);
  set_clock_ready_src(cwr, gatewr);

  start_clock(cwr);
  start_clock(cwe);
}

static void finish()
{
  delay(100);

  set_port_use_off(sramaddr);
  set_port_use_off(data);
  set_port_use_off(sramctrl);
  set_port_use_off(we);
  set_port_use_off(gatewr);
  set_port_use_off(gatewe);
  set_port_use_off(gaterd);

  set_clock_off(cwr);
}

static void w2b(chanend s, buffered out port:32 addr, buffered out port:32 data, buffered out port:8 gatewr, buffered out port:32 gatewe)
{
  register unsigned a = inuint(s);
  register unsigned aa = a + 1;
  register unsigned x = inuint(s);
  register const int one = 1;
#ifdef SLOW_SRAM
  register const int twoticks = 0x60000003;
#else
  register const int twoticks = 0x63;
#endif

	sync(gatewe);
        partout(gatewr,2,one);
        partout(data,16,x);
	clearbuf(addr);
        addr <: a;
  addr <: aa;
#ifdef SLOW_SRAM
        partout(gatewe,32,twoticks);
#else
        partout(gatewe,8,twoticks);
#endif
}

static void r4w(chanend s, buffered out port:32 addr, buffered port:32 data, buffered out port:8 gatewr, buffered out port:32 gatewe, out port ctrl, clock cwe)
{
  register unsigned a = inuint(s);
  unsigned xl, xh;
	register int i;

	sync(gatewe);

  set_clock_ready_src(cwr, gaterd);

  set_port_master(data);
  partin(data, 8);
  set_port_slave(data);

  ctrl <: 0;

  clearbuf(data);

	for (i = 0; i < 4; i += 1)
	{
		addr <: a;
		a += 1;
		addr <: a;
		a += 1;
#ifdef SLOW_SRAM
                partout(gaterd,8,0x63);
#else
		partout(gaterd,5, 15);
#endif
		data :> xl;
		xl >>= 16;

		addr <: a;
		a += 1;
		addr <: a;
		a += 1;
#ifdef SLOW_SRAM
                partout(gaterd,8,0x63);
#else
		partout(gaterd,5,15);
#endif
		data :> xh;
		xh >>= 16;

		outuint(s, (xh << 16) | xl);
	}

  ctrl <: 1;

  set_port_master(data);
  partout(data,8,0);
  set_port_slave(data);

  set_clock_ready_src(cwr, gatewr);

	clearbuf(addr);
	clearbuf(data);
}

static void error()
{
  int i = 1;
  int j = 0;
  i = j / j;
}
