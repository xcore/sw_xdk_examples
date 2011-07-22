/**
 * Module:  rgb_leds
 * Version: 1v1
 * Build:   f4342838884e05fbfcf9a6e35bb5e66dbbf16ebe
 * File:    buttons.xc
 *
 * The copyrights, all other intellectual and industrial
 * property rights are retained by XMOS and/or its licensors.
 * Terms and conditions covering the use of this code can
 * be found in the Xmos End User License Agreement.
 *
 * Copyright XMOS Ltd 2010
 *
 * In the case where this code is a modification of existing code
 * under a separate license, the separate license terms are shown
 * below. The modifications to the code are still covered by the
 * copyright notice above.
 *
 **/
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
