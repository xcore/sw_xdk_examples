// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>
#include <xclib.h>

void keys(port in keys_port, port in key, chanend toCodec, chanend outSelect, chanend toTouch) {
    int keyscurrent = 0;
    int keycurrent = 0;
    while(1)  {
        select {
        case keys_port when pinsneq(keyscurrent) :> keyscurrent:
            if ((keyscurrent & 0x4) == 0) {
                toCodec   <: 0x80000000;
                outSelect <: 0x80000000;
                toTouch   <: 0x80000000;
                return;
            } else if ((keyscurrent & 0x1) == 0) {
                outSelect <: 1;
            } else if ((keyscurrent & 0xa) != 0xa) {
                outSelect <: 0;
            }
            break;
        case key when pinsneq(keycurrent) :> keycurrent:
            if (keycurrent == 0) {
                outSelect <: -1;
            }
            break;
        }
    }
}
