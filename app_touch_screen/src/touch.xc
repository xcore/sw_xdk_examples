/**
 * Module:  touch_screen
 * Version: 1v1
 * Build:   b454f88b0e425ad38993188bdace5bbbcdf50276
 * File:    touch.xc
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
///////////////////////////////////////////////////////////////////////
//                                                                   //
//                      XMOS Semiconductor Ltd                       //
//                         * Touch screen *                          //
//                                                                   //
//             Simple touchscreen/LCD test/demo program              //
//                Note: Does not perform any calibration             //
//						                                                   //
//                             Ross Owen                             //
//                             June 2008                             //
///////////////////////////////////////////////////////////////////////

/*
This simple application demonstrates interfacing a touchscreen digitizer
and driving an LCD screen.

By default the program displays a large red cross on the screen and waits
for a user to press the screen.  On detection of this press the cross
colour is changed to green, the position of the press recorded and location
of the cross adjusted accordingly.  When pressure is removed the cross
turns to being red and remains stationary.

The entire program consists of three threads:

 1. Main program loop: Waits for user to press screen, outputs position
    data via channels to "position keeper"
 2. Position keeper: Keeps position and colour of cross. Deals with
    read/writes via channels
 3. LCD Thread: Gets colour/position of cross from "position keeper" once
    per frame and drives to LCD.
*/

#include <xs1.h>
#include <platform.h>
#include <xclib.h>

#define CMD_POS         0x0
#define CMD_COLOUR      0x1
#define CMD_KILL        0x2

#define CROSS_RADIUS    3

// LCD Defines
#define LCD_WIDTH       240
#define LCD_HEIGHT      320

// LCD Timing defines
#define T_HFP           300
#define T_HBP           600
#define T_WH            150
#define T_VBP           20000

// Some useful colour defines...
#define LCD_WHITE       0x3ffff
#define LCD_BLACK       0x00000
#define LCD_BLUE        0x3f000
#define LCD_GREEN       0x0FC00
#define LCD_RED         0x0003F
#define LCD_TEAL        0x0FFFF
#define LCD_YELLOW      0x3FFC0

unsigned doADCTransaction(unsigned controlReg);
{unsigned,unsigned} getTouchScreenPos();

// LED ports
on stdcore[3] : out port p_led_0 = PORT_LED_3_0;
on stdcore[3] : out port p_led_1 = PORT_LED_3_1;
on stdcore[3] : out port p_led_2 = PORT_LED_3_2;

// Touchscreen ADC ports/ clock block
on stdcore[3] : in port p_tou_pen       = PORT_TOUCH_PEN;         // Pen Interupt
on stdcore[3] : in port p_tou_dout      = PORT_TOUCH_DOUT;        // DOUT (ADC -> Xcore)
on stdcore[3] : out port p_tou_cs       = PORT_TOUCH_CS;
on stdcore[3] : out port p_tou_dclk     = PORT_TOUCH_DCLK;
on stdcore[3] : out port p_tou_din      = PORT_TOUCH_DIN;         // DIN (Xcore -> ADC)

on stdcore[3] : clock clk_tou           = XS1_CLKBLK_1;

// LCD ports/clock block
on stdcore[3] : out port p_lcd_dclk     = PORT_LCD_DCLK;
on stdcore[3] : out port p_lcd_hsync    = PORT_LCD_HSYNC;
on stdcore[3] : out port p_lcd_dtmg     = PORT_LCD_DTMG;
on stdcore[3] : out port p_lcd_rgb      = PORT_LCD_RGB;

on stdcore[3] : clock clk_lcd           = XS1_CLKBLK_2;


/** Main program loop
  * @param chanend c channel to cross position keeper
  * @brief The main program thread.  This thread waits for an user pressing the screen event, reads the position from the touchscreen
  * and uses channels to output this position to the "position keeper" thread
  * @return void
  */
