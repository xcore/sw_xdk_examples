// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>
#include <platform.h>

on stdcore[0] : in port p_but = PORT_BUTTON_4;

void buttons(chanend c_but)
{
  p_but when pinsneq(0xf) :> int _;

  c_but <: 1;  
}

