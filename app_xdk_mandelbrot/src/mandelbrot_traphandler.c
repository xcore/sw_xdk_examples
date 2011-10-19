// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "mandelbrot_traphandler.h"
#include "libtrap.h"

void mandelbrot_traphandler(const struct trapinfo_t *info)
{
	while (1)
		;
}

void mandelbrot_register_traphandler()
{
	register_traphandler(mandelbrot_traphandler);
}
