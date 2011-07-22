// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*
 ============================================================================
 Name        : $(sourceFile)
 Description : Illuminate an LED on the XDK board 
 ============================================================================
 */

#include <platform.h>

out port led = PORT_LED_0_1;

int main (void){
  led <: 0;
  while (1)
    ;
  return 0;
}
