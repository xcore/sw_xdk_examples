/**
 * Module:  freq
 * Version: 1v1
 * Build:   b45a0fb9ab3e66156caa93683e6c6968b24e3366
 * File:    filter.xc
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
#include <print.h>

#define Mac(a,b,c,d)  {b,a} = mac(c,d,b,a)

/*
int b0o[] = { 619489, 1194043, 2223731, 3891548, 6130479, 8136044,};
int b2o[] = { -619489, -1194043, -2223731, -3891548, -6130479, -8136044,};
int a1o[] = { -32291694, -31074719, -28765182, -24567970, -17409222, -5822246,};
int a2o[] = { 15538238, 14389130, 12329753, 8994119, 4516259, 505128,};

#define BANKS 6
*/

#include "banks.h"
#include "filtercoefficients.h"

struct filterPars {
    int b0[BANKS];
    int corr[BANKS];
    int b2N[BANKS];
    int a1[BANKS];
    int a2N[BANKS];
};

#define MAXGAIN  1
#define B (1<<31)

void setCoeff(struct filterPars &f, int i, int from, int gain) {
    f.b0[i]   =  (b0o[from] >>6) * gain;
    f.b2N[i]  = -(b2o[from] >>6) * gain;
    f.a1[i]   = -(a1o[from]);
    f.a2N[i]  =  (a2o[from]) ;
    f.corr[i] = ((f.b0[i] - f.b2N[i] + f.a1[i] - f.a2N[i])<<7) - B;
}


void filter(chanend gains, chanend sin, chanend sout) {
    struct filterPars f;
    int ynl;
    int ynh, xn1, xn2;
    unsigned xn;
    int yn1[BANKS], yn2[BANKS];
    int i;
    int curgain[BANKS], newgain[BANKS];
    int adjust = 10;
    int g = 0;
    xn = 0; xn1 = 0; xn2 = 0;
    for(i = 0; i<BANKS; i+=1) {
        yn1[i] = B;
        yn2[i] = B;
        setCoeff(f, i,i,64);
        curgain[i] = 64;
        newgain[i] = 32;
    }
    xn1 = B;
    xn2 = B;

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
            xn += B;
            for(int j=BANKS-1; j>=0; j--) {
                int yn1j = yn1[j];
                ynl = 0;
                ynh = 0;
                Mac(ynl,ynh,f.b2N[j],xn2);
                Mac(ynl, ynh, f.a2N[j], yn2[j]);
                yn2[j] = yn1j;
                ynl = ~ynl;
                ynh = ~ynh;
                ynl+=1;
                if (ynl == 0) {
                    ynh+=1;
                }
                Mac(ynl, ynh, f.a1[j], yn1j);
                Mac(ynl, ynh, f.b0[j], xn);
                ynh = (ynh << 8) | (((unsigned) ynl) >> 24);
                ynh -= f.corr[j];
                yn1[j]= ynh;
                sum += ynh;   // Should have a -B, but this falls out for an even number of sums...
            }
            xn2 = xn1; xn1= xn;
            outuint(sout, sum);
            break;
        case gains :> x:
            if (x >= 0 && x < BANKS) {
                gains :> newgain[x];
            } else {
                gains :> int _;
            }
            break;
        }
        if (adjust == 0) {
            adjust = 10;
            g = g + 1;
            if (g >= BANKS) g = 0;
            if (curgain[g] != newgain[g]) {
                if (curgain[g] < newgain[g]) {
                    curgain[g] += 1;
                } else {
                    curgain[g] -= 1;
                }
                setCoeff(f, g, g, curgain[g]);
            }
        }
        adjust--;
    }
}
