// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>
#include <xclib.h>
#include "banks.h"

extern int Sinewave[]; /* under the fft */


void fix_fft_512(int fin[], unsigned int fout[]) {
    int fr[512], fi[512];
    int l,k;
    int sum = 0;

#pragma unsafe arrays
    for(int m=0; m<512; m++) {
        sum += fin[m] >> 9;
        fi[m] = 0;
        fr[bitrev(m<<23)] = fin[m];
    }
#pragma unsafe arrays
    for(int m=0; m<512; m++) {
        fr[m] -= sum;
    }

    l = 1;
    k = 8;
#pragma unsafe arrays
    while(l < 512) {
        for(int m=0; m < l; m++) {
            int j = m << k;
            int wr =  Sinewave[j+128];
            int wi = -Sinewave[j];
            wr >>= 1;
            wi >>= 1;
            for(int i=m; i< 512; i+=l+l) {
                int j = i + l;
                int tr = (wr*fr[j] - wi*fi[j])>>15;
                int ti = (wr*fi[j] + wi*fr[j])>>15;
                int qr = fr[i];
                int qi = fi[i];
                qr >>= 1;
                qi >>= 1;
                fr[j] = qr - tr;
                fi[j] = qi - ti;
                fr[i] = qr + tr;
                fi[i] = qi + ti;
            }
        }
        k-=1;
        l = l << 1;
    }
    for(int m=0; m<512; m += 1) {
        fout[m] = fr[m] * fr[m] + fi[m] * fi[m];
    }
}

int Sinewave[512] = {
 0, 402, 804, 1206, 1608, 2009, 2410, 2811, 3212, 3612, 4011, 4410, 4808, 5205, 5602, 5998, 6393, 6786, 7179, 7571, 7962, 8351, 8739, 9126, 9512, 9896, 10278, 10659, 11039, 11417, 11793, 12167, 12539, 12910, 13279, 13645, 14010, 14372, 14732, 15090, 15446, 15800, 16151, 16499, 16846, 17189, 17530, 17869, 18204, 18537, 18868, 19195, 19519, 19841, 20159, 20475, 20787, 21096, 21403, 21705, 22005, 22301, 22594, 22884, 23170, 23452, 23731, 24007, 24279, 24547, 24811, 25072, 25329, 25582, 25832, 26077, 26319, 26556, 26790, 27019, 27245, 27466, 27683, 27896, 28105, 28310, 28510, 28706, 28898, 29085, 29268, 29447, 29621, 29791, 29956, 30117, 30273, 30424, 30571, 30714, 30852, 30985, 31113, 31237, 31356, 31470, 31580, 31685, 31785, 31880, 31971, 32057, 32137, 32213, 32285, 32351, 32412, 32469, 32521, 32567, 32609, 32646, 32678, 32705, 32728, 32745, 32757, 32765,
 32767, 32765, 32757, 32745, 32728, 32705, 32678, 32646, 32609, 32567, 32521, 32469, 32412, 32351, 32285, 32213, 32137, 32057, 31971, 31880, 31785, 31685, 31580, 31470, 31356, 31237, 31113, 30985, 30852, 30714, 30571, 30424, 30273, 30117, 29956, 29791, 29621, 29447, 29268, 29085, 28898, 28706, 28510, 28310, 28105, 27896, 27683, 27466, 27245, 27019, 26790, 26556, 26319, 26077, 25832, 25582, 25329, 25072, 24811, 24547, 24279, 24007, 23731, 23452, 23170, 22884, 22594, 22301, 22005, 21705, 21403, 21096, 20787, 20475, 20159, 19841, 19519, 19195, 18868, 18537, 18204, 17869, 17530, 17189, 16846, 16499, 16151, 15800, 15446, 15090, 14732, 14372, 14010, 13645, 13279, 12910, 12539, 12167, 11793, 11417, 11039, 10659, 10278, 9896, 9512, 9126, 8739, 8351, 7962, 7571, 7179, 6786, 6393, 5998, 5602, 5205, 4808, 4410, 4011, 3612, 3212, 2811, 2410, 2009, 1608, 1206, 804, 402,
 0, -402, -804, -1206, -1608, -2009, -2410, -2811, -3212, -3612, -4011, -4410, -4808, -5205, -5602, -5998, -6393, -6786, -7179, -7571, -7962, -8351, -8739, -9126, -9512, -9896, -10278, -10659, -11039, -11417, -11793, -12167, -12539, -12910, -13279, -13645, -14010, -14372, -14732, -15090, -15446, -15800, -16151, -16499, -16846, -17189, -17530, -17869, -18204, -18537, -18868, -19195, -19519, -19841, -20159, -20475, -20787, -21096, -21403, -21705, -22005, -22301, -22594, -22884, -23170, -23452, -23731, -24007, -24279, -24547, -24811, -25072, -25329, -25582, -25832, -26077, -26319, -26556, -26790, -27019, -27245, -27466, -27683, -27896, -28105, -28310, -28510, -28706, -28898, -29085, -29268, -29447, -29621, -29791, -29956, -30117, -30273, -30424, -30571, -30714, -30852, -30985, -31113, -31237, -31356, -31470, -31580, -31685, -31785, -31880, -31971, -32057, -32137, -32213, -32285, -32351, -32412, -32469, -32521, -32567, -32609, -32646, -32678, -32705, -32728, -32745, -32757, -32765,
 -32767, -32765, -32757, -32745, -32728, -32705, -32678, -32646, -32609, -32567, -32521, -32469, -32412, -32351, -32285, -32213, -32137, -32057, -31971, -31880, -31785, -31685, -31580, -31470, -31356, -31237, -31113, -30985, -30852, -30714, -30571, -30424, -30273, -30117, -29956, -29791, -29621, -29447, -29268, -29085, -28898, -28706, -28510, -28310, -28105, -27896, -27683, -27466, -27245, -27019, -26790, -26556, -26319, -26077, -25832, -25582, -25329, -25072, -24811, -24547, -24279, -24007, -23731, -23452, -23170, -22884, -22594, -22301, -22005, -21705, -21403, -21096, -20787, -20475, -20159, -19841, -19519, -19195, -18868, -18537, -18204, -17869, -17530, -17189, -16846, -16499, -16151, -15800, -15446, -15090, -14732, -14372, -14010, -13645, -13279, -12910, -12539, -12167, -11793, -11417, -11039, -10659, -10278, -9896, -9512, -9126, -8739, -8351, -7962, -7571, -7179, -6786, -6393, -5998, -5602, -5205, -4808, -4410, -4011, -3612, -3212, -2811, -2410, -2009, -1608, -1206, -804, -402,};


