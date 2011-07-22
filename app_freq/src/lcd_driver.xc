/**
 * Module:  freq
 * Version: 1v1
 * Build:   b45a0fb9ab3e66156caa93683e6c6968b24e3366
 * File:    lcd_driver.xc
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
#include "LcdDefines.h"
#include "LcdDriver.h"

unsigned colours[] =  {LCD_RED, LCD_GREEN, LCD_BLUE};

on stdcore[3]:clock clk = LCD_CLKBLK;

void lcd_shutdown(chanend lcd, out port dclk, clock clk)
{
  outct(lcd, XS1_CT_END);
  inct(lcd);
  set_port_use_off(dclk);
  set_clock_off(clk);
}

void lcd_init(chanend toLCD, out port HSYNC_port, out port DCLK_port, out port DTMG_port, out port RGB_port, out port led) {
    timer t;
    unsigned time;
    unsigned lineCount;
    int rowCount;
    int x;

    set_clock_off(clk);
    set_clock_on(clk);

    led <: 0;
    set_clock_div(clk, LCD_CLKDIV);

    set_port_use_off(HSYNC_port);
    set_port_use_on(HSYNC_port);
    HSYNC_port <: 0;

    set_port_use_off(DTMG_port);
    set_port_use_on(DTMG_port);
    DTMG_port <: 0;

    set_port_use_off(DCLK_port);
    set_port_use_on(DCLK_port);
    // Don't output on DCLK here
    // It will go to output mode

    set_port_inv(DCLK_port);

    set_port_clock(HSYNC_port, clk);
    set_port_clock(DCLK_port, clk);
    set_port_clock(DTMG_port, clk);
    set_port_clock(RGB_port, clk);

    set_port_mode_clock(DCLK_port);      // Outclock
    start_clock(clk);


    x = inuint(toLCD);	// Read 0
    outuint(toLCD, 3);
    x = inuint(toLCD);	// First sample
    outuint(toLCD, 3);
    outuint(toLCD, 3);

    while(1) {
        t :> time;
        t when timerafter(time+T_VBP) :> time;

        for(lineCount = 0; lineCount < LCD_HEIGHT_PX; lineCount++) {
            t when timerafter(time + T_WH) :> time;
            HSYNC_port <: 1;
            t when timerafter(time+T_HBP) :> time;
            DTMG_port <: 1;

            for(rowCount = 0; rowCount < LCD_WIDTH_PX; rowCount++) {
                RGB_port <: x;
                x = inuint(toLCD);	
                outuint(toLCD, 3);
                if (x == 0x80000000) {
                    led <: 1;
                    lcd_shutdown(toLCD, DCLK_port, clk);
                    return;
                }
            }

            DTMG_port <: 0;

            t :> time;
            t when timerafter( time + T_HFP) :> time;

            HSYNC_port <:0;
        }
    }

}
