/* LCD driver code. Reads data from SDRAM to buffer then writes to screen.
 */

#include <xs1.h>
#include "lcd.h"
#include "lcd_defines.h"
#include <platform.h>

// LCD ports set up in main.

on stdcore[3]:clock clk = XS1_CLKBLK_3;

on stdcore[3] : out port HSYNC_port  = LCD_PORT_HSYNC;
on stdcore[3] : out port DTMG_port   = LCD_PORT_DTMG;
on stdcore[3] : out port DCLK_port   = LCD_PORT_DCLK;
on stdcore[3] : out port RGB_port    = LCD_PORT_RGB;
on stdcore[3] : port out p_led_lcd    = XS1_PORT_1F;


// from app freq, LCD is driven as 240w x 320h.

void LCD_driver(streaming chanend c_lcd, chanend c_flash_done) {
  // code mainly copied from XDK driver.
  timer t;
  unsigned time;
  unsigned x;
  unsigned lineCount;
  unsigned rowCount;

  // Wait for flash to be finished.
 c_flash_done :> int _;


  // Continuously drive the screen
  // code copied from Henk's AppFreq demo which we know works.

  set_clock_off(clk);
  set_clock_on(clk);

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

  while (1) {
  t :> time;
    t when timerafter(time+T_VBP) :> time;

    for(lineCount = 0; lineCount < LCD_HEIGHT; lineCount++) {
      t when timerafter(time + T_WH) :> time;
      HSYNC_port <: 1;
      c_lcd <: 0; // request a row.
    c_lcd :> int _;
    c_lcd :> x;
      t when timerafter(time+T_HBP) :> time;
      DTMG_port <: 1;
      for(rowCount = 0; rowCount < LCD_WIDTH; rowCount++) {

        RGB_port <: x;
      c_lcd :> x;
      }

      DTMG_port <: 0;

    t :> time;
      t when timerafter( time + T_HFP) :> time;

      HSYNC_port <:0;
    }

  }

}