#define SHIFT 64
#define BUFSIZE 512

void buffer(chanend fromDAC, chanend toBuf, port out led) {
    int buf[BUFSIZE];
    int rd = 0, wr = 0;
    int count = 0;
    int sample;

    led <: 0;
#pragma unsafe arrays
    while (1) {
        select {
        case toBuf :> count:
            break;
        case fromDAC :> sample:
            if (count > 0 && ((wr-rd)&(BUFSIZE-1)) > 2) {
                toBuf <: buf[rd];
                toBuf <: buf[rd+1];
                rd = (rd + 2) & (BUFSIZE-1);
                count -= 2;
            }
            if (sample == 0x80000000) {
                if (count == 0) {
                    toBuf :> count;
                }
                toBuf <: sample;
                led <: 1;
                return;
            }
            buf[wr] = sample;
            wr = (wr+1) & (BUFSIZE-1);
            break;
        }
    }
}

void ffter(chanend fromBuf, chanend toScreen) {
    int fi[512];
    unsigned int fo[512];

#pragma unsafe arrays
    while (1) {
        int avg;

        avg = 0;
        for(int i=0; i < 512-SHIFT; i++) {
            fi[i] = fi[i+SHIFT];
        }

        fromBuf <: SHIFT;
        for(int i=512-SHIFT; i<512; i++) {
            fromBuf :> fi[i];
            if (fi[i] == 0x80000000) {
                toScreen <: fi[i];
                return;
            }
            fi[i] <<= 3;
        }

        fix_fft_512(fi,fo);
        avg = 0;
        for(int i=1; i<256; i++) {
            int a = fo[i] + fo[512-i];
            int b = (32 - clz(a));
            a = (b<<3)-80;
            if (a < 0) {
                a = 0;
            }
            if (i < 2) {
                for (int j = 0; j < 8; j++ ) {
                    toScreen <: a;
                }
            } else if (i < 4) {
                for (int j = 0; j < 4; j++ ) {
                    toScreen <: a;
                }
            } else if (i < 8) {
                for (int j = 0; j < 2; j++ ) {
                    toScreen <: a;
                }
            } else if (i < 16) {
                toScreen <: a;
            } else {
                int mask;
                if (i < 32) {
                    mask = 1;
                } else if (i < 64) {
                    mask = 3;
                } else if (i < 128) {
                    mask = 7;
                } else if (i < 256) {
                    mask = 15;
                }
                if ((i & mask) == mask) {
                    toScreen <: avg/mask;
                    avg = 0;
                } else {
                    avg += a;
                }
            }
        }
    }
}


