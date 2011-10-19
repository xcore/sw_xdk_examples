// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*
 * @Example App - Mandelbrot
 * @Description Simple mandelbrot fractal algorithm
 */

// Receives x and y coordinates in fixed point format, one sign bit, 4 integer bits, 27 fractional bits.
// Returns number of mandelbrot iterations required, with a ceiling of traplimit.
 
unsigned mandelbrot(unsigned x, unsigned y, unsigned traplimit);
unsigned mandelbrotAss(unsigned x, unsigned y, unsigned traplimit);
