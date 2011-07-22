/**
 * Module:  touch_screen
 * Version: 1v1
 * Build:   b454f88b0e425ad38993188bdace5bbbcdf50276
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
#include <xs1.h>
#include <platform.h>

on stdcore[0] : in port p_but = PORT_BUTTON_4;

void buttons(chanend c_but)
{
  p_but when pinsneq(0xf) :> int _;

  c_but <: 1;  
}

