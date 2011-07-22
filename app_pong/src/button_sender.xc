// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*
 * @Example App - Pong - Button Sender
 * @Description Runs on core with buttons on. Allows polling for button state.
 */

#include <xs1.h>
#include "pong.h"

// Gets button data and sends to pong core (core 2)

void getButtonData(in port p_btn, in port p_btn2, chanend c_pong)
{
  unsigned buttonData, buttonData2;

  do
  {
    // Receive state request
    c_pong :> buttonData;

    // Read state
    p_btn :> buttonData;
    p_btn2 :> buttonData2;

    buttonData = ((buttonData >> 2) & 0xF) | (buttonData2<<4);

    // Send back state over channel
    c_pong <: buttonData;

  } while (buttonData & PONG_HOME_BUTTON);

}



