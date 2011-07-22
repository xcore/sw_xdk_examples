/**
 * Module:  rgb_leds
 * Version: 1v1
 * Build:   f4342838884e05fbfcf9a6e35bb5e66dbbf16ebe
 * File:    top.xc
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

extern void getButtonData(chanend ch);
extern void rgbLeds(chanend ch);

int main()
{
  chan ch;
  par
  {
    on stdcore[0] : getButtonData(ch);
    on stdcore[2] : rgbLeds(ch);
  }
  return 0;
}
