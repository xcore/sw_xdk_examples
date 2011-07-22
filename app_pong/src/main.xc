/**
 * Module:  pong
 * Version: 1v1
 * Build:   09eb107119f1beff657cf7dc11fdadf918468539
 * File:    main.xc
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
