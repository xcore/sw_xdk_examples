/**
 * Module:  rgb_leds
 * Version: 1v1
 * Build:   f4342838884e05fbfcf9a6e35bb5e66dbbf16ebe
 * File:    rgb.xc
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
 * @RGB Leds
 * @Description Runs patterns on RGB Leds
 */

#include <platform.h>

#define HOME_BUTTON 4

on stdcore[2] : out port p_rgb_sclk  = PORT_RGB_SCLK;
on stdcore[2] : out port p_rgb_sin   = PORT_RGB_SIN;
on stdcore[2] : out port p_rgb_csel  = PORT_RGB_CSEL;
on stdcore[2] : out port p_rgb_latch = PORT_RGB_LATCH_N;
on stdcore[2] : out port p_rgb_blank = PORT_RGB_BLANK;

void DriveLeds(out port blank, out port csel, out port sclk, out port sin, out port latch, unsigned holdLength, unsigned patterns[3])
{
  unsigned currentColour;

  latch <: 1;

  for (currentColour = 0; currentColour < 3; currentColour += 1)
  {
    unsigned i;
    unsigned currentPattern;

    csel <: currentColour;

    currentPattern = patterns[currentColour];

    for (i = 0; i < 16; i += 1)
    {
      sclk <: 0;
      sin <: >> currentPattern;
      sclk <: 1;
    }

    latch <: 0;
    sclk <: 1;
    latch <: 1;

    for (i = 0; i < holdLength; i += 1)
    {
      sclk <: 0;
    }
  }
}

void rgbLeds(chanend ch)
{
  int running=1;
  int buttonState;
#if 0
  //1
  unsigned patterns[3] = {0xffff, 0x0000, 0x0000};

  blank <: 0;

  while(running)
  {
    // Poll button thread
    ch <: 0;
    ch :> buttonState;
    if (buttonState & HOME_BUTTON)
        running = 0;
    DriveLeds(blank, csel, sclk, sin, latch, 1000, patterns);
  }
#endif
#if 0
  //2
  unsigned patterns[3] = {0xffff, 0xffff, 0xffff};

  blank <: 0;

  while(running)
  {
    // Poll button thread
    ch <: 0;
    ch :> buttonState;
    if (buttonState & HOME_BUTTON)
        running = 0;
    DriveLeds(blank, csel, sclk, sin, latch, 1000000, patterns);
  }
#endif
#if 1
  unsigned patterns[3] = {0x8000, 0x0000, 0x0100};
  int i;

  p_rgb_blank <: 0;

  while (running)
  {

    for (i = 0; (i < 500) && running; i += 1)
    {

        // Poll button thread
        ch <: 0;
        ch :> buttonState;
        if (buttonState & HOME_BUTTON)
        {
          ch <: 1;
          running = 0;
        }

        // Drive the LEDs again
        DriveLeds(p_rgb_blank, p_rgb_csel, p_rgb_sclk, p_rgb_sin, p_rgb_latch, 1000, patterns);

    }

    patterns[0] = patterns[0] >> 1;
    patterns[2] = patterns[2] << 1;

    if(patterns[0] == 0x80)
    {
      patterns[0] = 0x8000;
      patterns[2] = 0x0100;
    }

  }

  p_rgb_blank <: 1;
#endif
}
