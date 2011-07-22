// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*
 ============================================================================
 Name        : $(sourceFile)
 Description : Illuminate multiple LEDs concurrently on the XDK board 
 ============================================================================
 */

#include <platform.h>

#define PERIOD 20000000

out port led1 = PORT_LED_0_2;
out port led2 = PORT_LED_0_1;
out port led3 = PORT_LED_0_0;

void flashLED (out port led, int period);

int main (void) {
  par {
    flashLED (led1, PERIOD);
    flashLED (led2, PERIOD);
    flashLED (led3, PERIOD);
  }
  return 0;
}

void flashLED (out port led, int period){
}
