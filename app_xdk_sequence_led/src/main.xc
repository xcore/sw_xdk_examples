// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*
 ============================================================================
 Name        : $(sourceFile)
 Description : Illuminate multiple LEDs in sequence on an XDK board 
 ============================================================================
 */

#include <platform.h>
#define PERIOD 20000000

out port led1 = PORT_LED_0_2;
out port led2 = PORT_LED_0_1;
out port led3 = PORT_LED_0_0;

void tokenFlash (chanend left, chanend right, out port led, int period, int isMaster);

int main (void) {
  chan c0 , c1 , c2;
  par {
    tokenFlash (c0, c1, led1, PERIOD, 1);
    tokenFlash (c1, c2, led2, PERIOD, 0);
    tokenFlash (c2, c0, led3, PERIOD, 0);
  }
  return 0;
}


void tokenFlash (chanend left, chanend right, out port led, int period, int isMaster) {

  timer tmr;
  unsigned t;

  if (isMaster) /* master inserts token into ring */
    right <: 1;

  while (1) {
    int token;
    left :> token; /* input token from left neighbor */
    led <: 1;
    tmr :> t;
    tmr when timerafter (t + period) :> void;
    led <: 0;
    right <: token; /* output token to right neighbor */
  }
}