void shutdown(chanend toLCD, int x, chanend fromFFT, out port led_screen) {
    do {
        fromFFT :> x;
    } while (x != 0x80000000);
    inuint(toLCD);
    outuint(toLCD, x);
    inuint(toLCD);
    inuint(toLCD);
    outct(toLCD, XS1_CT_END);
    inct(toLCD);
    led_screen <: 1;
}

#define FILTERCOLOUR  0x003f
#define INPUTCOLOUR  0x00c00
#define BACKGROUND   0xffff

void realtime(chanend fromEqualiser, chanend fromFFTBefore, chanend fromFFTAfter, chanend toLCD, out port led_screen) {
    int cnt = 0, cntA = 0;
    int rowCount = 0;
    int subColCount = 0;
    int colCount =0;
    int lta[64];
    int buf[64];
    int ltaA[64];
    int bufA[64];
    int next[8], col[8], theNext, theCol, equaliser[BANKS];
    int i;
    unsigned dummy;

    led_screen <: 0;
    for(int i = 0; i<BANKS; i++) {
        equaliser[i] = 0;
    }
    for(int i = 0; i<64; i++) {
        lta[i] = (i*2)<<8;
        ltaA[i] = (i*2)<<8;
    }
    i = 0;
    outuint(toLCD, 0);
#pragma unsafe arrays
    while(1) {
        select {

        case fromFFTAfter :> int x:
            if (x == 0x80000000) {
                shutdown(toLCD, x,fromFFTBefore, led_screen);
                return;
            }
            bufA[cntA] = x ;
            ltaA[cntA] = (ltaA[cntA] * 31 + (x<<8)) >> 5;
            cntA++;
            if (cntA == 64) {
                cntA = 0;
            }
            break;

        case fromEqualiser :> int x:
            if (x >=0 && x < BANKS) {
                fromEqualiser :> equaliser[x];
            } else {
                fromEqualiser :> x;
            }
            break;

        case fromFFTBefore :> int x:
            if (x == 0x80000000) {
                shutdown(toLCD, x,fromFFTAfter, led_screen);
                return;
            }
            buf[cnt] = x ;
            lta[cnt] = (lta[cnt] * 31 + (x<<8)) >> 5;
            cnt++;
            if (cnt == 64) {
                cnt = 0;
            }
            break;

        case inuint_byref(toLCD, dummy):
            if (rowCount >= theNext) {
                theCol = col[i];
                theNext = next[i];
                i++;
            }
            outuint(toLCD, theCol);
            rowCount++;

            if (rowCount == 120) {
                rowCount = 0;
                subColCount++;
                if (subColCount == 5) {
                    subColCount = 0;
                    colCount++;
                    if( colCount == 64) {
                        colCount = 0;
                    }
                }
                {
                    int v0 = buf[colCount];
                    int aa;
                    int marker;
                    if (subColCount > 2) {
                        marker = 0;
                        aa = 2*equaliser[colCount*BANKS>>6];
                    } else {
                        aa = ltaA[colCount] >> 8;
                        marker = FILTERCOLOUR;
                    }
                    i = 0;
                    if (subColCount == 0 && (colCount & 7) == 0 ) {
                        theNext = 128;
                        theCol = 0x1f7df;
                    } else {
                        if (v0 == aa) {
                            theNext = aa;
                            next[0] = aa+1;
                            next[1] = 128;
                            theCol = INPUTCOLOUR;
                            col[0] = marker;
                            col[1] = BACKGROUND;
                        } else if (v0 < aa) {
                            theNext = v0;
                            next[0] = aa;
                            next[1] = aa+1;
                            next[2] = 128;
                            theCol = INPUTCOLOUR;
                            col[0] = BACKGROUND;
                            col[1] = marker;
                            col[2] = BACKGROUND;
                        } else {
                            theNext = aa;
                            next[0] = aa+1;
                            next[1] = v0;
                            next[2] = 128;
                            theCol = INPUTCOLOUR;
                            col[0] = marker;
                            col[1] = INPUTCOLOUR;
                            col[2] = BACKGROUND;
                        }
                    }
                }
            }
            inuint(toLCD);

            outuint(toLCD, theCol);
            break;
        }
    }
}

void freq(chanend fromEqualiser, chanend toLCD, chanend beforeFilter, chanend afterFilter, out port led_left, out port led_right, out port led_screen) {
    chan toScreenBefore, toScreenAfter;
    chan bufBefore, bufAfter;

    par {
        buffer(beforeFilter, bufBefore, led_left);
        buffer(afterFilter, bufAfter, led_right);
        ffter(bufBefore, toScreenBefore);
        ffter(bufAfter, toScreenAfter);
        realtime(fromEqualiser, toScreenBefore, toScreenAfter, toLCD, led_screen);
    }
}