void touch(chanend c_tou, chanend c_but)
{
  unsigned  tmp = 0;
  unsigned tmpx, tmpy, time;
  timer t;
  unsigned ledVal = 0;
  unsigned active = 1;

  // Setup touchscreen/adc ports
  set_clock_div(clk_tou,50);
  start_clock(clk_tou);
  set_port_clock(p_tou_dclk, clk_tou);
  set_port_clock(p_tou_din, clk_tou);
  set_port_clock(p_tou_dout, clk_tou);

  p_tou_cs <: 1;
  p_tou_dclk <: 0;

  // Leds off
  p_led_0 <: 1;
  p_led_1 <: 1;
  p_led_2 <: 1;

  // Set Cross to center of screen
  c_tou <: CMD_POS;
  c_tou <: 120;
  c_tou <: 160;

  // Main loop
  while(active)
  {
    // All LEDs off
    p_led_0 <: 1;
    p_led_1 <: 1;
    p_led_2 <: 1;

    // Set cross colour to red
    c_tou <: CMD_COLOUR;
    c_tou <: LCD_RED;

    // Wait for screen press...
    select
    {
      case p_tou_pen when pinseq(0) :> tmp:
        break;

      case c_but:> int _:
        active = 0;
        break;
    }

    if(active)
    {
      // Screen pressed...Update cross colour
      c_tou <: CMD_COLOUR;
      c_tou <: LCD_GREEN;

      // Get positions on screen
      {tmpx, tmpy} = getTouchScreenPos();

      // Update cross position
      c_tou <: CMD_POS;
      c_tou <: tmpx;
      c_tou <: tmpy;
      ledVal = tmpy;

      //Turn LEDs on (based on y val)
      p_led_2 <: (ledVal > 80);
      p_led_1 <: (ledVal > 160);
      p_led_0 <: (ledVal > 240);

      t :> time;
      t when timerafter(time+1000000) :> time;
    }
    else
    {
      c_tou <: CMD_KILL;

    }
  }
}


/** doADCTransaction
  * @brief Sends commands to ADC and returns relevant data (using SPI)
  */
unsigned doADCTransaction(unsigned controlReg)
{
  unsigned returnVal = 0;
  int i;

  p_tou_cs <: 0;

  controlReg=bitrev(controlReg);
  controlReg=controlReg >> 25;

  p_tou_dclk <: 0;

  // Start bit
  p_tou_din <: 1;
  p_tou_dclk <: 1;

  for(i = 0; i< 7; i+=1)
  {
    p_tou_dclk <: 0;
    p_tou_din <: >> controlReg;
    p_tou_dclk <: 1;
  }

  //Busy clock.  .
  p_tou_dclk <:0;
  p_tou_dclk <:1;

  // TODO: check control reg val to see how many bits to clock in
  // Currently only using 8-bit mode...
  for(i = 0; i < 8; i+=1)
  {
    p_tou_dclk <: 0;
    p_tou_dclk <: 1;
    sync(p_tou_dclk);
    p_tou_dout :> >> returnVal;
  }

  p_tou_cs <: 1;
  p_tou_dclk <: 0;

  return bitrev(returnVal) ;
}


/** getTouchScreenPos
  * @brief Uses doADCTransaction function to get X and Y positions
  * Note the nice use of XC multiple return values for X and Y data
  * Also note: this is probably the main resuable interface this demo app provides
  */
{unsigned, unsigned} getTouchScreenPos()
{
  unsigned returnValX;
  unsigned returnValY;

  // 8 bit/single ended/power up  Y:0x1e  X:0x5e
  // 8 bit/differential/power up  Y:0x1a  X:0x5a
  returnValY = doADCTransaction(0x1a);
  returnValX = doADCTransaction(0x5a);

  // Physical screen resolution is 240 X 320, ADC resolution (8 bit) is 255 * 255.  Do simple scaling and bounds check
  returnValY = (returnValY * 320) >> 8;
  if (returnValX > 240 - CROSS_RADIUS)
    returnValX = 240 - CROSS_RADIUS;

  return {returnValX, returnValY};
}


