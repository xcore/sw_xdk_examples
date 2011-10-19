// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#ifndef _colours_h_
#define _colours_h_

// R  0 .. 31
// G  0 .. 63
// B  0 .. 31
#define RGB(r, g, b) (((b) << 11) | ((g) << 5) | (r))

#define RGB_WHITE (RGB(31, 63, 31))
#define RGB_BLACK (RGB(0, 0, 0))

#endif
