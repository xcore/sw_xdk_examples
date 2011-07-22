/**
 * Module:  freq
 * Version: 1v1
 * Build:   b45a0fb9ab3e66156caa93683e6c6968b24e3366
 * File:    keys.xc
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
