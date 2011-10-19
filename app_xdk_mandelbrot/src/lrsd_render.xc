// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>
#include "mandelbrot_traphandler.h"
#include "lrsd_render.h"
#include "lrsd_tokens.h"
#include "streaming.h"

void render(chanend r, chanend rr)
{
	int x;
	int y;
	int done = 0;

  mandelbrot_register_traphandler();
  start_streaming_master(r);
  start_streaming_slave(rr);

	set_thread_fast_mode_on();

	while (!done)
	{
		done = inuint(rr);
		outuint(r, done);
		outuint(rr, 0);
		inuint(r);
		if (!done)
		{
			do
			{
				x = inuint(rr);
				if (x != -1)
				{
					y = inuint(rr);
					outuint(r, x);
					outuint(r, y);
				}
			}
			while (x != -1);
			outct(r, CT_FRAME_DONE);
		}
	}

	set_thread_fast_mode_off();

  stop_streaming_slave(rr);
  stop_streaming_master(r);
}
