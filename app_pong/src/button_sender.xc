/**
 * Module:  pong
 * Version: 1v1
 * Build:   09eb107119f1beff657cf7dc11fdadf918468539
 * File:    button_sender.xc
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



