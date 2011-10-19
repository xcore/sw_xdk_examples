// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "mandelbrot_traphandler.h"

{ int, int, int, int, int, int } static init(chanend p, chanend c);
void static finish(chanend p, chanend c, int d);
{ int, int, int } static produce(int w, int a, int d);
{ int, int, int } static consume(int r, int a, int d);

void ctrl(chanend p, chanend c)
{
	int r, w, a, d;
	int np, nc;
	int done = 0;

  mandelbrot_register_traphandler();

	{ r, w, a, d, np, nc } = init(p, c);
	while (done == 0)
	{
		select
		{
			case p :> done:
				{ w, a, d } = produce(w, a, d);
			  p <: (w - 1);
				np += 1;
				break;
      case c :> int x:
				{ r, a, d } = consume(r, a, d);
			  c <: (r - 1);
				nc += 1;
				break;
    }
  }
	finish(p, c, d);
}

{ int, int, int, int, int, int } static init(chanend p, chanend c)
{
	p :> int done;
	c :> int x;
	p <: 0;
	p :> int done;
	c <: 0;
	p <: 1;
	return { 1, 2, 3, 0, 2, 1 };
}

void static finish(chanend p, chanend c, int d)
{
	c :> int x;
	c <: (d - 1);
	c :> int x;
	c <: -1;
}

{ int, int, int } static produce(int w, int a, int d)
{
	if (d != 0)
	{
		int x;
		x = d;
		d = w;
		w = x;
	}
	else
	{
		d = w;
		w = a;
		a = 0;
	}

	return { w, a, d };
}

{ int, int, int } static consume(int r, int a, int d)
{
	if (d != 0)
	{
		a = r;
		r = d;
		d = 0;
	}

	return { r, a, d };
}