/** Position Keeper
  * @brief Keeps position and colour data of cross. Takes channel inputs from main program loop and LCD loop
  * to update/read data
  */
void posKeeper(chanend c_adc, chanend c_lcd)
{
  unsigned y_pos = 100;
  unsigned x_pos = 100;
  unsigned colour = LCD_RED;
  unsigned tmp;
  int active = 1;

  while(active)
  {
    select
    {
      case c_adc :> tmp:
        switch(tmp)
        {
          case CMD_POS:          // Update position
             c_adc :> x_pos;
             c_adc :> y_pos;
            break;


          case CMD_COLOUR:
            c_adc :> colour;     // Update colour
            break;

          case CMD_KILL:
            active = 0;
            break;

          default:
            break;
        }
        break;

      case c_lcd :> tmp:        // Read data request
        c_lcd <: 1;
        c_lcd <: x_pos;
        c_lcd <: y_pos;
        c_lcd <: colour;
        break;
    }
  }

  c_lcd :> tmp;
  c_lcd <: 0;

}


/** LCD Loop
  * @brief Main LCD loop. Requests cross position and colour data once per frame drives to screen
  * @param c_lcd channel to position keeper thread
  * Note: The screen is acually a protrait screen mounted in landscape orientation
  */
void LcdLoop(chanend c_lcd)
{
  unsigned porttime;
  unsigned lineCounter;
  unsigned horizCounter;
  unsigned cross_colour = LCD_RED;
  unsigned x_pos, y_pos;            // Cross position
  unsigned tmp;

  while(1)
  {
    // Get position and colour data
    c_lcd <: 1;
    c_lcd :> tmp;
    if(!tmp)
      return;
    c_lcd :> x_pos;
    c_lcd :> y_pos;
    c_lcd :> cross_colour;

    p_lcd_hsync <: 0 @ porttime;
    p_lcd_hsync @ porttime + 700 <: 0;
    sync(p_lcd_hsync);

    // For each line....
    for(lineCounter = 0; lineCounter < LCD_HEIGHT; lineCounter+=1)
    {
      p_lcd_hsync <: 1 @ porttime;

      p_lcd_dtmg @ porttime + 16 <: 1;
      sync(p_lcd_dtmg);

      // Drive out one line ...
      for(horizCounter = 0; horizCounter < LCD_WIDTH; horizCounter++)
      {
        // Draw big cross
        if(lineCounter < y_pos + CROSS_RADIUS && lineCounter > y_pos - CROSS_RADIUS )
          p_lcd_rgb <: cross_colour;
        else  if(horizCounter < x_pos + CROSS_RADIUS && horizCounter > x_pos - CROSS_RADIUS )
          p_lcd_rgb <: cross_colour;
        else
          p_lcd_rgb <: LCD_BLACK;
      }

      p_lcd_dtmg <: 0 @ porttime;

      p_lcd_hsync @ porttime + 11 <:0;

      p_lcd_hsync @ porttime + 11 + 5 <: 0;
      sync(p_lcd_hsync);
    }
  }
}


/** LCD Driver thread
  * @brief Sets up the LCD ports/clock and calls the main lcd loop
  * @param c_lcd channel to position keeper thread
  */
void LcdDriver(chanend c_lcd)
{
  // Setup LCD ports and clock...
  set_clock_div(clk_lcd, 19);                // Clock clock block from divided ref clock

  set_port_inv(p_lcd_dclk);                  // Invert clock (LCD samples on falling edge)

  set_port_clock(p_lcd_dclk, clk_lcd);       // Clock all LCD ports from the clock block
  set_port_clock(p_lcd_dtmg, clk_lcd);
  set_port_clock(p_lcd_rgb, clk_lcd);
  set_port_clock(p_lcd_hsync, clk_lcd);

  set_port_mode_clock(p_lcd_dclk);           // Generate clock using clock mode of port

  start_clock(clk_lcd);                      // Finally start the clock block

  LcdLoop(c_lcd);                            // Run LCD loop

  set_port_mode_data(p_lcd_dclk);
}
















