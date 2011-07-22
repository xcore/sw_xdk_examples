// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*
 ============================================================================
 Name        : $(sourceFile)
 Description : Flash LEDs connected to different cores on an XDK board 
 ============================================================================
 */

#include <platform.h>
#define PERIOD 20000000

on stdcore [0] : out port led1 = PORT_LED_0_2;
on stdcore [3] : out port led2 = PORT_LED_3_1;
on stdcore [2] : out port led3 = PORT_LED_2_0;

void tokenFlash (chanend left, chanend right, out port led, int period, int isMaster);

int main (void) {
  chan c0 , c1 , c2;
  par {
    on stdcore [0] : tokenFlash (c0, c1, led1, PERIOD, 1);
    on stdcore [3] : tokenFlash (c1, c2, led2, PERIOD, 0);
    on stdcore [2] : tokenFlash (c2, c0, led3, PERIOD, 0);
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
    tmr when timerafter (t+ period ) :> void;
    led <: 0;
    right <: token; /* output token to right neighbor */
  }
}
