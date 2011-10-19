// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>
#include "mandelbrot_traphandler.h"
#include "streaming.h"

#ifdef SIMULATION
// Note: This must be divisible by 8
#define NUM_WORDS_FRAME 16
#else
#define NUM_WORDS_FRAME (320 * 240 / 2)
#endif

static void init(chanend l, chanend ll);
static int frame(chanend l, chanend ll);
static void finish(chanend ll);

void lcdc(chanend l, chanend ll)
{
	int done = 0;

  mandelbrot_register_traphandler();
  start_streaming_slave(l);
  start_streaming_master(ll);

	set_thread_fast_mode_on();

	init(l, ll);

	while (done == 0)
	{
		done = frame(l, ll);
	}

	finish(ll);

	set_thread_fast_mode_off();

  stop_streaming_master(ll);
  stop_streaming_slave(l);
}

static void init(chanend l, chanend ll)
{
	int done;
	inuint(ll);
	chkct(ll, XS1_CT_END);
	outuint(ll, 0);
	outuint(l, 0);
	done = inuint(l);
}

static int frame(chanend l, chanend ll)
{
	int done;
	int w1, w2, w3, w4, w1_, w2_, w3_, w4_;
	int niterations = NUM_WORDS_FRAME / 8 - 1;
	int i;

	outuint(ll, 0);
	outuint(l, 0);
	w1 = inuint(l);
	w2 = inuint(l);
	w3 = inuint(l);
	w4 = inuint(l);
	outuint(ll, w1);
	for (i = 0; i < niterations; i += 1)
	{
		outuint(ll, w2);
		outuint(l, 0);
		outuint(ll, w3);
		w1_ = inuint(l);
		w2_ = inuint(l);
		w3_ = inuint(l);
		w4_ = inuint(l);
		outuint(ll, w4);
		outuint(ll, w1_);
		outuint(l, 0);
		outuint(ll, w2_);
		w1 = inuint(l);
		w2 = inuint(l);
		w3 = inuint(l);
		w4 = inuint(l);
		outuint(ll, w3_);
		outuint(ll, w4_);
		outuint(ll, w1);
	}
	outuint(ll, w2);
	outuint(l, 0);
	w1_ = inuint(l);
	w2_ = inuint(l);
	w3_ = inuint(l);
	w4_ = inuint(l);
	outuint(ll, w3);
	outuint(ll, w4);
	outuint(ll, w1_);
	outuint(ll, w2_);
	outuint(ll, w3_);
	outuint(ll, w4_);
	outuint(l, 0);
	done = inuint(l);
	return done;
}

static void finish(chanend ll)
{
	outuint(ll, 1);
	outct(ll, XS1_CT_END);
}
