// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*
 * @Example App - Pong
 * @Description Simple two player pong demonstration.
 *    main.xc: Top-level par declaration and channel setup
 */

#include <xs1.h>
#include <platform.h>

void getButtonData(in port p_btn, in port p_btn2, chanend c_pong);
void pongMain(chanend c_btns, chanend c_gen);
void pongFrameGen(chanend c_pong, chanend c_lcd);
void lcd(out port p_hsync, out port p_dtmg, out port p_dclk, out port p_rgb, clock clk_lcd, chanend c);

// Button Ports, on core 0 on the XDK
on stdcore[0]: in port    p_btn  = XS1_PORT_8C;
on stdcore[0]: in port    p_btn2 = XS1_PORT_1J;

// LCD Ports, on core 3 on the XDK
on stdcore[3]: out port   p_hsync = PORT_LCD_HSYNC;
on stdcore[3]: out port   p_dtmg  = PORT_LCD_DTMG;
on stdcore[3]: out port   p_dclk  = PORT_LCD_DCLK;
on stdcore[3]: out port   p_rgb   = PORT_LCD_RGB;

// Clock block for driving the LCD
on stdcore[3]: clock      clk_lcd = XS1_CLKBLK_2;

int main()
{
  chan c_lcd, c_btn, c_pong;
  par
  {
    on stdcore[0]: getButtonData(p_btn, p_btn2, c_btn);
    on stdcore[2]: pongMain(c_btn, c_pong);
    on stdcore[2]: pongFrameGen(c_pong, c_lcd);
    on stdcore[3]: { lcd(p_hsync, p_dtmg, p_dclk, p_rgb, clk_lcd, c_lcd); set_port_use_off(p_dclk); }
  }
  return 0;
}
