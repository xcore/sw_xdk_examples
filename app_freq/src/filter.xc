// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>
#include <print.h>


#include "coeffs.h"
#include "biquadCascade.h"

extern int biquadAsm(int xn, biquadState &state);

// Update 2011 moving to cascaded biquad filters taken from GitHub:
// sc_dsp_filters
// Only works on RevB silicon as signed MACC used.
//

#define MAXGAIN  1


// Filter called twice, once for each channel.
// So need a slightly different approach to indicate which channel
// in use? Another arg to indicate which bq used?
// Pass in bq state then pass this around? Or have as a local
// and pass as needed.

void filter(chanend gains, chanend sin, chanend sout) {
    unsigned xn;
    biquadState bs;
    initBiquads(bs,20);

#pragma unsafe arrays
    while (1) {
        int x;
        int sum = 0;
        select {
        case inuint_byref(sin,xn):
            if (xn == 0x80000000) {
                inct(sin);
                outct(sin, XS1_CT_END);
                outuint(sout, xn);
                outct(sout, XS1_CT_END);
                inct(sout);
                return;
            }
            //            xn += B;
            xn = biquadAsm (xn, bs);
            outuint(sout, xn);
            break;
        case gains :> x:
            if (x >= 0 && x < BANKS) {
              int tmp;
            gains :> tmp;
              tmp >>= 1; // halve values to keep sensible range and avoid distortion
              bs.desiredDb[x] = tmp;

            } else {
                gains :> int _;
            }
            break;
        }
    }
}
