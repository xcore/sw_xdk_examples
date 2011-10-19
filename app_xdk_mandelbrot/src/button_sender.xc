// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*
 * @Example App - Pong - Button Sender
 * @Description Runs on core with buttons on. Allows polling for button state.
 */
 
#define HOME_BUTTON 4 

#include <xs1.h>
#include "mandelbrot_traphandler.h"
#include "button_sender.h"
// Gets button data and sends to pong core (core 2)

void getButtonData(chanend pollChan)
{
	//timer t;
	//unsigned time;
	unsigned buttonData, buttonData2;

  mandelbrot_register_traphandler();

	do
	{  
		// Read state
		buttonPort :> buttonData;
		buttonPort2 :> buttonData2;

		buttonData = ((buttonData >> 2) & 0xF) | (buttonData2<<4);
  	
	} while (buttonData & HOME_BUTTON);
  
  // Send back kill over channel
	pollChan <: (int)1;

  // Die
	
}

