// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*
 * @Button Sender
 * @Description Runs on core with buttons on. Allows polling for button state.
 */

#include <print.h>
#include <platform.h>

on stdcore[0] : in port p_button03 = PORT_BUTTON_0_3;
on stdcore[0] : in port p_button4  = PORT_BUTTON_4;

// Gets button data
void getButtonData(chanend ch)
{
	unsigned data1, data2, data;
  int done;

	while (1)
	{
		// Receive state request
		ch :> done;
    if (done)
      break;

		// Read state
		p_button03 :> data1;
		p_button4 :> data2;

		data = ~((data1 & 0xF) | ((data2 & 0x1) << 4));

		// Send back state over channel
    ch <: data;

	}

}
