// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#ifndef _select_priority_h_
#define _select_priority_h_

// Selects on channel ends a and b
// Priority is on channel end a
// Returns 0 or 1 for a or b, respectively
int select_priority2(chanend a, chanend b);
int select_priority4(chanend a, chanend b1, chanend b2, chanend b3);

#endif
