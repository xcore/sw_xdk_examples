// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#ifndef _ctrl_h_
#define _ctrl_h_

// WARNING
// XC version uses handshaked channels here, whereas handcoded version uses
// raw channels
// Therefore the following work together: sem.xc & ctrl.xc, sem.S & ctrl.S
// And the following don't work together: sem.xc & ctrl.S, sem.S & ctrl.xc

void ctrl(chanend p, chanend c);

#endif
