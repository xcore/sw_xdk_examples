// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>
#include <platform.h>
#include "LcdDefines.h"
#include "LcdDriver.h"

// Ports
on stdcore[0] : port in p_keys        = XS1_PORT_4F;
on stdcore[0] : port in p_key         = XS1_PORT_1J;
on stdcore[3] : port p_aud_lrcin      = XS1_PORT_1D;    // X3D11
on stdcore[3] : port p_aud_lrcout     = XS1_PORT_1H;    // X3D23
on stdcore[3] : buffered in  port:8 p_aud_din  = XS1_PORT_1J;    // X3D25
on stdcore[3] : buffered out port:8 p_aud_dout = XS1_PORT_1I;    // X3D24
on stdcore[3] : port p_aud_sclk       = XS1_PORT_1K;    // X3D34  2-wire configuration interface.
on stdcore[3] : port p_aud_sdin       = XS1_PORT_1L;    // X3D35
on stdcore[3] : port out p_led_dac    = XS1_PORT_1E;
on stdcore[3] : port out p_led_adc    = XS1_PORT_1G;
on stdcore[3] : out port p_lcd_hsync  = LCD_PORT_HSYNC;
on stdcore[3] : out port p_lcd_dtmg   = LCD_PORT_DTMG;
on stdcore[3] : out port p_lcd_dclk   = LCD_PORT_DCLK;
on stdcore[3] : out port p_lcd_rgb    = LCD_PORT_RGB;
on stdcore[3] : port out p_led_lcd    = XS1_PORT_1F;
on stdcore[0] : port out p_led_left   = XS1_PORT_1F;
on stdcore[0] : port out p_led_right  = XS1_PORT_1E;
on stdcore[0] : port out p_led_screen = XS1_PORT_1G;

// Threads
void keys(port in keys_port, port in key, chanend toCodec, chanend outSelect, chanend toTouch);
void touch(chanend fromKeys, chanend toVis, chanend c_adc, chanend c_adc2);
void freq(chanend fromEqualiser, chanend toLCD, chanend beforeFilter, chanend afterFilter, out port led_left, out port led_right, out port led_screen);
void filter(chanend gains, chanend sin, chanend sout);
void audio(chanend adc_buf, chanend before, chanend leftIn, chanend rightIn, chanend leftOut, chanend rightOut, chanend after, chanend selector, port AUD_LRCIN, port AUD_LRCOUT, buffered in port:8 AUD_DIN, buffered out port:8 AUD_DOUT, out port led_adc, out port led_dac, port AUD_SCLK, port AUD_SDIN);

int main()
{
    // Channel declarations
    chan toLCD, killCodec, audioSelect, toTouchFromKeys;
    chan filterDataLeft, filterDataRight;
    chan filterCoefficients1, filterCoefficients2;
    chan filteredDataLeft, filteredDataRight;
    chan displayEqualiser, beforeFilter, afterFilter;

    par
    {
        on stdcore[0] : keys(p_keys, p_key, killCodec, audioSelect, toTouchFromKeys);
        on stdcore[0] : freq(displayEqualiser, toLCD, beforeFilter, afterFilter, p_led_left, p_led_right, p_led_screen);

        on stdcore[3] : filter(filterCoefficients1, filterDataLeft, filteredDataLeft);
        on stdcore[3] : filter(filterCoefficients2, filterDataRight, filteredDataRight);
        on stdcore[3] : touch(toTouchFromKeys, displayEqualiser, filterCoefficients1, filterCoefficients2);
        on stdcore[3] : lcd_init(toLCD, p_lcd_hsync, p_lcd_dclk, p_lcd_dtmg, p_lcd_rgb, p_led_lcd);
        on stdcore[3] : audio(killCodec, beforeFilter, filterDataLeft, filterDataRight, filteredDataLeft, filteredDataRight, afterFilter, audioSelect, p_aud_lrcin, p_aud_lrcout, p_aud_din, p_aud_dout, p_led_adc, p_led_dac, p_aud_sclk, p_aud_sdin);
    }

    return 0;
}
