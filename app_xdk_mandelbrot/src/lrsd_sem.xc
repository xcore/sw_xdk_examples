// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>
#include "mandelbrot_traphandler.h"
#include "select_priority.h"
#include "lrsd_tokens.h"
#include "streaming.h"

#ifdef SIMULATION
// Note: This must be divisible by 8
#define NUM_WORDS_FRAME 16
#else
#define NUM_WORDS_FRAME (320 * 240 / 2)
#endif

{ int, int, int, int } static init(chanend p, chanend c, chanend r, chanend s, chanend l);
{ int, int } static out_begin(chanend l, chanend c);
{ int, int, int } static in_begin(chanend r, chanend p);
static int out_step(chanend l, chanend s, int A_, int G);
static void in_step(chanend r, chanend s, int A);
static int in_end(chanend r);
static void finish(chanend c, chanend s, chanend l, int A_, int G);

static int addr[3] =
{
	(NUM_WORDS_FRAME << 2) * 0,
	(NUM_WORDS_FRAME << 2) * 1,
	(NUM_WORDS_FRAME << 2) * 2,
};

void sem(chanend p, chanend c, chanend r, chanend s, chanend l)
{
	int A, A_, G, F;
	int done = 0;
	int priority;

  mandelbrot_register_traphandler();
  start_streaming_slave(r);
  start_streaming_master(s);
  start_streaming_master(l);

	set_thread_fast_mode_on();

	{ A, A_, G, F } = init(p, c, r, s, l);
	while (done == 0)
	{
		priority = select_priority2(l, r);
		if (priority == 0)
		{
			// l - priority
			if (G == -1)
				{ G, A_ } = out_begin(l, c);
			else
				G = out_step(l, s, A_, G);
		}
		else
		{
			// r
			if (testct(r) == 1)
				F = in_end(r);
			else if (F == 1)
				{ F, A, done } = in_begin(r, p);
			else
				in_step(r, s, A);
		}
	}
	finish(c, s, l, A_, G);

	set_thread_fast_mode_off();

  stop_streaming_master(l);
  stop_streaming_master(s);
  stop_streaming_slave(r);
}

{ int, int, int, int } static init(chanend p, chanend c, chanend r, chanend s, chanend l)
{
	int b;
	int x, y;
	int i;
	int A, A_;
	int F, G;
	unsigned w;

	p <: 0;
	c <: 0;
	p :> b;
	A = addr[b];
	inuint(r);
	outuint(r, 0);
	while (testct(r) == 0)
	{
		x = inuint(r);
		y = inuint(r);
		outuchar(s, T_SRAM_W2B);
		outuint(s, 2 * x + A);
		outuint(s, y);
	}
	chkct(r, CT_FRAME_DONE);
	p <: 0;
	c :> b;
	A_ = addr[b];
	p :> b;
	A = addr[b];
	inuint(r);
	outuint(r, 0);
	while (testct(r) == 0)
	{
		x = inuint(r);
		y = inuint(r);
		outuchar(s, T_SRAM_W2B);
		outuint(s, 2 * x + A);
		outuint(s, y);
	}
	chkct(r, CT_FRAME_DONE);
	F = 1;
	inuint(l);
	outuint(l, 0);
	G = 0;
	for (i = 0; i < (NUM_WORDS_FRAME >> 2); i += 1)
	{
		inuint(l);
		outuchar(s, T_SRAM_R4W);
		outuint(s, G + A_);
		w = inuint(s);
		outuint(l, w);
		w = inuint(s);
		outuint(l, w);
		w = inuint(s);
		outuint(l, w);
		w = inuint(s);
		outuint(l, w);
		G += 16;
	}
	G = -1;
	return { A, A_, G, F };
}

{ int, int } static out_begin(chanend l, chanend c)
{
	int G;
	int A_;
	int b;

	inuint(l);
	outuint(l, 0);
	G = 0;
	c <: 0;
	c :> b;
	A_ = addr[b];

	return { G, A_ };
}

static int out_step(chanend l, chanend s, int A_, int G)
{
	const int nbytes = NUM_WORDS_FRAME << 2;
	unsigned w;
	inuint(l);
	outuchar(s, T_SRAM_R4W);
	outuint(s, G + A_);
	w = inuint(s);
	outuint(l, w);
	w = inuint(s);
	outuint(l, w);
	w = inuint(s);
	outuint(l, w);
	w = inuint(s);
	outuint(l, w);
	G += 16;
	if (G >= nbytes)
		G = -1;

	return G;
}

static int in_end(chanend r)
{
	chkct(r, CT_FRAME_DONE);
	return 1;
}

{ int, int, int } static in_begin(chanend r, chanend p)
{
	int done;
	int b;
	int A;

	done = inuint(r);
	outuint(r, 0);
	p <: done;
	p :> b;

	if (done == 0)
		A = addr[b];

	return { 0, A, done };
}

static void in_step(chanend r, chanend s, int A)
{
	int x, y;

	x = inuint(r);
	y = inuint(r);
	outuchar(s, T_SRAM_W2B);
	outuint(s, 2 * x + A);
	outuint(s, y);
}

static void finish(chanend c, chanend s, chanend l, int A_, int G)
{
	int done = 0;
	int b;

	while (done == 0)
	{
		if (G == -1)
		{
			inuint(l);
			G = 0;
			c <: 0;
			c :> b;

			if (b == -1)
				done = 1;
			else
				A_ = addr[b];

			outuint(l, done);
		}
		else
		{
			G = out_step(l, s, A_, G);
		}
	}

	outuchar(s, T_SHUTDOWN);
}
